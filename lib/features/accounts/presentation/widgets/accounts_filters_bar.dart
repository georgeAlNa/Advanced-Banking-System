import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'accounts_helpers.dart';

class AccountsFiltersBar extends StatelessWidget {
  final AccountsFilter selected;
  final ValueChanged<AccountsFilter> onSelected;

  const AccountsFiltersBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Chip(
                label: 'All',
                active: selected == AccountsFilter.all,
                onTap: () => onSelected(AccountsFilter.all),
              ),
              _Chip(
                label: 'Checking',
                active: selected == AccountsFilter.checking,
                onTap: () => onSelected(AccountsFilter.checking),
              ),
              _Chip(
                label: 'Savings',
                active: selected == AccountsFilter.savings,
                onTap: () => onSelected(AccountsFilter.savings),
              ),
              _Chip(
                label: 'Invest',
                active: selected == AccountsFilter.invest,
                onTap: () => onSelected(AccountsFilter.invest),
              ),
              _Chip(
                label: 'Loans',
                active: selected == AccountsFilter.loans,
                onTap: () => onSelected(AccountsFilter.loans),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: active
                ? AppColors.blueColor.withOpacity(0.10)
                : AppColors.whiteForTextFieldBorderColor,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: active ? AppColors.blueColor : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
