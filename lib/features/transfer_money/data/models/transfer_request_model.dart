import 'package:json_annotation/json_annotation.dart';

part 'transfer_request_model.g.dart';

enum TransferKind { ownAccounts, otherBanks, scheduled }

@JsonSerializable()
class TransferRequestModel {
  final TransferKind kind;
  final String fromAccountId;
  final String toAccountId; 
  final double amount;
  final String? note;

  final String? beneficiaryId;

  final DateTime? scheduledAt;

  final String? otpCode;

  const TransferRequestModel({
    required this.kind,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    this.note,
    this.beneficiaryId,
    this.scheduledAt,
    this.otpCode,
  });

  factory TransferRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TransferRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRequestModelToJson(this);
}
