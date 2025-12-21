class LoginRequestBody {
  final String email;
  final String password;

  LoginRequestBody({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
