// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$AccountTypeEnumMap, json['type']),
  status: $enumDecode(_$AccountStatusEnumMap, json['status']),
  balance: (json['balance'] as num).toDouble(),
  parentId: json['parentId'] as String?,
);

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'status': _$AccountStatusEnumMap[instance.status]!,
      'balance': instance.balance,
      'parentId': instance.parentId,
    };

const _$AccountTypeEnumMap = {
  AccountType.savings: 'savings',
  AccountType.checking: 'checking',
  AccountType.loan: 'loan',
  AccountType.investment: 'investment',
};

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.frozen: 'frozen',
  AccountStatus.suspended: 'suspended',
  AccountStatus.closed: 'closed',
};
