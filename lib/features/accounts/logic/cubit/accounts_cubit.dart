import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/account_repo.dart';
import '../services/account_tree_composite.dart';

part 'accounts_state.dart';
part 'accounts_cubit.freezed.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountRepo repo;
  AccountTreeBuilder? treeBuilder;

  AccountsCubit({required this.repo, AccountTreeBuilder? treeBuilder})
    : treeBuilder = treeBuilder ?? AccountTreeBuilder(),
      super(AccountsState.initial());

  Future<void> loadAccounts() async {
    emit(const AccountsState.loading());
    try {
      final models = await repo.fetchAccounts();
      final roots = treeBuilder?.buildForest(models) ?? [];
      emit(AccountsState.success(roots: roots));
    } catch (e) {
      emit(AccountsState.error(message: e.toString()));
    }
  }
}
