class SendOtpRequestBody {
  final String email;
  final String purpose;

  SendOtpRequestBody({
    required this.email,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
        "email": email,
        "purpose": purpose,
      };
}
