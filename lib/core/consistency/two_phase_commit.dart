import 'dart:async';
import 'package:flutter/foundation.dart';

// =============================================================================
// TASK — Two-Phase Commit (2PC) Distributed Transaction Coordinator
// المسار: lib/core/consistency/two_phase_commit.dart
//
// المشكلة التي يحلها:
//   عملية التحويل المالي تتضمن خطوتين على السيرفر:
//     الخطوة 1: خصم المبلغ من حساب المُرسل
//     الخطوة 2: إضافة المبلغ لحساب المستقبل
//
//   إذا انهار السيرفر بين الخطوتين:
//     ✅ تم الخصم من حساب A
//     💥 لم تتم الإضافة لحساب B
//     النتيجة: المال ضاع دون أثر
//
// الحل — مرحلتان:
//
//   Phase 1 (Prepare/Vote):
//     كل مشارك يحجز الموارد المطلوبة ويصوّت COMMIT أو ABORT.
//     إذا صوّت أي مشارك ABORT، تُلغى العملية بالكامل.
//
//   Phase 2 (Commit أو Rollback):
//     إذا كل الأصوات COMMIT → نُنفِّذ بالترتيب
//     إذا أي صوت ABORT     → نتراجع عن كل من حضّر بالترتيب المعكوس
//
// المشاركون في التحويل:
//   DebitParticipant  → يخصم من حساب المُرسل
//   CreditParticipant → يضيف لحساب المستقبل
//   AuditLogParticipant → يسجل العملية
//
// الاتصال بالـ UI:
//   يبث stream من الـ logs والحالات للـ TransactionLogPanel
// =============================================================================

// -----------------------------------------------------------------------------
// TxState — حالات العملية (تُبث للـ UI عبر stateStream)
// -----------------------------------------------------------------------------

enum TxState {
  idle,        // لم تبدأ
  preparing,   // Phase 1: إرسال طلبات التحضير
  voting,      // Phase 1: جمع الأصوات
  committing,  // Phase 2: تنفيذ العمليات (كل الأصوات COMMIT)
  rollingBack, // Phase 2: التراجع (أحد صوّت ABORT)
  committed,   // اكتملت بنجاح ✅
  aborted,     // أُلغيت ❌
}

enum Vote { commit, abort }

// -----------------------------------------------------------------------------
// TwoPhaseResult — نتيجة العملية (sealed = exhaustive switch في الـ Cubit)
// -----------------------------------------------------------------------------

sealed class TwoPhaseResult {
  const TwoPhaseResult();
}

/// العملية اكتملت بنجاح — كل المشاركين نفّذوا
class TwoPhaseCommitted extends TwoPhaseResult {
  final String transactionId;
  final List<String> participantIds; // مَن نفّذ
  const TwoPhaseCommitted({
    required this.transactionId,
    required this.participantIds,
  });
}

/// العملية أُلغيت — تم التراجع عن كل العمليات المُنجزة
class TwoPhaseAborted extends TwoPhaseResult {
  final String transactionId;
  final String vetoedBy;        // مَن صوّت ABORT
  final String reason;
  final List<String> rolledBackIds; // مَن تراجع بنجاح
  const TwoPhaseAborted({
    required this.transactionId,
    required this.vetoedBy,
    required this.reason,
    required this.rolledBackIds,
  });
}

/// انتهت المهلة لأحد المشاركين — تم التراجع تلقائياً
class TwoPhaseTimeout extends TwoPhaseResult {
  final String transactionId;
  final String participantId; // مَن تأخر
  const TwoPhaseTimeout({
    required this.transactionId,
    required this.participantId,
  });
}

// -----------------------------------------------------------------------------
// TxParticipant — الواجهة التي يجب أن يُطبّقها كل مشارك
//
// كل مشارك مسؤول عن:
//   prepare() → حجز الموارد والتصويت
//   commit()  → تنفيذ العملية الفعلية
//   rollback() → التراجع عن ما حُجز
// -----------------------------------------------------------------------------

abstract class TxParticipant {
  String get id;

  /// Phase 1: احجز الموارد وصوّت COMMIT أو ABORT
  Future<Vote> prepare(String transactionId, Map<String, dynamic> payload);

  /// Phase 2A: نفّذ العملية بعد تأكيد كل الأصوات
  Future<void> commit(String transactionId);

  /// Phase 2B: تراجع عن الحجز إذا أُلغيت العملية
  Future<void> rollback(String transactionId);
}

// -----------------------------------------------------------------------------
// TxLogEntry — رسائل اللوغ للعرض في الـ UI (TransactionLogPanel)
// -----------------------------------------------------------------------------

enum TxLogLevel { info, success, error }

class TxLogEntry {
  final String transactionId;
  final String message;
  final TxLogLevel level;
  final DateTime timestamp;

  TxLogEntry._({
    required this.transactionId,
    required this.message,
    required this.level,
  }) : timestamp = DateTime.now();

  factory TxLogEntry.info(String txId, String msg) =>
      TxLogEntry._(transactionId: txId, message: msg, level: TxLogLevel.info);

  factory TxLogEntry.success(String txId, String msg) =>
      TxLogEntry._(transactionId: txId, message: msg, level: TxLogLevel.success);

  factory TxLogEntry.error(String txId, String msg) =>
      TxLogEntry._(transactionId: txId, message: msg, level: TxLogLevel.error);
}

// -----------------------------------------------------------------------------
// TransferTwoPhaseCoordinator — المنسّق الرئيسي
// -----------------------------------------------------------------------------

class TransferTwoPhaseCoordinator {
  final Duration prepareTimeout; // أقصى وقت لكل prepare
  final Duration commitTimeout;  // أقصى وقت لكل commit/rollback

  TransferTwoPhaseCoordinator({
    this.prepareTimeout = const Duration(seconds: 5),
    this.commitTimeout = const Duration(seconds: 8),
  });

  // Streams للـ UI — TransactionLogPanel يستمع عليهم
  final _logController = StreamController<TxLogEntry>.broadcast();
  Stream<TxLogEntry> get logStream => _logController.stream;

  final _stateController = StreamController<TxState>.broadcast();
  Stream<TxState> get stateStream => _stateController.stream;

  TxState _state = TxState.idle;
  TxState get currentState => _state;

  /// نفّذ عملية 2PC كاملة
  Future<TwoPhaseResult> execute({
    required String transactionId,
    required List<TxParticipant> participants,
    required Map<String, dynamic> payload,
  }) async {
    _setState(TxState.preparing);
    _addLog(TxLogEntry.info(
      transactionId,
      '🚀 Phase 1 START — إرسال PREPARE لـ ${participants.length} مشاركين',
    ));

    // =========================================================================
    // PHASE 1: Prepare & Vote
    // =========================================================================
    _setState(TxState.voting);

    final preparedIds = <String>[];
    String? vetoedBy;
    String? vetoReason;

    for (final p in participants) {
      try {
        _addLog(TxLogEntry.info(transactionId, '📋 ${p.id} — جاري التحضير...'));

        final vote = await p.prepare(transactionId, payload).timeout(prepareTimeout);

        if (vote == Vote.commit) {
          preparedIds.add(p.id);
          _addLog(TxLogEntry.success(transactionId, '✅ ${p.id} صوّت COMMIT'));
        } else {
          // أي صوت ABORT يوقف Phase 1 فوراً
          vetoedBy = p.id;
          vetoReason = '${p.id} صوّت ABORT';
          _addLog(TxLogEntry.error(transactionId, '❌ ${p.id} صوّت ABORT'));
          break;
        }
      } on TimeoutException {
        // انتهت المهلة — نتراجع فوراً
        vetoedBy = p.id;
        vetoReason = '${p.id} تجاوز المهلة';
        _addLog(TxLogEntry.error(transactionId, '⏰ ${p.id} TIMEOUT'));
        _setState(TxState.rollingBack);
        await _rollbackAll(transactionId, participants, preparedIds);
        _setState(TxState.aborted);
        return TwoPhaseTimeout(
          transactionId: transactionId,
          participantId: p.id,
        );
      } catch (e) {
        vetoedBy = p.id;
        vetoReason = '${p.id} رمى خطأ: $e';
        _addLog(TxLogEntry.error(transactionId, '💥 ${p.id} خطأ: $e'));
        break;
      }
    }

    // =========================================================================
    // PHASE 2A: Global Abort — أحد المشاركين رفض
    // =========================================================================
    if (vetoedBy != null) {
      _addLog(TxLogEntry.error(
        transactionId,
        '🔴 Phase 2: GLOBAL ABORT — بسبب $vetoedBy',
      ));
      _setState(TxState.rollingBack);

      // تراجع بالترتيب المعكوس — آخر من حضّر أول من يتراجع
      final rolledBack = await _rollbackAll(transactionId, participants, preparedIds);

      _setState(TxState.aborted);
      return TwoPhaseAborted(
        transactionId: transactionId,
        vetoedBy: vetoedBy,
        reason: vetoReason ?? 'Unknown',
        rolledBackIds: rolledBack,
      );
    }

    // =========================================================================
    // PHASE 2B: Global Commit — كل المشاركين وافقوا
    // =========================================================================
    _addLog(TxLogEntry.success(
      transactionId,
      '🟢 Phase 2: GLOBAL COMMIT — ${participants.length} مشاركون وافقوا',
    ));
    _setState(TxState.committing);

    for (final p in participants) {
      try {
        await p.commit(transactionId).timeout(commitTimeout);
        _addLog(TxLogEntry.success(transactionId, '💾 ${p.id} نفّذ بنجاح'));
      } catch (e) {
        // فشل في مرحلة commit بعد الموافقة — الحالة الأسوأ في 2PC
        // في production يحتاج recovery log — هنا نسجله كـ critical
        _addLog(TxLogEntry.error(
          transactionId,
          '🚨 CRITICAL: ${p.id} فشل أثناء commit: $e',
        ));
      }
    }

    _setState(TxState.committed);
    _addLog(TxLogEntry.success(
      transactionId,
      '🏁 العملية $transactionId اكتملت بنجاح',
    ));

    return TwoPhaseCommitted(
      transactionId: transactionId,
      participantIds: participants.map((p) => p.id).toList(),
    );
  }

  /// تراجع عن كل المشاركين الذين حضّروا، بالترتيب المعكوس
  Future<List<String>> _rollbackAll(
    String transactionId,
    List<TxParticipant> all,
    List<String> preparedIds,
  ) async {
    final rolledBack = <String>[];

    // عكس الترتيب: آخر من حضّر أول من يتراجع
    final toRollback = all
        .where((p) => preparedIds.contains(p.id))
        .toList()
        .reversed;

    for (final p in toRollback) {
      try {
        await p.rollback(transactionId).timeout(commitTimeout);
        rolledBack.add(p.id);
        _addLog(TxLogEntry.info(transactionId, '↩️ ${p.id} تراجع بنجاح'));
      } catch (e) {
        _addLog(TxLogEntry.error(
          transactionId, '🚨 ${p.id} فشل في التراجع: $e',
        ));
      }
    }

    return rolledBack;
  }

  void _setState(TxState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
    if (kDebugMode) print('[2PC] الحالة → ${s.name}');
  }

  void _addLog(TxLogEntry entry) {
    if (!_logController.isClosed) _logController.add(entry);
    if (kDebugMode) print('[2PC] ${entry.message}');
  }

  void dispose() {
    _logController.close();
    _stateController.close();
  }
}

// -----------------------------------------------------------------------------
// Concrete Participants — التطبيقات الفعلية لمشروع البنك
// -----------------------------------------------------------------------------

/// يخصم المبلغ من حساب المُرسل
/// prepare: يتحقق من الرصيد ويصوّت بناءً على الكفاية
/// commit:  ينفذ الخصم الفعلي
/// rollback: يُعيد المبلغ إذا أُلغيت العملية
class DebitParticipant implements TxParticipant {
  @override
  final String id = 'debit-participant';

  final Future<bool> Function(String fromAccount, double amount) checkBalance;
  final Future<void> Function(String fromAccount, double amount) debit;
  final Future<void> Function(String fromAccount, double amount) refund;

  DebitParticipant({
    required this.checkBalance,
    required this.debit,
    required this.refund,
  });

  String? _fromAccount;
  double? _amount;

  @override
  Future<Vote> prepare(String txId, Map<String, dynamic> payload) async {
    _fromAccount = payload['fromAccountId'] as String;
    _amount = (payload['amount'] as num).toDouble();
    final sufficient = await checkBalance(_fromAccount!, _amount!);
    return sufficient ? Vote.commit : Vote.abort;
  }

  @override
  Future<void> commit(String txId) => debit(_fromAccount!, _amount!);

  @override
  Future<void> rollback(String txId) async {
    if (_fromAccount != null && _amount != null) {
      await refund(_fromAccount!, _amount!);
    }
  }
}

/// يضيف المبلغ لحساب المستقبل
/// prepare: يصوّت COMMIT دائماً (الإضافة لا تفشل)
/// commit:  ينفذ الإضافة الفعلية
/// rollback: يخصم المبلغ إذا أُلغيت العملية بعد الإضافة
class CreditParticipant implements TxParticipant {
  @override
  final String id = 'credit-participant';

  final Future<void> Function(String toAccount, double amount) credit;
  final Future<void> Function(String toAccount, double amount) debit;

  CreditParticipant({required this.credit, required this.debit});

  String? _toAccount;
  double? _amount;

  @override
  Future<Vote> prepare(String txId, Map<String, dynamic> payload) async {
    _toAccount = payload['toAccountId'] as String;
    _amount = (payload['amount'] as num).toDouble();
    return Vote.commit; // الإضافة لحساب دائماً ممكنة
  }

  @override
  Future<void> commit(String txId) => credit(_toAccount!, _amount!);

  @override
  Future<void> rollback(String txId) async {
    if (_toAccount != null && _amount != null) {
      await debit(_toAccount!, _amount!);
    }
  }
}

/// يسجل العملية في الـ AuditLogger
/// prepare: يصوّت COMMIT دائماً (التسجيل لا يمنع العملية)
/// commit:  يسجل نجاح العملية
/// rollback: يسجل إلغاء العملية
class AuditLogParticipant implements TxParticipant {
  @override
  final String id = 'audit-participant';

  final Future<void> Function(String txId, Map<String, dynamic> payload) logCommit;
  final Future<void> Function(String txId) logRollback;

  AuditLogParticipant({required this.logCommit, required this.logRollback});

  Map<String, dynamic>? _payload;

  @override
  Future<Vote> prepare(String txId, Map<String, dynamic> payload) async {
    _payload = payload;
    return Vote.commit;
  }

  @override
  Future<void> commit(String txId) => logCommit(txId, _payload ?? {});

  @override
  Future<void> rollback(String txId) => logRollback(txId);
}