class SendOtpResponse {
  final bool success;
  final String message;
  final int expiryMinutes;

  SendOtpResponse({
    required this.success,
    required this.message,
    required this.expiryMinutes,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      expiryMinutes: json['expiry_minutes'] ?? 0,
    );
  }
}
