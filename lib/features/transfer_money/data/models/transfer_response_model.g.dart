// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferResponseModel _$TransferResponseModelFromJson(
  Map<String, dynamic> json,
) => TransferResponseModel(
  transactionId: json['transactionId'] as String,
  status: json['status'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$TransferResponseModelToJson(
  TransferResponseModel instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'status': instance.status,
  'message': instance.message,
};
