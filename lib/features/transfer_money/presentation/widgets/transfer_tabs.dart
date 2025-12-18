import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/transfer_request_model.dart';

class TransferTabs extends StatelessWidget {
  final TransferKind selected;
  final ValueChanged<TransferKind> onSelected;

  const TransferTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            _TabPill(
              label: 'Own Accounts',
              active: selected == TransferKind.ownAccounts,
              onTap: () => onSelected(TransferKind.ownAccounts),
            ),
            8.horizontalSpace,
            _TabPill(
              label: 'Other Banks',
              active: selected == TransferKind.otherBanks,
              onTap: () => onSelected(TransferKind.otherBanks),
            ),
            8.horizontalSpace,
            _TabPill(
              label: 'Scheduled',
              active: selected == TransferKind.scheduled,
              onTap: () => onSelected(TransferKind.scheduled),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active
                ? AppColors.blueColor.withOpacity(0.12)
                : AppColors.whiteForTextFieldBorderColor,
            borderRadius: BorderRadius.circular(999.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: active ? AppColors.blueColor : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
