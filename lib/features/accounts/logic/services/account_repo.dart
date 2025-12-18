import '../../data/models/account_model.dart';

abstract class AccountRepo {
  Future<List<AccountModel>> fetchAccounts();
}
