import 'package:advanced_banking_system/features/auth/presentation/screens/otp_screen.dart';
import 'package:advanced_banking_system/features/auth/presentation/view/login_view.dart';
import 'package:advanced_banking_system/features/auth/presentation/view/otp_view.dart';
import 'package:advanced_banking_system/features/auth/presentation/view/signup_view.dart';
import 'package:advanced_banking_system/features/home/logic/cubit/home_cubit.dart';
import 'package:advanced_banking_system/features/home/presentation/screens/bottom_nav_bar.dart';
import 'package:advanced_banking_system/features/home/presentation/screens/home_screen.dart';
import 'package:advanced_banking_system/features/support/presentation/screens/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/transfer_money/presentation/screens/transfer_screen.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignupView());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case Routes.bottomNavBarScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<HomeCubit>(),
            child: BottomNavBar(),
          ),
        );
      case Routes.otpScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpView(
            email: args['email'],
            expiryMinutes: args['expiryMinutes'],
          ),
        );

      case Routes.accountsScreen:
        return MaterialPageRoute(builder: (_) => AccountsScreen());
      case Routes.transferMoneyScreen:
        return MaterialPageRoute(builder: (_) => TransferScreen());
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.supportScreen:
        return MaterialPageRoute(builder: (_) => SupportScreen());
      case Routes.profileScreen:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      default:
        return null;
    }
  }
}
