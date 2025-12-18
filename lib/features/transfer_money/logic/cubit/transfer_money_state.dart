part of 'transfer_money_cubit.dart';

@freezed
class TransferMoneyState with _$TransferMoneyState {
  const factory TransferMoneyState.initial() = _Initial;
  const factory TransferMoneyState.loading() = _Loading;

  const factory TransferMoneyState.ready({
    required TransferKind kind,
    required String amountText,
    required String? fromAccountId,
    required String? toAccountId,
    required String note,
  }) = _Ready;

  const factory TransferMoneyState.success({required String message}) = _Success;
  const factory TransferMoneyState.error({required String message}) = _Error;
}
