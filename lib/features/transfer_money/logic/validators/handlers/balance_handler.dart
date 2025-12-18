import '../../../data/models/transfer_request_model.dart';
import '../transfer_approval_chain.dart';

class BalanceHandler extends ApprovalHandler {
  @override
  Future<ApprovalResult> check(TransferRequestModel request, ApprovalContext ctx) async {
    if (request.amount <= 0) {
      return const ApprovalResult.rejected('Amount must be greater than 0');
    }
    if (ctx.balance < request.amount) {
      return const ApprovalResult.rejected('Insufficient balance');
    }
    return const ApprovalResult.approved();
  }
}
