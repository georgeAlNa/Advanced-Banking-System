import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:advanced_banking_system/core/public_widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../logic/cubit/accounts_cubit.dart';
import '../../logic/services/account_tree_composite.dart';
import 'account_card.dart';

class AccountsList extends StatelessWidget {
  final AccountsState state;
  final bool hideBalances;
  final List<AccountComponent> items;

  const AccountsList({
    super.key,
    required this.state,
    required this.hideBalances,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const LoadingWidget(),
      error: (message) => Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark, fontSize: 14.sp),
          ),
        ),
      ),
      success: (_) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No accounts found.',
              style: TextStyle(color: AppColors.textDark, fontSize: 14.sp),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 90.h),
          itemCount: items.length,
          separatorBuilder: (_, __) => verticalSpace(14),
          itemBuilder: (context, i) {
            final a = items[i];
            return AccountCard(
              account: a,
              hideBalances: hideBalances,
              onTransfer: () {},
              onDetails: () {},
              onSettings: () {},
              onMenu: () {},
            );
          },
        );
      },
    );
  }
}
