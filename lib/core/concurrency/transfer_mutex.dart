import 'dart:async';
import 'package:flutter/foundation.dart';

// =============================================================================
// TASK — Distributed Mutex Lock Coordinator
// المسار: lib/core/concurrency/transfer_mutex.dart
//
// المشكلة التي يحلها:
//   إذا ضغط المستخدم زر "تحويل" مرتين بسرعة، أو أعاد المحاولة فوراً بعد بطء
//   الشبكة، فقد يُنفَّذ نفس التحويل مرتين — أي خسارة مزدوجة من الرصيد.
//
// الحل — أربع آليات متكاملة:
//
//   1. Mutex Lock:
//      يضمن أن عملية تحويل واحدة فقط تعمل في نفس الوقت.
//      الطلب الثاني يحصل على MutexLocked فوراً.
//
//   2. Fencing Token:
//      رقم متصاعد يُعطى لكل عملية. إذا وصل طلب قديم متأخر من الشبكة
//      بـ token أصغر من الحالي، نرفضه تلقائياً.
//
//   3. Idempotency Key:
//      نبني مفتاحاً فريداً من (from + to + amount + الدقيقة الحالية).
//      إذا جاء نفس التحويل بنفس البيانات خلال 30 ثانية، نرجع نجاح هادئ
//      دون تنفيذ مجدد.
//
//   4. Lease Expiry:
//      إذا انهار التطبيق أثناء التحويل، يتحرر القفل تلقائياً بعد 10 ثوانٍ
//      لمنع "dead lock" دائم.
//
// كيف يُستخدم:
//   final result = await _mutex.runExclusive(
//     idempotencyKey: IdempotencyKeyBuilder.forTransfer(...),
//     task: () => _run2PC(current, amount),
//   );
// =============================================================================

// -----------------------------------------------------------------------------
// MutexResult — نتيجة محاولة الحصول على القفل (sealed = type-safe exhaustive)
// -----------------------------------------------------------------------------

/// الكلاس الأساسي — sealed يعني أن الـ switch في الـ Cubit يجب أن يعالج كل حالة
sealed class MutexResult<T> {
  const MutexResult();
}

/// العملية نجحت: القفل حُصل عليه والـ task اكتمل
class MutexSuccess<T> extends MutexResult<T> {
  final T value;
  final int fencingToken; // الرقم المتسلسل لهذه العملية
  const MutexSuccess({required this.value, required this.fencingToken});
}

/// طلب مكرر: نفس الـ idempotencyKey تم تنفيذه خلال الـ window
/// نُرجع نجاحاً هادئاً دون تنفيذ مجدد
class MutexDuplicate<T> extends MutexResult<T> {
  final String key;
  const MutexDuplicate(this.key);
}

/// القفل محجوز بعملية أخرى — double-submission محظور
class MutexLocked<T> extends MutexResult<T> {
  final String lockedBy;      // مَن يحمل القفل حالياً
  final Duration remainingLease; // كم وقت متبقٍ
  const MutexLocked({required this.lockedBy, required this.remainingLease});
}

/// Fencing token قديم — طلب وصل متأخراً من الشبكة
/// نسجله كـ suspiciousActivity في الـ AuditLogger
class MutexFencingRejected<T> extends MutexResult<T> {
  final int submittedToken; // الرقم الذي أرسله الطلب
  final int currentToken;   // الرقم الحالي في النظام
  const MutexFencingRejected({
    required this.submittedToken,
    required this.currentToken,
  });
}

/// خطأ داخل الـ task نفسه (شبكة، validation، إلخ)
class MutexTaskError<T> extends MutexResult<T> {
  final Object error;
  const MutexTaskError(this.error);
}

// -----------------------------------------------------------------------------
// _LockEntry — بيانات القفل النشط (private — لا يُكشف للخارج)
// -----------------------------------------------------------------------------

class _LockEntry {
  /// المفتاح الفريد للعملية التي تحمل القفل
  final String ownerId;
  final int fencingToken;
  final DateTime acquiredAt;
  final DateTime expiresAt; // بعد هذا الوقت يتحرر القفل تلقائياً

  _LockEntry({
    required this.ownerId,
    required this.fencingToken,
    required this.acquiredAt,
    required this.expiresAt,
  });

  /// هل انتهت صلاحية القفل؟ (Lease Expiry)
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingLease {
    final r = expiresAt.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }
}

// -----------------------------------------------------------------------------
// TransferMutex — المنطق الأساسي
// -----------------------------------------------------------------------------

class TransferMutex {
  /// أقصى وقت يُحجز فيه القفل (يتحرر تلقائياً لو التطبيق انهار)
  final Duration leaseDuration;

  /// كم وقت نتذكر الـ idempotency key بعد انتهاء العملية
  final Duration idempotencyWindow;

  TransferMutex({
    this.leaseDuration = const Duration(seconds: 10),
    this.idempotencyWindow = const Duration(seconds: 30),
  });

  // --- الحالة الداخلية ---
  _LockEntry? _currentLock;
  int _fencingSequence = 1000; // يبدأ من 1000 ليكون واضحاً في الـ logs

  /// ذاكرة العمليات المنفَّذة مؤخراً لمنع التكرار
  final _idempotencyCache = <String, DateTime>{};

  /// نفّذ [task] بشكل حصري — عملية واحدة في نفس الوقت
  Future<MutexResult<T>> runExclusive<T>({
    required String idempotencyKey,
    required Future<T> Function() task,
    int? fencingToken, // اختياري — للتحقق من طلبات خارجية
  }) async {
    // --- 1. Lease Expiry Check ---
    // إذا انتهى وقت القفل السابق، نحرره تلقائياً
    if (_currentLock != null && _currentLock!.isExpired) {
      _log('⏰ انتهت صلاحية القفل لـ ${_currentLock!.ownerId} — تحرير تلقائي');
      _currentLock = null;
    }

    // --- 2. Idempotency Check ---
    // هل نفذنا هذه العملية بالفعل خلال الـ window؟
    final cachedExpiry = _idempotencyCache[idempotencyKey];
    if (cachedExpiry != null && DateTime.now().isBefore(cachedExpiry)) {
      _log('♻️ طلب مكرر: $idempotencyKey');
      return MutexDuplicate(idempotencyKey);
    }

    // --- 3. Fencing Token Check ---
    // هل الطلب قادم من عملية قديمة؟
    if (fencingToken != null && fencingToken < _fencingSequence) {
      _log('🚫 token مرفوض: $fencingToken < $_fencingSequence الحالي');
      return MutexFencingRejected(
        submittedToken: fencingToken,
        currentToken: _fencingSequence,
      );
    }

    // --- 4. Lock Acquisition ---
    // هل القفل محجوز بعملية أخرى؟
    if (_currentLock != null) {
      _log('🔒 محجوز بواسطة: ${_currentLock!.ownerId}');
      return MutexLocked(
        lockedBy: _currentLock!.ownerId,
        remainingLease: _currentLock!.remainingLease,
      );
    }

    // احجز القفل لهذه العملية
    _fencingSequence++;
    final token = _fencingSequence;
    final now = DateTime.now();

    _currentLock = _LockEntry(
      ownerId: idempotencyKey,
      fencingToken: token,
      acquiredAt: now,
      expiresAt: now.add(leaseDuration),
    );

    _log('✅ تم الحجز: $idempotencyKey | token: $token');

    // --- 5. Execute Task ---
    try {
      final result = await task();

      // سجّل في الـ idempotency cache لمنع التكرار لمدة الـ window
      _idempotencyCache[idempotencyKey] = DateTime.now().add(idempotencyWindow);

      _log('🏁 اكتملت العملية: $idempotencyKey | token: $token');
      return MutexSuccess(value: result, fencingToken: token);
    } catch (e) {
      _log('❌ خطأ في العملية: $e');
      return MutexTaskError(e);
    } finally {
      // حرّر القفل دائماً — سواء نجح أو فشل
      _currentLock = null;
      _cleanIdempotencyCache();
    }
  }

  // Getters للعرض في الـ UI (اختياري)
  bool get isLocked => _currentLock != null && !_currentLock!.isExpired;
  int get currentFencingToken => _fencingSequence;
  String? get currentOwner => _currentLock?.ownerId;
  Duration? get remainingLease => _currentLock?.remainingLease;

  /// احذف المفاتيح المنتهية الصلاحية من الذاكرة
  void _cleanIdempotencyCache() {
    final now = DateTime.now();
    final expired = _idempotencyCache.entries
        .where((e) => now.isAfter(e.value))
        .map((e) => e.key)
        .toList();
    expired.forEach(_idempotencyCache.remove);
  }

  void _log(String msg) {
    if (kDebugMode) print('[TransferMutex] $msg');
  }
}

// -----------------------------------------------------------------------------
// IdempotencyKeyBuilder — يبني مفتاحاً فريداً لكل عملية تحويل
//
// المنطق: from + to + amount + الدقيقة الحالية
// - إذا أعاد المستخدم نفس التحويل خلال نفس الدقيقة → نعتبره مكرراً
// - إذا أعاد التحويل بعد دقيقة → نعتبره محاولة جديدة مشروعة
// -----------------------------------------------------------------------------

class IdempotencyKeyBuilder {
  static String forTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) {
    // التقسيم على 60000 يعطينا رقم الدقيقة الحالية كـ int
    final minute = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return 'transfer_${fromAccountId}_${toAccountId}_${amount}_$minute';
  }
}