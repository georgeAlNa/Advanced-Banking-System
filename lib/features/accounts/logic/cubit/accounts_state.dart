part of 'accounts_cubit.dart';

@freezed
class AccountsState with _$AccountsState {
  const factory AccountsState.initial() = _Initial;
  const factory AccountsState.loading() = Loading;

  const factory AccountsState.success({required List<AccountComponent> roots}) =
      Success;

  const factory AccountsState.error({required String message}) = Error;
}
