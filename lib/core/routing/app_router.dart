import 'package:advanced_banking_system/features/home/logic/cubit/home_cubit.dart';
import 'package:advanced_banking_system/features/home/presentation/screens/bottom_nav_bar.dart';
import 'package:advanced_banking_system/features/home/presentation/screens/home_screen.dart';
import 'package:advanced_banking_system/features/support/presentation/screens/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/auth/logic/login/login_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/transfer_money/presentation/screens/transfer_screen.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: LoginScreen(),
          ),
        );
      case Routes.bottomNavBarScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<HomeCubit>(),
            child: BottomNavBar(),
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
