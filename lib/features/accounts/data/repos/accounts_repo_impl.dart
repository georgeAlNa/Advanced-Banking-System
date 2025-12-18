import '../../logic/services/account_repo.dart';
import '../datasources/accounts_remote_data_source.dart';
import '../models/account_model.dart';

class AccountRepoImpl implements AccountRepo {
  final AccountsRemoteDataSource remote;

  AccountRepoImpl({required this.remote});

  @override
  Future<List<AccountModel>> fetchAccounts() => remote.fetchAccounts();
}
