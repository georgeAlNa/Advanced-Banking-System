import 'package:advanced_banking_system/core/routing/routes.dart';
import 'package:advanced_banking_system/features/auth/data/datasources/otp_remote_data_source.dart';
import 'package:advanced_banking_system/features/auth/data/repos/otp_repo.dart';
import 'package:advanced_banking_system/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/networking/api_services_impl.dart';
import '../../../../core/networking/network_info.dart';
import '../../data/datasources/signup_remote_data_source.dart';
import '../../data/repos/signup_repo.dart';
import '../../logic/signup/signup_cubit.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(
        SignupRepo(
          networkInfo: NetworkInfoImp(
            internetConnectionChecker:
                InternetConnectionChecker.instance,
          ),
          signupRemoteDataSource: SignupRemoteDataSourceImp(
            apiServicesImpl: ApiServicesImpl(),
          ),
        ),
        OtpRepo(
          networkInfo: NetworkInfoImp(
            internetConnectionChecker:
                InternetConnectionChecker.instance,
          ),
          otpRemoteDataSource: OtpRemoteDataSourceImp(
            apiServicesImpl: ApiServicesImpl(),
          ),
        ),
      ),
      child: BlocListener<SignupCubit, SignupState>(
  listener: (context, state) {
    state.whenOrNull(
      loading: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              const Center(child: CircularProgressIndicator()),
        );
      },
      otpSent: () {
        Navigator.pop(context);

        Navigator.pushReplacementNamed(
          context,
          Routes.otpScreen,
          arguments: {
            'email': 'example@example.com', // Replace with actual email if needed
            'expiryMinutes': 5, // Replace with actual expiryMinutes if needed
          },
        );
      },
      error: (msg) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  },
  child: const SignupScreen(),
),
    );
  }
}
