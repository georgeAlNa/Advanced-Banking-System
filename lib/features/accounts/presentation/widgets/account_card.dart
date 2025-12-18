import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../data/models/account_model.dart';
import '../../logic/services/account_tree_composite.dart';
import 'accounts_helpers.dart';

class AccountCard extends StatelessWidget {
  final AccountComponent account;
  final bool hideBalances;

  final VoidCallback onTransfer;
  final VoidCallback onDetails;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  const AccountCard({
    super.key,
    required this.account,
    required this.hideBalances,
    required this.onTransfer,
    required this.onDetails,
    required this.onSettings,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final headerColorValue = headerColor(account.type);
    final isNegative = account.ownBalance < 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: headerColorValue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusPill(text: account.status.name),
                    const Spacer(),
                    IconButton(
                      onPressed: onMenu,
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.whiteColor,
                        size: 20.sp,
                      ),
                      splashRadius: 20.r,
                    ),
                  ],
                ),
                Text(
                  account.name,
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                verticalSpace(4),
                Text(
                  typeLabel(account.type),
                  style: TextStyle(
                    color: AppColors.whiteColor.withOpacity(0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                verticalSpace(12),
                Text(
                  'Account Number',
                  style: TextStyle(
                    color: AppColors.whiteColor.withOpacity(0.9),
                    fontSize: 12.sp,
                  ),
                ),
                verticalSpace(6),
                Text(
                  fakeAccountNumberFromId(account.id),
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12.sp),
                ),
                verticalSpace(6),
                Text(
                  hideBalances ? '••••••' : formatMoney(account.ownBalance),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: isNegative ? AppColors.redColor : AppColors.textDark,
                  ),
                ),
                verticalSpace(10),
                _MiniMetric(type: account.type),
                verticalSpace(14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Transfer',
                        onTap: onTransfer,
                      ),
                    ),
                    horizontalSpace(10),
                    Expanded(
                      child: _ActionButton(label: 'Details', onTap: onDetails),
                    ),
                    horizontalSpace(10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Settings',
                        onTap: onSettings,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final AccountType type;
  const _MiniMetric({required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == AccountType.investment) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Performance',
              style: TextStyle(color: AppColors.textLight, fontSize: 12.sp),
            ),
          ),
          Icon(Icons.trending_up, size: 16.sp, color: AppColors.greenColor),
          4.horizontalSpace,
          Text(
            '+15.2%',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.greenColor,
              fontSize: 12.sp,
            ),
          ),
        ],
      );
    }

    if (type == AccountType.savings || type == AccountType.loan) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Interest Rate',
              style: TextStyle(color: AppColors.textLight, fontSize: 12.sp),
            ),
          ),
          Text(
            '4.5% APY',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
              color: AppColors.textDark,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
      ),
    );
  }
}
