import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/services/transfer_repo.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/cubit/transfer_money_cubit.dart';
import 'package:advanced_banking_system/features/transfer_money/data/models/transfer_response_model.dart';
import 'package:advanced_banking_system/features/transfer_money/data/models/transfer_request_model.dart';

class _MockRepo extends Mock implements TransferRepo {}

class _FakeRequest extends Fake implements TransferRequestModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequest());
  });

  group('TransferMoneyCubit', () {
    test('submit without accounts emits error and restores ready state', () async {
      final repo = _MockRepo();
      final cubit = TransferMoneyCubit(repo: repo);

      // collect emitted states
      final emitted = <dynamic>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.setAmount('10');

      await cubit.submit();
      await Future<void>.delayed(Duration.zero);

      // should have emitted an error then restored the ready state
      expect(emitted.any((s) => s.toString().contains('error')), isTrue);
      expect(cubit.state.toString().contains('ready'), isTrue);

      await sub.cancel();
    });

    test('successful transfer leads to success state', () async {
      final repo = _MockRepo();

      when(() => repo.getAccountBalance(any())).thenAnswer((_) async => 5000);
      when(() => repo.getRemainingDailyLimit(any())).thenAnswer((_) async => 2000);
      when(() => repo.processTransfer(any())).thenAnswer((_) async => TransferResponseModel(transactionId: 't1', status: 'ok', message: 'done'));

      final cubit = TransferMoneyCubit(repo: repo);
      cubit.setFromAccount('A');
      cubit.setToAccount('B');
      cubit.setAmount('100');

      await cubit.submit();

      // final state should be success with message 'done'
      cubit.state.maybeWhen(
        success: (message) => expect(message, 'done'),
        orElse: () => fail('Expected success state'),
      );
    });

    test('transfer rejected due to insufficient balance produces error then restore', () async {
      final repo = _MockRepo();

      when(() => repo.getAccountBalance(any())).thenAnswer((_) async => 50);
      when(() => repo.getRemainingDailyLimit(any())).thenAnswer((_) async => 1000);

      final cubit = TransferMoneyCubit(repo: repo);
      cubit.setFromAccount('A');
      cubit.setToAccount('B');
      cubit.setAmount('100');

      final emitted = <dynamic>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.any((s) => s.toString().contains('error')), isTrue);
      expect(cubit.state.toString().contains('ready'), isTrue);

      await sub.cancel();
    });
  });
}
