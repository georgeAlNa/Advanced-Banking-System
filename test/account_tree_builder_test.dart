import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_banking_system/features/accounts/data/models/account_model.dart';
import 'package:advanced_banking_system/features/accounts/logic/services/account_tree_composite.dart';

void main() {
  group('AccountTreeBuilder', () {
    test('builds tree and computes balances', () {
      final models = [
        AccountModel(id: '1', name: 'Root', type: AccountType.savings, status: AccountStatus.active, balance: 100),
        AccountModel(id: '2', name: 'Child A', type: AccountType.checking, status: AccountStatus.active, balance: 50, parentId: '1'),
        AccountModel(id: '3', name: 'Child B', type: AccountType.loan, status: AccountStatus.active, balance: 25, parentId: '1'),
        AccountModel(id: '4', name: 'Grandchild', type: AccountType.investment, status: AccountStatus.active, balance: 10, parentId: '2'),
      ];

      final builder = AccountTreeBuilder();
      final forest = builder.buildForest(models);

      expect(forest.length, 1);
      final root = forest.single;
      expect(root.id, '1');
      expect(root.isGroup, isTrue);
      expect(root.children.length, 2);

      // Root total: 100 + 50 + 10 + 25 = 185
      expect(root.totalBalance(), closeTo(185.0, 1e-9));

      final childA = root.children.firstWhere((c) => c.id == '2');
      expect(childA.isGroup, isTrue);
      expect(childA.totalBalance(), closeTo(60.0, 1e-9));

      final leaf = childA.children.firstWhere((c) => c.id == '4');
      expect(leaf.isGroup, isFalse);
      expect(leaf.totalBalance(), closeTo(10.0, 1e-9));
    });
  });
}
