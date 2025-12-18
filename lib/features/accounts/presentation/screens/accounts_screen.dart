import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:advanced_banking_system/core/helpers/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../logic/cubit/accounts_cubit.dart';
import '../widgets/accounts_filters_bar.dart';
import '../widgets/accounts_header.dart';
import '../widgets/accounts_helpers.dart';
import '../widgets/accounts_list.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool hideBalances = false;
  AccountsFilter filter = AccountsFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountsCubit>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final derived = state.maybeWhen(
          success: (roots) {
            final leaves = flattenLeaves(roots);
            final filtered = applyFilter(leaves, filter);
            final totals = computeTotals(filtered);
            return AccountsDerivedUi(
              items: filtered,
              assets: totals.assets,
              liabilities: totals.liabilities,
            );
          },
          orElse: () => const AccountsDerivedUi.empty(),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Icon(
              Icons.arrow_back,
              color: AppColors.whiteColor,
              size: 22.sp,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.blueColor,
            foregroundColor: AppColors.whiteColor,
            onPressed: () {},
            child: Icon(Icons.add, size: 22.sp),
          ),
          body: Stack(
            children: [
              const _GradientHeaderBackground(),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    verticalSpace(12),

                    AccountsHeader(
                      assets: derived.assets,
                      liabilities: derived.liabilities,
                      hideBalances: hideBalances,
                      onToggleHide: () =>
                          setState(() => hideBalances = !hideBalances),
                    ),

                    verticalSpace(14),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: AccountsFiltersBar(
                        selected: filter,
                        onSelected: (f) => setState(() => filter = f),
                      ),
                    ),

                    verticalSpace(10),

                    Expanded(
                      child: AccountsList(
                        state: state,
                        hideBalances: hideBalances,
                        items: derived.items,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradientHeaderBackground extends StatelessWidget {
  const _GradientHeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2F67FF), const Color(0xFF4C35F3)],
        ),
      ),
    );
  }
}
