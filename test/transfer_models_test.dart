import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_banking_system/features/transfer_money/data/models/transfer_request_model.dart';
import 'package:advanced_banking_system/features/transfer_money/data/models/transfer_response_model.dart';

void main() {
  group('Transfer models JSON', () {
    test('TransferRequestModel toJson/fromJson roundtrip', () {
      final req = TransferRequestModel(
        kind: TransferKind.ownAccounts,
        fromAccountId: 'A',
        toAccountId: 'B',
        amount: 123.45,
        note: 'hi',
      );

      final json = req.toJson();
      final parsed = TransferRequestModel.fromJson(json);

      expect(parsed.kind, req.kind);
      expect(parsed.fromAccountId, req.fromAccountId);
      expect(parsed.toAccountId, req.toAccountId);
      expect(parsed.amount, req.amount);
      expect(parsed.note, req.note);
    });

    test('TransferResponseModel toJson/fromJson roundtrip', () {
      final res = TransferResponseModel(
        transactionId: 'tx1',
        status: 'ok',
        message: 'done',
      );

      final json = res.toJson();
      final parsed = TransferResponseModel.fromJson(json);

      expect(parsed.transactionId, res.transactionId);
      expect(parsed.status, res.status);
      expect(parsed.message, res.message);
    });
  });
}
