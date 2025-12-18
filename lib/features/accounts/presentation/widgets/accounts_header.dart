import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import 'accounts_helpers.dart';

class AccountsHeader extends StatelessWidget {
  final double assets;
  final double liabilities;
  final bool hideBalances;
  final VoidCallback onToggleHide;

  const AccountsHeader({
    super.key,
    required this.assets,
    required this.liabilities,
    required this.hideBalances,
    required this.onToggleHide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'My Accounts',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
            ),
          ),
        ),
        14.verticalSpace,

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Assets',
                  value: hideBalances ? '••••••' : formatMoney(assets),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: _SummaryCard(
                  title: 'Total Liabilities',
                  value: hideBalances ? '••••••' : formatMoney(liabilities),
                ),
              ),
            ],
          ),
        ),

        verticalSpace(10),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: onToggleHide,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hideBalances ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.whiteColor.withOpacity(0.9),
                    size: 18.sp,
                  ),
                  8.horizontalSpace,
                  Text(
                    hideBalances ? 'Show balances' : 'Hide balances',
                    style: TextStyle(
                      color: AppColors.whiteColor.withOpacity(0.95),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.whiteColor.withOpacity(0.9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
