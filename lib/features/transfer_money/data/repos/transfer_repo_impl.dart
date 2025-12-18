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
}
