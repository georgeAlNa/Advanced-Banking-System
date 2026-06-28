 
// ─────────────────────────────────────────────────────────────────────────────
// FILE 4: audit_logger.dart
//
// يسجل كل عملية حساسة مع: هوية المستخدم، الوقت، التفاصيل، مستوى الخطورة.
// يعمل في الذاكرة (آخر 100 entry) ويطبع في debug mode.
// قابل للتوسيع لاحقاً لحفظ في قاعدة بيانات محلية.
// ─────────────────────────────────────────────────────────────────────────────
 
import 'dart:collection';

import 'package:advanced_banking_system/core/security/jwt_service.dart';
import 'package:advanced_banking_system/core/security/secure_storage.dart';
import 'package:flutter/foundation.dart';

enum AuditEvent {
  loginSuccess,
  loginFailed,
  loginExpiredToken,
  logoutSuccess,
  transferInitiated,
  transferApproved,
  transferRejected,
  transferFailed,
  permissionDenied,  // الأهم — يُسجل كـ critical
  tokenExpired,
  tokenRefreshed,
  suspiciousActivity, // Fencing token مرفوض أو طلب مشبوه
}
 
class AuditEntry {
  final String id;
  final AuditEvent event;
  final DateTime timestamp;
  final String? userId;
  final String? userRole;
  final Map<String, dynamic>? details;
  final AuditSeverity severity;
 
  const AuditEntry({
    required this.id,
    required this.event,
    required this.timestamp,
    required this.severity,
    this.userId,
    this.userRole,
    this.details,
  });
 
  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] '
      '[${severity.name.toUpperCase()}] '
      '${event.name}'
      '${userId != null ? " user=$userId" : ""}'
      '${details != null ? " $details" : ""}';
}
 
enum AuditSeverity { info, warning, critical }
 
/// ربط كل حدث بمستوى خطورته
const _severityMap = <AuditEvent, AuditSeverity>{
  AuditEvent.loginSuccess:       AuditSeverity.info,
  AuditEvent.loginFailed:        AuditSeverity.warning,
  AuditEvent.loginExpiredToken:  AuditSeverity.warning,
  AuditEvent.logoutSuccess:      AuditSeverity.info,
  AuditEvent.transferInitiated:  AuditSeverity.info,
  AuditEvent.transferApproved:   AuditSeverity.info,
  AuditEvent.transferRejected:   AuditSeverity.warning,
  AuditEvent.transferFailed:     AuditSeverity.warning,
  AuditEvent.permissionDenied:   AuditSeverity.critical,
  AuditEvent.tokenExpired:       AuditSeverity.warning,
  AuditEvent.tokenRefreshed:     AuditSeverity.info,
  AuditEvent.suspiciousActivity: AuditSeverity.critical,
};
 
class AuditLogger {
  AuditLogger._();
  static final AuditLogger instance = AuditLogger._();
 
  final _jwt = JwtService.instance;
  final _storage = SecureStorage.instance;
 
  // Queue بدل List لأنها أسرع في الإضافة والحذف من الطرفين
  final _log = Queue<AuditEntry>();
  static const _maxEntries = 100;
  int _counter = 0;
 
  /// سجّل حدثاً مع استخراج هوية المستخدم تلقائياً من التوكن
  Future<void> log(
    AuditEvent event, {
    Map<String, dynamic>? details,
    String? overrideUserId, // للحالات التي لا يوجد فيها توكن (مثل loginFailed)
  }) async {
    String? userId = overrideUserId;
    String? userRole;
 
    // استخرج هوية المستخدم من التوكن إذا لم تُحدَّد يدوياً
    if (userId == null) {
      final token = await _storage.readToken();
      if (token != null) {
        final claims = _jwt.decode(token);
        userId = claims?.sub;
        userRole = claims?.role;
      }
    }
 
    final entry = AuditEntry(
      id: '${++_counter}',
      event: event,
      timestamp: DateTime.now(),
      userId: userId,
      userRole: userRole,
      details: details,
      severity: _severityMap[event] ?? AuditSeverity.info,
    );
 
    // أضف للـ queue وأزل الأقدم إذا امتلأت
    _log.addLast(entry);
    if (_log.length > _maxEntries) _log.removeFirst();
 
    if (kDebugMode) _printEntry(entry);
  }
 
  // --- Queries ---
  List<AuditEntry> get entries => _log.toList().reversed.toList();
  List<AuditEntry> entriesBy(AuditSeverity severity) =>
      entries.where((e) => e.severity == severity).toList();
  List<AuditEntry> entriesForUser(String userId) =>
      entries.where((e) => e.userId == userId).toList();
  void clear() => _log.clear();
 
  void _printEntry(AuditEntry e) {
    final icon = switch (e.severity) {
      AuditSeverity.info     => 'ℹ️',
      AuditSeverity.warning  => '⚠️',
      AuditSeverity.critical => '🚨',
    };
    print('$icon [AUDIT] $e');
  }
}
 