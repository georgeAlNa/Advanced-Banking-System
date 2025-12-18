import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/accounts/logic/cubit/accounts_cubit.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/auth/logic/login/login_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/transfer_money/logic/cubit/transfer_money_cubit.dart';
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
      case Routes.accountsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<AccountsCubit>(),
            child: AccountsScreen(),
          ),
        );
      case Routes.transferMoneyScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<TransferMoneyCubit>(),
            child: TransferScreen(),
          ),
        );

      default:
        return null;
    }
  }
}
