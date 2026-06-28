// =============================================================================
// TASK — Decentralized JWT Token Verification + RBAC + Secure Storage
// المسارات:
//   lib/core/security/jwt_service.dart
//   lib/core/security/rbac.dart
//   lib/core/security/secure_storage.dart
//   lib/core/logging/audit_logger.dart
//
// المشكلة التي تحلها هذه الملفات مجتمعةً:
//
//   1. التوكن كان يُحفظ في SharedPreferences — نص عادي مكشوف للقراءة
//   2. لم يكن هناك تحقق من صلاحية التوكن قبل استخدامه
//   3. لم يكن هناك نظام صلاحيات — أي مستخدم يمكنه تحويل أي مبلغ
//   4. لم تكن العمليات الحساسة مُسجَّلة في أي مكان
//
// الحل:
//   JwtService    → يفك تشفير التوكن ويتحقق من صلاحيته محلياً (بدون round-trip)
//   SecureStorage → يحفظ التوكن في Keychain/Keystore (مشفر)
//   Rbac          → يتحقق من صلاحيات المستخدم بناءً على الـ role في التوكن
//   AuditLogger   → يسجل كل عملية حساسة مع هوية المستخدم
// =============================================================================
 
// ─────────────────────────────────────────────────────────────────────────────
// FILE 1: jwt_service.dart
// ─────────────────────────────────────────────────────────────────────────────
 
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
 
// -----------------------------------------------------------------------------
// JwtClaims — البيانات المستخرجة من التوكن بعد فك التشفير
// -----------------------------------------------------------------------------
 
class JwtClaims {
  final String? sub;        // معرف المستخدم
  final String? email;
  final String? role;       // الدور (customer, teller, manager, admin)
  final DateTime? issuedAt; // وقت الإصدار
  final DateTime? expiresAt;
  final Map<String, dynamic> raw; // البيانات الكاملة كاملة
 
  const JwtClaims({
    required this.sub,
    required this.email,
    required this.role,
    required this.issuedAt,
    required this.expiresAt,
    required this.raw,
  });
 
  /// هل التوكن منتهي الصلاحية؟
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
 
  /// كم وقت متبقٍ قبل انتهاء الصلاحية؟
  Duration? get remainingValidity {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
 
  @override
  String toString() => 'JwtClaims(sub: $sub, role: $role, '
      'expires: $expiresAt, isExpired: $isExpired)';
}
 
// -----------------------------------------------------------------------------
// JwtVerifyResult — نتيجة التحقق (sealed = exhaustive switch)
// -----------------------------------------------------------------------------
 
sealed class JwtVerifyResult {
  const JwtVerifyResult();
}
 
/// التوكن صالح
class JwtValid extends JwtVerifyResult {
  final JwtClaims claims;
  const JwtValid(this.claims);
}
 
/// التوكن منتهي الصلاحية
/// نُرجع الـ claims حتى مع الانتهاء لاستخدامها في الـ logging
class JwtExpired extends JwtVerifyResult {
  final JwtClaims claims;
  final DateTime expiredAt;
  const JwtExpired({required this.claims, required this.expiredAt});
}
 
/// التوكن مشوه أو غير قابل للقراءة
class JwtMalformed extends JwtVerifyResult {
  final String reason;
  const JwtMalformed(this.reason);
}
 
// -----------------------------------------------------------------------------
// JwtService — يفك تشفير JWT ويتحقق محلياً دون الحاجة لاستدعاء السيرفر
//
// لماذا محلياً؟
//   - أسرع: لا round-trip للسيرفر
//   - أكثر أماناً: لا نُرسل التوكن لطرف ثالث للتحقق
//   - يعمل offline: يمكن التحقق من الصلاحية حتى بدون إنترنت
//
// ملاحظة: التحقق من التوقيع (signature) يتم على السيرفر عند كل طلب.
//   ما نتحقق منه هنا هو الـ claims والصلاحية الزمنية فقط.
// -----------------------------------------------------------------------------
 
class JwtService {
  JwtService._();
  static final JwtService instance = JwtService._();
 
  /// تحقق من التوكن وأرجع النتيجة
  JwtVerifyResult verify(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return const JwtMalformed('التوكن يجب أن يحتوي على 3 أجزاء (header.payload.signature)');
      }
 
      final payload = _decodeSegment(parts[1]);
      final claims = _parseClaims(payload);
 
      if (claims.isExpired) {
        return JwtExpired(
          claims: claims,
          expiredAt: claims.expiresAt!,
        );
      }
 
      return JwtValid(claims);
    } catch (e) {
      return JwtMalformed('فشل في تحليل التوكن: $e');
    }
  }
 
  /// فك تشفير التوكن بدون تحقق من الصلاحية (للعرض فقط)
  JwtClaims? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = _decodeSegment(parts[1]);
      return _parseClaims(payload);
    } catch (_) {
      return null;
    }
  }
 
  /// فك تشفير الـ header فقط (لمعرفة الخوارزمية)
  Map<String, dynamic>? decodeHeader(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      return _decodeSegment(parts[0]);
    } catch (_) {
      return null;
    }
  }
 
  // JWT يستخدم Base64Url (بدون padding) — نُضيف الـ padding يدوياً
  Map<String, dynamic> _decodeSegment(String segment) {
    final normalized = segment
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    final padded = normalized.padRight(
      normalized.length + (4 - normalized.length % 4) % 4,
      '=',
    );
    final decoded = utf8.decode(base64.decode(padded));
    return json.decode(decoded) as Map<String, dynamic>;
  }
 
  JwtClaims _parseClaims(Map<String, dynamic> payload) {
    DateTime? parseEpoch(dynamic v) {
      if (v == null) return null;
      // JWT يخزن الوقت كـ Unix timestamp (ثوانٍ) — نحوله لـ milliseconds
      return DateTime.fromMillisecondsSinceEpoch((v as int) * 1000);
    }
 
    return JwtClaims(
      sub: payload['sub']?.toString(),
      email: payload['email']?.toString(),
      role: payload['role']?.toString(),
      issuedAt: parseEpoch(payload['iat']),
      expiresAt: parseEpoch(payload['exp']),
      raw: payload,
    );
  }
}
 