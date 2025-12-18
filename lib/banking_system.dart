import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/colors.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';

class BankingSystem extends StatelessWidget {
  final AppRouter appRouter;
  const BankingSystem({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Banking System',
          onGenerateRoute: appRouter.generateRoute,
          initialRoute: Routes.transferMoneyScreen,
          theme: ThemeData(
            primaryColor: AppColors.blueColor,
            scaffoldBackgroundColor: AppColors.whiteColor,
          ),
        );
      },
    );
  }
}
