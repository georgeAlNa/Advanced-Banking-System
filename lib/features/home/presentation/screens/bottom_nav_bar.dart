import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../logic/cubit/home_cubit.dart';
import '../widgets/bottom_nav_bar_widget.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.whiteColor,
            body: Padding(
              padding: EdgeInsets.all(0.dm),
              child: cubit.pages[cubit.selectedIndex],
            ),
            bottomNavigationBar: BottomNavBarWidget(
              currentIndex: cubit.selectedIndex,
              onTap: cubit.changePage,
            ),
          ),
        );
      },
    );
  }
}