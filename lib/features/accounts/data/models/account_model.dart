import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonEnum(alwaysCreate: true)
enum AccountType { savings, checking, loan, investment }

@JsonEnum(alwaysCreate: true)
enum AccountStatus { active, frozen, suspended, closed }

@JsonSerializable(explicitToJson: true)
class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final AccountStatus status;
  final double balance;
  final String? parentId;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.balance,
    this.parentId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);
}
