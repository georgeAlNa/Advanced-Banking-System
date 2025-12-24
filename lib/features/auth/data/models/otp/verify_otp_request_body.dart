class VerifyOtpRequestBody {
  final int userId;
  final String otp;

  VerifyOtpRequestBody({
    required this.userId,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "otp": otp,
      };
}
