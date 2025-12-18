import '../../data/models/transfer_request_model.dart';
import 'handlers/balance_handler.dart';
import 'handlers/limits_handler.dart';
import 'handlers/otp_handler.dart';
import 'handlers/manager_approval_handler.dart';

class ApprovalContext {
  final double balance;
  final double remainingDailyLimit;
  final bool otpVerified;
  final bool managerApproved;

  const ApprovalContext({
    required this.balance,
    required this.remainingDailyLimit,
    required this.otpVerified,
    required this.managerApproved,
  });

  ApprovalContext copyWith({
    double? balance,
    double? remainingDailyLimit,
    bool? otpVerified,
    bool? managerApproved,
  }) {
    return ApprovalContext(
      balance: balance ?? this.balance,
      remainingDailyLimit: remainingDailyLimit ?? this.remainingDailyLimit,
      otpVerified: otpVerified ?? this.otpVerified,
      managerApproved: managerApproved ?? this.managerApproved,
    );
  }
}

class ApprovalResult {
  final bool approved;
  final String? reason;

  const ApprovalResult._(this.approved, this.reason);

  const ApprovalResult.approved() : this._(true, null);
  const ApprovalResult.rejected(String reason) : this._(false, reason);
}

abstract class ApprovalHandler {
  ApprovalHandler? _next;

  ApprovalHandler setNext(ApprovalHandler next) {
    _next = next;
    return next;
  }

  Future<ApprovalResult> handle(
    TransferRequestModel request,
    ApprovalContext ctx,
  ) async {
    final res = await check(request, ctx);
    if (!res.approved) return res;
    if (_next == null) return const ApprovalResult.approved();
    return _next!.handle(request, ctx);
  }

  Future<ApprovalResult> check(
    TransferRequestModel request,
    ApprovalContext ctx,
  );
}

class TransferApprovalChain {
  static ApprovalHandler build({required double managerThreshold}) {
    final balance = BalanceHandler();
    final limit = LimitsHandler();
    final otp = OtpHandler();
    final manager = ManagerApprovalHandler(threshold: managerThreshold);

    balance
      ..setNext(limit)
      ..setNext(otp)
      ..setNext(manager);

    return balance;
  }
}
