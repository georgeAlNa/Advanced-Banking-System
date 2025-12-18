import 'package:json_annotation/json_annotation.dart';

part 'transfer_response_model.g.dart';

@JsonSerializable()
class TransferResponseModel {
  final String transactionId;
  final String status;
  final String message;

  const TransferResponseModel({
    required this.transactionId,
    required this.status,
    required this.message,
  });

  factory TransferResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransferResponseModelToJson(this);
}
