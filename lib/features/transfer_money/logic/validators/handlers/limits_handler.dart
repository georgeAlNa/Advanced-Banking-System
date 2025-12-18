import '../../../data/models/transfer_request_model.dart';
import '../transfer_approval_chain.dart';

class LimitsHandler extends ApprovalHandler {
  @override
  Future<ApprovalResult> check(TransferRequestModel request, ApprovalContext ctx) async {
    if (request.amount > ctx.remainingDailyLimit) {
      return const ApprovalResult.rejected('Daily limit exceeded');
    }
    return const ApprovalResult.approved();
  }
}
