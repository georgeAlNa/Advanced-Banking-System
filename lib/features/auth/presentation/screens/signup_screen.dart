import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:advanced_banking_system/core/helpers/input_validation_type.dart';
import 'package:advanced_banking_system/core/public_widgets/text_field_widget.dart';
import 'package:advanced_banking_system/features/auth/logic/signup/signup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),

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
                    'Create your account to get started.',
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
                      TextFieldWidget(
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        hintText: 'Enter your full name',
                        labelText: 'Full Name',
                        obscureText: false,
                        validationType: InputValidationType.none,
                      ),
                      const SizedBox(height: 16),

                      TextFieldWidget(
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        hintText: 'Enter your email',
                        labelText: 'Email',
                        obscureText: false,
                        validationType: InputValidationType.none,
                      ),
                      const SizedBox(height: 16),

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

                      TextFieldWidget(
                        controller: _confirmPasswordController,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onPressedSuffixIcon: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        hintText: 'Confirm your password',
                        labelText: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        validationType: InputValidationType.none,
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<SignupCubit>().signup(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                confirmPassword:
                                    _confirmPasswordController.text,
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/LoginScreen',
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Color.fromARGB(255, 34, 37, 41),
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
