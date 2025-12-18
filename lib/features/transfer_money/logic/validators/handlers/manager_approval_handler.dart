import '../../../data/models/transfer_request_model.dart';
import '../transfer_approval_chain.dart';

class ManagerApprovalHandler extends ApprovalHandler {
  final double threshold;

  ManagerApprovalHandler({required this.threshold});

  @override
  Future<ApprovalResult> check(TransferRequestModel request, ApprovalContext ctx) async {
    if (request.amount <= threshold) return const ApprovalResult.approved();

    if (!ctx.managerApproved) {
      return const ApprovalResult.rejected('Manager approval required');
    }

    return const ApprovalResult.approved();
  }
}
