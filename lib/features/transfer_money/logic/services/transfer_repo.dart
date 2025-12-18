import '../../data/models/transfer_request_model.dart';
import '../../data/models/transfer_response_model.dart';

abstract class TransferRepo {
  Future<double> getAccountBalance(String accountId);
  Future<double> getRemainingDailyLimit(String accountId);

  Future<TransferResponseModel> processTransfer(TransferRequestModel request);
}
