import 'package:advanced_banking_system/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter/material.dart';

class OtpView extends StatelessWidget {
  final String email;
  final int expiryMinutes;

  const OtpView({
    super.key,
    required this.email,
    required this.expiryMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return OtpScreen(
      email: email,
      expiryMinutes: expiryMinutes,
    );
  }
}
