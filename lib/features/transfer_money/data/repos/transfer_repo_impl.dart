import '../../logic/services/transfer_repo.dart';
import '../datasources/transfer_remote_data_source.dart';
import '../models/transfer_request_model.dart';
import '../models/transfer_response_model.dart';

class TransferRepoImpl implements TransferRepo {
  final TransferRemoteDataSource remote;

  TransferRepoImpl({required this.remote});

  @override
  Future<double> getAccountBalance(String accountId) =>
      remote.getAccountBalance(accountId);

  @override
  Future<double> getRemainingDailyLimit(String accountId) =>
      remote.getRemainingDailyLimit(accountId);

  @override
  Future<TransferResponseModel> processTransfer(TransferRequestModel request) =>
      remote.processTransfer(request);

  // ── 2PC methods ───────────────────────────────────────────────────────────

  @override
  Future<void> debitAccount(String accountId, double amount) =>
      remote.debitAccount(accountId, amount);

  @override
  Future<void> creditAccount(String accountId, double amount) =>
      remote.creditAccount(accountId, amount);
}