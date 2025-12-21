import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:advanced_banking_system/core/helpers/input_validation_type.dart';
import 'package:advanced_banking_system/core/public_widgets/text_field_widget.dart';
import 'package:advanced_banking_system/features/auth/logic/login/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor, // Blue background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Title section
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF1454F2),
                      size: 45,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'SecureBank',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome Back! Please login to your account.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // Main form container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username Field
                      TextFieldWidget(
                        controller: _emailController,
                        prefixIcon: Icons.person_2_outlined,
                        hintText: 'Enter your email',
                        labelText: 'Email',
                        obscureText: false,
                        validationType: InputValidationType.none,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFieldWidget(
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onPressedSuffixIcon: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        hintText: 'Enter your password',
                        labelText: 'Password',
                        obscureText: _obscurePassword,
                        validationType: InputValidationType.none,
                      ),

                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  activeColor: AppColors.blueColor,
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 34, 37, 41),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<LoginCubit>().login(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Link
                      Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Color.fromARGB(255, 34, 37, 41),
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
