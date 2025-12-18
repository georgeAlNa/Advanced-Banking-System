import '../models/transfer_request_model.dart';
import '../models/transfer_response_model.dart';

abstract class TransferRemoteDataSource {
  Future<double> getAccountBalance(String accountId);
  Future<double> getRemainingDailyLimit(String accountId);

  Future<TransferResponseModel> processTransfer(TransferRequestModel request);
}

class TransferRemoteDataSourceMock implements TransferRemoteDataSource {
  @override
  Future<double> getAccountBalance(String accountId) async => 5000;

  @override
  Future<double> getRemainingDailyLimit(String accountId) async => 2000;

  @override
  Future<TransferResponseModel> processTransfer(
    TransferRequestModel request,
  ) async {
    return const TransferResponseModel(
      transactionId: 'TX-1001',
      status: 'success',
      message: 'Transfer completed successfully',
    );
  }
}
