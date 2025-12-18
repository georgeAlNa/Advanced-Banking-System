import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransferHeader extends StatelessWidget {
  const TransferHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Money',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          6.verticalSpace,
          Text(
            'Send money quickly and securely',
            style: TextStyle(
              color: AppColors.whiteColor.withOpacity(0.9),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
