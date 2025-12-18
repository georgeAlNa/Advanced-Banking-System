import '../../../data/models/transfer_request_model.dart';
import '../transfer_approval_chain.dart';

class OtpHandler extends ApprovalHandler {
  @override
  Future<ApprovalResult> check(TransferRequestModel request, ApprovalContext ctx) async {
    final needsOtp = request.kind == TransferKind.otherBanks;

    if (!needsOtp) return const ApprovalResult.approved();

    if (request.otpCode == null || request.otpCode!.trim().isEmpty) {
      return const ApprovalResult.rejected('OTP is required');
    }

    if (!ctx.otpVerified) {
      return const ApprovalResult.rejected('OTP not verified');
    }

    return const ApprovalResult.approved();
  }
}
