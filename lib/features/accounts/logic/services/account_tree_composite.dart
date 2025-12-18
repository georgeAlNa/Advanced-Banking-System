import '../../data/models/account_model.dart';

abstract class AccountComponent {
  String get id;
  String get name;
  AccountType get type;
  AccountStatus get status;

  double get ownBalance;

  double totalBalance();

  List<AccountComponent> get children;

  bool get isGroup;

  void add(AccountComponent child);
  void remove(AccountComponent child);
}


class AccountLeaf implements AccountComponent {
  @override
  final String id;
  @override
  final String name;
  @override
  final AccountType type;
  @override
  final AccountStatus status;
  @override
  final double ownBalance;

  AccountLeaf({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.ownBalance,
  });

  @override
  double totalBalance() => ownBalance;

  @override
  List<AccountComponent> get children => const [];

  @override
  bool get isGroup => false;

  @override
  void add(AccountComponent child) {
    throw UnsupportedError('Cannot add child to leaf account');
  }

  @override
  void remove(AccountComponent child) {
    throw UnsupportedError('Cannot remove child from leaf account');
  }
}


class AccountGroup implements AccountComponent {
  @override
  final String id;
  @override
  final String name;
  @override
  final AccountType type;
  @override
  final AccountStatus status;
  @override
  final double ownBalance;

  final List<AccountComponent> _children;

  AccountGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.ownBalance,
    List<AccountComponent>? children,
  }) : _children = children ?? [];

  @override
  List<AccountComponent> get children => List.unmodifiable(_children);

  @override
  bool get isGroup => true;

  @override
  void add(AccountComponent child) => _children.add(child);

  @override
  void remove(AccountComponent child) => _children.remove(child);

  @override
  double totalBalance() {
    var sum = ownBalance;
    for (final c in _children) {
      sum += c.totalBalance();
    }
    return sum;
  }
}


class AccountTreeBuilder {
  List<AccountComponent> buildForest(List<AccountModel> models) {
    final Map<String?, List<AccountModel>> byParent = {};
    for (final m in models) {
      byParent.putIfAbsent(m.parentId, () => []).add(m);
    }

    final roots = byParent[null] ?? const [];
    return roots.map((root) => _buildNode(root, byParent)).toList();
  }

  AccountComponent _buildNode(
    AccountModel model,
    Map<String?, List<AccountModel>> byParent,
  ) {
    final kids = byParent[model.id] ?? const [];

    if (kids.isEmpty) {
      return AccountLeaf(
        id: model.id,
        name: model.name,
        type: model.type,
        status: model.status,
        ownBalance: model.balance,
      );
    }

    final group = AccountGroup(
      id: model.id,
      name: model.name,
      type: model.type,
      status: model.status,
      ownBalance: model.balance,
    );

    for (final child in kids) {
      group.add(_buildNode(child, byParent));
    }
    return group;
  }
}
