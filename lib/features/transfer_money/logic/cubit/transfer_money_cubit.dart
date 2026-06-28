import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/concurrency/transfer_mutex.dart';
import '../../../../core/consistency/two_phase_commit.dart';
import '../../../../core/logging/audit_logger.dart';
import '../../../../core/security/rbac.dart';
import '../../data/models/transfer_request_model.dart';
import '../services/transfer_repo.dart';
import '../validators/transfer_approval_chain.dart';

part 'transfer_money_state.dart';
part 'transfer_money_cubit.freezed.dart';

class TransferMoneyCubit extends Cubit<TransferMoneyState> {
  final TransferRepo repo;

  final _mutex       = TransferMutex(
    leaseDuration:     const Duration(seconds: 10),
    idempotencyWindow: const Duration(seconds: 30),
  );

  late final TransferTwoPhaseCoordinator _coordinator;

  // 2PC log stream — الـ UI يستمع عليه مباشرة
  Stream<TxLogEntry> get txLogStream => _coordinator.logStream;
  Stream<TxState>    get txStateStream => _coordinator.stateStream;

  TransferMoneyCubit({required this.repo})
      : super(TransferMoneyState.ready(
          kind: TransferKind.ownAccounts,
          amountText: '',
          fromAccountId: null,
          toAccountId: null,
          note: '',
        )) {
    _coordinator = TransferTwoPhaseCoordinator();
  }

  // ── Tab & field setters ───────────────────────────────────────────────────

  void changeTab(TransferKind kind) {
    state.maybeWhen(
      ready: (k, a, from, to, n) => emit(TransferMoneyState.ready(
        kind: kind, amountText: a,
        fromAccountId: from, toAccountId: to, note: n,
      )),
      orElse: () {},
    );
  }

  void setAmount(String v)        => _updateReady(amountText: v);
  void setFromAccount(String? id) => _updateReady(fromAccountId: id);
  void setToAccount(String? id)   => _updateReady(toAccountId: id);
  void setNote(String v)          => _updateReady(note: v);

  void _updateReady({
    String? amountText, String? fromAccountId,
    String? toAccountId, String? note,
  }) {
    state.maybeWhen(
      ready: (k, a, from, to, n) => emit(TransferMoneyState.ready(
        kind: k,
        amountText:    amountText    ?? a,
        fromAccountId: fromAccountId ?? from,
        toAccountId:   toAccountId   ?? to,
        note:          note          ?? n,
      )),
      orElse: () {},
    );
  }

  // ── submit ────────────────────────────────────────────────────────────────

  Future<void> submit() async {
    final current = state;
    if (current is! _Ready) return;

    final amount = double.tryParse(current.amountText.trim()) ?? 0;

    if (current.fromAccountId == null || current.toAccountId == null) {
      emit(const TransferMoneyState.error(message: 'الرجاء اختيار الحسابات'));
      emit(current);
      return;
    }

    // ── RBAC ──────────────────────────────────────────────────────────────
    final permission = amount > 1000
        ? Permission.transferAboveLimit
        : Permission.transferOwnAccounts;

    if (!await Rbac.instance.can(permission)) {
      await AuditLogger.instance.log(
        AuditEvent.permissionDenied,
        details: {'permission': permission.name, 'amount': amount},
      );
      emit(const TransferMoneyState.error(
          message: 'ليس لديك صلاحية لإتمام هذه العملية'));
      emit(current);
      return;
    }

    // ── Idempotency key ───────────────────────────────────────────────────
    final iKey = IdempotencyKeyBuilder.forTransfer(
      fromAccountId: current.fromAccountId!,
      toAccountId:   current.toAccountId!,
      amount:        amount,
    );

    emit(const TransferMoneyState.loading());

    // ── Mutex wraps the 2PC ───────────────────────────────────────────────
    final mutexResult = await _mutex.runExclusive(
      idempotencyKey: iKey,
      task: () => _run2PC(current, amount),
    );

    switch (mutexResult) {
      case MutexSuccess<TwoPhaseResult>():
        _handle2PCResult(mutexResult.value, current);

      case MutexDuplicate<TwoPhaseResult>():
        emit(const TransferMoneyState.success(message: 'تمت العملية بنجاح'));

      case MutexLocked<TwoPhaseResult>():
        emit(const TransferMoneyState.error(
            message: 'عملية تحويل قيد التنفيذ، الرجاء الانتظار'));
        emit(current);

      case MutexFencingRejected<TwoPhaseResult>():
        emit(const TransferMoneyState.error(
            message: 'انتهت صلاحية هذه العملية'));
        emit(current);

      case MutexTaskError<TwoPhaseResult>():
        emit(TransferMoneyState.error(
            message: mutexResult.error.toString()));
        emit(current);
    }
  }

  // ── 2PC execution ─────────────────────────────────────────────────────────

  Future<TwoPhaseResult> _run2PC(_Ready current, double amount) async {
    // ApprovalChain قبل الـ 2PC
    final balance = await repo.getAccountBalance(current.fromAccountId!);
    final limit   = await repo.getRemainingDailyLimit(current.fromAccountId!);

    final ctx = ApprovalContext(
      balance:             balance,
      remainingDailyLimit: limit,
      otpVerified:         true,
      managerApproved:     amount <= 1000,
    );

    final chain   = TransferApprovalChain.build(managerThreshold: 1000);
    final request = TransferRequestModel(
      kind:          current.kind,
      fromAccountId: current.fromAccountId!,
      toAccountId:   current.toAccountId!,
      amount:        amount,
      note: current.note.trim().isEmpty ? null : current.note.trim(),
    );

    final approval = await chain.handle(request, ctx);
    if (!approval.approved) {
      throw Exception(approval.reason ?? 'Transfer rejected');
    }

    // بناء الـ participants
    final participants = _buildParticipants(request);

    // تنفيذ الـ 2PC
    return _coordinator.execute(
      transactionId: '2PC-${DateTime.now().millisecondsSinceEpoch}',
      participants:  participants,
      payload: {
        'fromAccountId': current.fromAccountId,
        'toAccountId':   current.toAccountId,
        'amount':        amount,
        'kind':          current.kind.name,
      },
    );
  }

  List<TxParticipant> _buildParticipants(TransferRequestModel request) {
    return [
      DebitParticipant(
        checkBalance: (from, amt) async {
          final bal = await repo.getAccountBalance(from);
          return bal >= amt;
        },
        debit:  (from, amt) => repo.debitAccount(from, amt),
        refund: (from, amt) => repo.creditAccount(from, amt),
      ),
      CreditParticipant(
        credit: (to, amt) => repo.creditAccount(to, amt),
        debit:  (to, amt) => repo.debitAccount(to, amt),
      ),
      AuditLogParticipant(
        logCommit: (txId, payload) async {
          await AuditLogger.instance.log(
            AuditEvent.transferApproved,
            details: {'transactionId': txId, ...payload},
          );
        },
        logRollback: (txId) async {
          await AuditLogger.instance.log(
            AuditEvent.transferFailed,
            details: {'transactionId': txId, 'reason': '2PC rollback'},
          );
        },
      ),
    ];
  }

  void _handle2PCResult(TwoPhaseResult result, _Ready current) {
    switch (result) {
      case TwoPhaseCommitted():
        emit(const TransferMoneyState.success(
            message: 'تم التحويل بنجاح'));

      case TwoPhaseAborted():
        emit(TransferMoneyState.error(
            message: 'تعذّر التحويل: ${result.reason}'));
        emit(current);

      case TwoPhaseTimeout():
        emit(const TransferMoneyState.error(
            message: 'انتهت مهلة العملية، لم يُطبَّق أي تغيير'));
        emit(current);
    }
  }

  @override
  Future<void> close() {
    _coordinator.dispose();
    return super.close();
  }
}