import 'package:advanced_banking_system/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:advanced_banking_system/features/support/presentation/screens/support_screen.dart';
import 'package:advanced_banking_system/features/transfer_money/logic/cubit/transfer_money_cubit.dart';
import 'package:advanced_banking_system/features/transfer_money/presentation/screens/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../accounts/logic/cubit/accounts_cubit.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../presentation/screens/home_screen.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial());

  int selectedIndex = 0;

  final PageController pageController = PageController();
  int selectedIndexForPageController = 0;

  List<Widget> get pages => [
    BlocProvider(create: (context) => getIt<HomeCubit>(), child: HomeScreen()),
    BlocProvider(
      create: (context) => getIt<AccountsCubit>(),
      child: AccountsScreen(),
    ),
    BlocProvider(
      create: (context) => getIt<TransferMoneyCubit>(),
      child: TransferScreen(),
    ),

    SupportScreen(),
    ProfileScreen(),
  ];

  void changePage(int index) {
    selectedIndex = index;
    emit(HomeState.pageChanged(index));
  }
}
