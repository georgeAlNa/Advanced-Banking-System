// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferRequestModel _$TransferRequestModelFromJson(
  Map<String, dynamic> json,
) => TransferRequestModel(
  kind: $enumDecode(_$TransferKindEnumMap, json['kind']),
  fromAccountId: json['fromAccountId'] as String,
  toAccountId: json['toAccountId'] as String,
  amount: (json['amount'] as num).toDouble(),
  note: json['note'] as String?,
  beneficiaryId: json['beneficiaryId'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  otpCode: json['otpCode'] as String?,
);

Map<String, dynamic> _$TransferRequestModelToJson(
  TransferRequestModel instance,
) => <String, dynamic>{
  'kind': _$TransferKindEnumMap[instance.kind]!,
  'fromAccountId': instance.fromAccountId,
  'toAccountId': instance.toAccountId,
  'amount': instance.amount,
  'note': instance.note,
  'beneficiaryId': instance.beneficiaryId,
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'otpCode': instance.otpCode,
};

const _$TransferKindEnumMap = {
  TransferKind.ownAccounts: 'ownAccounts',
  TransferKind.otherBanks: 'otherBanks',
  TransferKind.scheduled: 'scheduled',
};
