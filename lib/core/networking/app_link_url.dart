class AppLinkUrl {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String signup = "auth/register";
  static const String login = '$baseUrl/auth/login';
  static const String verifyOtp = "auth/verify-account";
  static const String requestPasswordReset = "auth/password/request-reset";
  static const String submitPasswordReset = "auth/password/reset";
  static const String changePassword = "auth/password/change";
  static const String submitComplaint = "complaints";
  static const String complaints = "complaints";
}
