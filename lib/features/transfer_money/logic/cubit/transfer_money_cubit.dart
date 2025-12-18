import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/transfer_request_model.dart';
import '../services/transfer_repo.dart';
import '../validators/transfer_approval_chain.dart';

part 'transfer_money_state.dart';
part 'transfer_money_cubit.freezed.dart';

class TransferMoneyCubit extends Cubit<TransferMoneyState> {
  final TransferRepo repo;

  TransferMoneyCubit({required this.repo})
    : super(
        TransferMoneyState.ready(
          kind: TransferKind.ownAccounts,
          amountText: '',
          fromAccountId: null,
          toAccountId: null,
          note: '',
        ),
      );

  void changeTab(TransferKind kind) {
    state.maybeWhen(
      ready: (k, amountText, from, to, note) {
        emit(
          TransferMoneyState.ready(
            kind: kind,
            amountText: amountText,
            fromAccountId: from,
            toAccountId: to,
            note: note,
          ),
        );
      },
      orElse: () {},
    );
  }

  void setAmount(String v) => _updateReady(amountText: v);
  void setFromAccount(String? id) => _updateReady(fromAccountId: id);
  void setToAccount(String? id) => _updateReady(toAccountId: id);
  void setNote(String v) => _updateReady(note: v);

  void _updateReady({
    String? amountText,
    String? fromAccountId,
    String? toAccountId,
    String? note,
  }) {
    state.maybeWhen(
      ready: (k, a, from, to, n) {
        emit(
          TransferMoneyState.ready(
            kind: k,
            amountText: amountText ?? a,
            fromAccountId: fromAccountId ?? from,
            toAccountId: toAccountId ?? to,
            note: note ?? n,
          ),
        );
      },
      orElse: () {},
    );
  }

  Future<void> submit() async {
    final current = state;
    if (current is! _Ready) return;

    final amount = double.tryParse(current.amountText.trim()) ?? 0;

    if (current.fromAccountId == null || current.toAccountId == null) {
      emit(const TransferMoneyState.error(message: 'Please select accounts'));
      emit(current);
      return;
    }

    emit(const TransferMoneyState.loading());

    try {
      // 1) gather context
      final balance = await repo.getAccountBalance(current.fromAccountId!);
      final limit = await repo.getRemainingDailyLimit(current.fromAccountId!);

      final ctx = ApprovalContext(
        balance: balance,
        remainingDailyLimit: limit,
        otpVerified: true,
        managerApproved: amount <= 1000,
      );

      // 2) build chain
      final chain = TransferApprovalChain.build(managerThreshold: 1000);

      // 3) validate/approve
      final request = TransferRequestModel(
        kind: current.kind,
        fromAccountId: current.fromAccountId!,
        toAccountId: current.toAccountId!,
        amount: amount,
        note: current.note.trim().isEmpty ? null : current.note.trim(),
      );

      final approval = await chain.handle(request, ctx);
      if (!approval.approved) {
        emit(TransferMoneyState.error(message: approval.reason ?? 'Rejected'));
        emit(current);
        return;
      }

      // 4) execute
      final result = await repo.processTransfer(request);
      emit(TransferMoneyState.success(message: result.message));
    } catch (e) {
      emit(TransferMoneyState.error(message: e.toString()));
      emit(current);
    }
  }
}
