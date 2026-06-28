import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import 'error/failure.dart';
import 'error/error_handler/network_exceptions.dart';

// =============================================================================
// TASK 4 — Fault-Tolerant Client Interceptor Service
// المسار: lib/core/networking/resilient_fetcher.dart
//
// المشكلة التي يحلها:
//   عند فشل الاتصال بالسيرفر، كان التطبيق ينتظر 30 ثانية لكل طلب قبل أن يُظهر
//   رسالة خطأ. هذا يعني أن المستخدم عالق أمام شاشة تحميل لفترة طويلة.
//
// الحل المُطبَّق — ثلاث آليات متكاملة:
//
//   1. Circuit Breaker (قاطع الدائرة)
//      آلة حالات بثلاثة أوضاع:
//      - CLOSED  : الاتصال طبيعي، كل الطلبات تمر
//      - OPEN    : السيرفر فاشل، نُرجع fallback فوراً دون انتظار
//      - HALF_OPEN: بعد انتهاء فترة الانتظار، نبعث طلب اختبار واحد
//
//   2. Retry Policy (إعادة المحاولة)
//      عند الفشل، ننتظر ثم نحاول مجدداً، لكن بوقت انتظار متصاعد (backoff)
//      حتى لا نُغرق السيرفر المتعافي بالطلبات
//
//   3. Jitter (عشوائية الانتظار)
//      نضيف ±25% عشوائي على وقت الانتظار لمنع "thundering herd":
//      لو 1000 مستخدم يعيدون المحاولة في نفس اللحظة، تتوزع طلباتهم تلقائياً
//
// كيف يُستخدم في المشروع:
//   AppFetchers.transfer.call(request: ..., fallback: ...)
//   AppFetchers.auth.call(request: ..., fallback: ...)
// =============================================================================

// -----------------------------------------------------------------------------
// Circuit Breaker States — أوضاع قاطع الدائرة
// -----------------------------------------------------------------------------

enum CircuitState {
  /// الوضع الطبيعي: الاتصال يعمل، كل الطلبات تمر
  closed,

  /// السيرفر فاشل: نُرجع fallback فوراً بدون ما نحاول الاتصال
  open,

  /// فترة اختبار: انتهى وقت الانتظار، نبعث طلباً واحداً لنختبر السيرفر
  halfOpen,
}

// -----------------------------------------------------------------------------
// CircuitBreakerConfig — إعدادات قابلة للتخصيص لكل API
// -----------------------------------------------------------------------------

class CircuitBreakerConfig {
  /// عدد الفشل المتتالي قبل فتح الدائرة
  final int failureThreshold;

  /// وقت الانتظار في وضع OPEN قبل الانتقال لـ HALF_OPEN
  final Duration cooldownDuration;

  /// عدد مرات إعادة المحاولة قبل اعتبار الطلب فاشلاً نهائياً
  final int maxRetries;

  /// أقل وقت انتظار بين المحاولات (يتضاعف مع كل محاولة)
  final Duration baseDelay;

  /// أقصى وقت انتظار بين المحاولات مهما كبر الـ backoff
  final Duration maxDelay;

  /// نسبة العشوائية المضافة على وقت الانتظار (0.25 = ±25%)
  final double jitterFactor;

  const CircuitBreakerConfig({
    this.failureThreshold = 3,
    this.cooldownDuration = const Duration(seconds: 5),
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.jitterFactor = 0.25,
  });
}

// -----------------------------------------------------------------------------
// CircuitBreaker — آلة الحالات الأساسية
// -----------------------------------------------------------------------------

class CircuitBreaker {
  final CircuitBreakerConfig config;

  /// اسم للتمييز في الـ logs (مثلاً: 'transfer-api')
  final String name;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _openedAt;

  CircuitBreaker({required this.name, this.config = const CircuitBreakerConfig()});

  CircuitState get state => _state;
  int get failureCount => _failureCount;

  /// هل يُسمح لهذا الطلب بالمرور؟
  bool get isRequestAllowed {
    switch (_state) {
      case CircuitState.closed:
        // الوضع الطبيعي: دائماً نسمح
        return true;

      case CircuitState.open:
        // هل انتهت فترة الـ cooldown؟
        if (_openedAt != null &&
            DateTime.now().difference(_openedAt!) >= config.cooldownDuration) {
          // انتقل لـ HALF_OPEN وأذن بطلب اختبار واحد
          _transitionTo(CircuitState.halfOpen);
          return true;
        }
        // لا — السيرفر لا يزال محجوباً
        return false;

      case CircuitState.halfOpen:
        // نسمح بطلب اختبار واحد
        return true;
    }
  }

  /// استدعَ هذا عند نجاح الطلب لإعادة الدائرة لوضعها الطبيعي
  void recordSuccess() {
    if (_state == CircuitState.halfOpen) {
      _log('✅ طلب الاختبار نجح — إغلاق الدائرة');
    }
    _failureCount = 0;
    _transitionTo(CircuitState.closed);
  }

  /// استدعَ هذا عند فشل الطلب لتتبع عدد الإخفاقات
  void recordFailure() {
    _failureCount++;
    _log('❌ فشل رقم #$_failureCount');

    if (_state == CircuitState.halfOpen) {
      // طلب الاختبار فشل — افتح الدائرة مجدداً
      _openCircuit();
      return;
    }

    // هل وصلنا للحد الأقصى من الإخفاقات؟
    if (_failureCount >= config.failureThreshold) {
      _openCircuit();
    }
  }

  void _openCircuit() {
    _openedAt = DateTime.now();
    _transitionTo(CircuitState.open);
  }

  void _transitionTo(CircuitState next) {
    if (_state == next) return;
    _log('🔄 ${_state.name} → ${next.name}');
    _state = next;
  }

  void _log(String msg) {
    if (kDebugMode) print('[CircuitBreaker:$name] $msg');
  }

  /// الوقت المتبقي في وضع OPEN قبل الانتقال لـ HALF_OPEN
  /// يُستخدم في الـ UI لعرض عداد تنازلي
  Duration? get remainingCooldown {
    if (_state != CircuitState.open || _openedAt == null) return null;
    final elapsed = DateTime.now().difference(_openedAt!);
    final remaining = config.cooldownDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

// -----------------------------------------------------------------------------
// RetryPolicy — سياسة إعادة المحاولة مع Exponential Backoff + Jitter
// -----------------------------------------------------------------------------

class RetryPolicy {
  final CircuitBreakerConfig config;
  final _random = Random();

  RetryPolicy({this.config = const CircuitBreakerConfig()});

  /// احسب وقت الانتظار للمحاولة رقم [attempt] (تبدأ من 0)
  ///
  /// المعادلة: min(baseDelay × 2^attempt, maxDelay) ± jitter
  ///
  /// مثال مع baseDelay = 500ms:
  ///   attempt 0 → ~500ms
  ///   attempt 1 → ~1000ms
  ///   attempt 2 → ~2000ms
  ///   attempt 3 → ~4000ms (محدود بـ maxDelay)
  Duration delayFor(int attempt) {
    final base = config.baseDelay.inMilliseconds * pow(2, attempt);
    final capped = min(base, config.maxDelay.inMilliseconds.toDouble());

    // الـ jitter: يضيف عشوائية ±25% لتوزيع الطلبات
    final jitter = capped * config.jitterFactor * (_random.nextDouble() * 2 - 1);

    final ms = max(0.0, capped + jitter).round();
    return Duration(milliseconds: ms);
  }

  /// هل يستحق هذا الخطأ إعادة المحاولة؟
  ///
  /// نعيد المحاولة فقط على أخطاء مؤقتة (شبكة، timeout، 5xx)
  /// لا نعيد المحاولة على أخطاء المستخدم (4xx)
  bool shouldRetry(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.connectionError:
          return true; // مشاكل شبكة مؤقتة — نعيد المحاولة
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode ?? 0;
          return status >= 500; // 5xx = خطأ في السيرفر، 4xx = خطأ منّا
        default:
          return false;
      }
    }
    return false;
  }
}

// -----------------------------------------------------------------------------
// ResilientFetcher — الواجهة الرئيسية التي تُستخدم في كل مكان
// -----------------------------------------------------------------------------

/// يُلف أي استدعاء Dio بـ Circuit Breaker + Retry + Backoff.
///
/// الاستخدام:
/// ```dart
/// final result = await AppFetchers.transfer.call(
///   request: () => crudDio.dioPostMethod(...),
///   fallback: Left(ServerFailure('الخدمة غير متاحة مؤقتاً')),
/// );
/// ```
class ResilientFetcher {
  final CircuitBreaker _breaker;
  final RetryPolicy _retry;

  ResilientFetcher({
    required String name,
    CircuitBreakerConfig config = const CircuitBreakerConfig(),
  })  : _breaker = CircuitBreaker(name: name, config: config),
        _retry = RetryPolicy(config: config);

  // للعرض في الـ UI (CircuitBreakerBanner يقرأ هذه القيم)
  CircuitState get circuitState => _breaker.state;
  int get failureCount => _breaker.failureCount;
  Duration? get remainingCooldown => _breaker.remainingCooldown;

  /// نفّذ الطلب مع حماية كاملة
  ///
  /// [request] : lambda يحتوي على الطلب الفعلي
  /// [fallback] : القيمة التي تُرجع فوراً إذا كانت الدائرة مفتوحة
  Future<Either<Failure, T>> call<T>({
    required Future<Either<Failure, T>> Function() request,
    required Either<Failure, T> fallback,
  }) async {
    // --- التحقق من Circuit Breaker أولاً ---
    if (!_breaker.isRequestAllowed) {
      final cooldown = _breaker.remainingCooldown;
      _log('⚡ fast-fail — الدائرة مفتوحة (${cooldown?.inSeconds}s متبقية)');
      return fallback; // إرجاع فوري دون انتظار
    }

    int attempt = 0;
    Object? lastError;

    // --- حلقة إعادة المحاولة ---
    while (attempt <= _retry.config.maxRetries) {
      try {
        final result = await request();

        // سجّل نجاح أو فشل في الـ Circuit Breaker
        result.fold(
          (failure) {
            _breaker.recordFailure();
            lastError = failure;
          },
          (_) {
            _breaker.recordSuccess();
          },
        );

        // إذا نجح الطلب، أرجع النتيجة مباشرة
        if (result.isRight()) return result;

        // إذا فشل، انتظر قبل المحاولة التالية
        if (attempt < _retry.config.maxRetries) {
          final delay = _retry.delayFor(attempt);
          _log('⏳ محاولة ${attempt + 1} فشلت — إعادة المحاولة بعد ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
        }
      } catch (e) {
        lastError = e;
        _breaker.recordFailure();

        // إذا لم يستحق الخطأ إعادة المحاولة، نوقف
        if (!_retry.shouldRetry(e) || attempt >= _retry.config.maxRetries) {
          break;
        }

        final delay = _retry.delayFor(attempt);
        _log('⏳ محاولة ${attempt + 1} رمت خطأ — إعادة المحاولة بعد ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }

      attempt++;
    }

    // --- استُنفدت كل المحاولات — أرجع الـ fallback ---
    _log('💀 استُنفدت $attempt محاولة — إرجاع الـ fallback');
    return fallback;
  }

  void _log(String msg) {
    if (kDebugMode) print('[ResilientFetcher] $msg');
  }
}

// -----------------------------------------------------------------------------
// AppFetchers — instances جاهزة، واحد لكل نوع API
//
// نستخدم singletons لأن الـ state (failureCount, openedAt) يجب أن يكون
// مشتركاً بين كل الاستدعاءات لنفس الـ API
// -----------------------------------------------------------------------------

class AppFetchers {
  AppFetchers._();

  /// للتحويلات المالية — أكثر صرامة (3 إخفاقات تفتح الدائرة)
  static final transfer = ResilientFetcher(
    name: 'transfer-api',
    config: const CircuitBreakerConfig(
      failureThreshold: 3,
      cooldownDuration: Duration(seconds: 5),
      maxRetries: 3,
      baseDelay: Duration(milliseconds: 500),
    ),
  );

  /// للمصادقة — أسرع في الفتح (2 إخفاقات) لأن تجربة تسجيل الدخول حساسة
  static final auth = ResilientFetcher(
    name: 'auth-api',
    config: const CircuitBreakerConfig(
      failureThreshold: 2,
      cooldownDuration: Duration(seconds: 8),
      maxRetries: 2,
      baseDelay: Duration(milliseconds: 300),
    ),
  );

  /// للحسابات — أكثر تساهلاً (4 إخفاقات) لأن القراءات أقل حساسية
  static final accounts = ResilientFetcher(
    name: 'accounts-api',
    config: const CircuitBreakerConfig(
      failureThreshold: 4,
      cooldownDuration: Duration(seconds: 5),
      maxRetries: 3,
      baseDelay: Duration(milliseconds: 500),
    ),
  );
}