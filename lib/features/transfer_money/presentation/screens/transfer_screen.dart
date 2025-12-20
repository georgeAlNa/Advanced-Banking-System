import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:advanced_banking_system/core/helpers/spacing.dart';
import 'package:advanced_banking_system/core/public_widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/public_widgets/snack_bar_widget.dart';
import '../../data/models/transfer_request_model.dart';
import '../../logic/cubit/transfer_money_cubit.dart';
import '../widgets/transfer_header.dart';
import '../widgets/transfer_tabs.dart';
import '../widgets/transfer_form_card.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  _ReadySnapshot _lastReady = const _ReadySnapshot();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransferMoneyCubit, TransferMoneyState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (message) {
            showAppSnackBar(context, message);
          },
          error: (message) {
            showAppSnackBar(context, message);
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final ready = state.maybeWhen(
          ready: (kind, amountText, fromId, toId, note) {
            _lastReady = _ReadySnapshot(
              kind: kind,
              amountText: amountText,
              fromAccountId: fromId,
              toAccountId: toId,
              note: note,
            );
            return _lastReady;
          },
          orElse: () => _lastReady,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Stack(
            children: [
              _GradientBg(),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    verticalSpace(12),
                    const TransferHeader(),

                    verticalSpace(12),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TransferTabs(
                        selected: ready.kind,
                        onSelected: context
                            .read<TransferMoneyCubit>()
                            .changeTab,
                      ),
                    ),

                    verticalSpace(12),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        child: TransferFormCard(
                          data: ready,
                          isLoading: isLoading,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoading) const LoadingWidget(),
            ],
          ),
        );
      },
    );
  }
}

class _GradientBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueColor, AppColors.majorelleBlueColor],
        ),
      ),
    );
  }
}

class _ReadySnapshot {
  final TransferKind kind;
  final String amountText;
  final String? fromAccountId;
  final String? toAccountId;
  final String note;

  const _ReadySnapshot({
    this.kind = TransferKind.ownAccounts,
    this.amountText = '',
    this.fromAccountId,
    this.toAccountId,
    this.note = '',
  });
}
