import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_banking_system/features/transfer_money/data/models/transfer_request_model.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/validators/transfer_approval_chain.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/validators/handlers/limits_handler.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/validators/handlers/balance_handler.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/validators/handlers/otp_handler.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/validators/handlers/manager_approval_handler.dart';

void main() {
  group('Approval handlers', () {
    test('BalanceHandler rejects non-positive and insufficient', () async {
      final bal = BalanceHandler();
      final reqZero = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 0);
      final ctx = ApprovalContext(balance: 100, remainingDailyLimit: 1000, otpVerified: true, managerApproved: true);

      final r0 = await bal.check(reqZero, ctx);
      expect(r0.approved, isFalse);
      expect(r0.reason, 'Amount must be greater than 0');

      final reqBig = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 200);
      final r1 = await bal.check(reqBig, ctx);
      expect(r1.approved, isFalse);
      expect(r1.reason, 'Insufficient balance');

      final reqOk = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 50);
      final r2 = await bal.check(reqOk, ctx);
      expect(r2.approved, isTrue);
    });

    test('LimitsHandler rejects when over limit', () async {
      final lim = LimitsHandler();
      final ctx = ApprovalContext(balance: 1000, remainingDailyLimit: 100, otpVerified: true, managerApproved: true);
      final req = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 200);

      final r = await lim.check(req, ctx);
      expect(r.approved, isFalse);
      expect(r.reason, 'Daily limit exceeded');
    });

    test('OtpHandler enforces for otherBanks', () async {
      final otp = OtpHandler();

      final reqNoOtp = TransferRequestModel(kind: TransferKind.otherBanks, fromAccountId: 'a', toAccountId: 'b', amount: 10);
      final ctxNotVerified = ApprovalContext(balance: 100, remainingDailyLimit: 1000, otpVerified: false, managerApproved: true);

      final r1 = await otp.check(reqNoOtp, ctxNotVerified);
      // missing code
      expect(r1.approved, isFalse);
      expect(r1.reason, 'OTP is required');

      final reqWithCode = TransferRequestModel(kind: TransferKind.otherBanks, fromAccountId: 'a', toAccountId: 'b', amount: 10, otpCode: '1234');
      final r2 = await otp.check(reqWithCode, ctxNotVerified);
      expect(r2.approved, isFalse);
      expect(r2.reason, 'OTP not verified');

      final ctxVerified = ctxNotVerified.copyWith(otpVerified: true);
      final r3 = await otp.check(reqWithCode, ctxVerified);
      expect(r3.approved, isTrue);
    });

    test('ManagerApprovalHandler requires approval above threshold', () async {
      final m = ManagerApprovalHandler(threshold: 1000);

      final reqLow = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 500);
      final ctx = ApprovalContext(balance: 10000, remainingDailyLimit: 10000, otpVerified: true, managerApproved: false);
      final r1 = await m.check(reqLow, ctx);
      expect(r1.approved, isTrue);

      final reqHigh = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 2000);
      final r2 = await m.check(reqHigh, ctx);
      expect(r2.approved, isFalse);
      expect(r2.reason, 'Manager approval required');

      final ctxOk = ctx.copyWith(managerApproved: true);
      final r3 = await m.check(reqHigh, ctxOk);
      expect(r3.approved, isTrue);
    });

    test('Full chain stops at first failure', () async {
      final chain = TransferApprovalChain.build(managerThreshold: 1000);
      final ctx = ApprovalContext(balance: 100, remainingDailyLimit: 50, otpVerified: true, managerApproved: true);
      final req = TransferRequestModel(kind: TransferKind.ownAccounts, fromAccountId: 'a', toAccountId: 'b', amount: 200);

      final res = await chain.handle(req, ctx);
      expect(res.approved, isFalse);
      expect(res.reason, anyOf('Insufficient balance', 'Daily limit exceeded'));
    });
  });
}
