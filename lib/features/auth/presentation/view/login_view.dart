import 'package:advanced_banking_system/features/auth/data/datasources/login_remote_data_source.dart';
import 'package:advanced_banking_system/features/auth/data/repos/login_repo.dart';
import 'package:advanced_banking_system/features/auth/logic/login/login_cubit.dart';
import 'package:advanced_banking_system/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/networking/api_services_impl.dart';
import '../../../../core/networking/network_info.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        LoginRepo(
          networkInfo: NetworkInfoImp(
            internetConnectionChecker: InternetConnectionChecker.instance,
          ),

          loginRemoteDataSource: LoginRemoteDataSourceImp(
            apiServicesImpl: ApiServicesImpl(),
          ),
        ),
      ),
      child: BlocListener<LoginCubit, LoginState>(
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
            success: (_) {
              Navigator.of(context).pop(); // close loading
              Navigator.pushReplacementNamed(context, '/home');
            },
            error: (msg) {
              Navigator.of(context).pop(); // close loading
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            },
          );
        },
        child: const LoginScreen(),
      ),
    );
  }
}
