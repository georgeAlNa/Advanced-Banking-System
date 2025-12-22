class SignupResponse {
  final String token;

  SignupResponse({required this.token});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      token: json['data']?['token'] ?? '',
    );
  }
}
