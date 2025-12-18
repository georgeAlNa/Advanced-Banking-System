import '../models/account_model.dart';

abstract class AccountsRemoteDataSource {
  Future<List<AccountModel>> fetchAccounts();
}

class AccountsRemoteDataSourceMock implements AccountsRemoteDataSource {
  @override
  Future<List<AccountModel>> fetchAccounts() async {
    return const [
      AccountModel(
        id: '1',
        name: 'Primary Checking',
        type: AccountType.checking,
        status: AccountStatus.active,
        balance: 2500,
        parentId: null,
      ),
      AccountModel(
        id: '2',
        name: 'Savings Sub',
        type: AccountType.savings,
        status: AccountStatus.active,
        balance: 1500,
        parentId: '1',
      ),
    ];
  }
}
