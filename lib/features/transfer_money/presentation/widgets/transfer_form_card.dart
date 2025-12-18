import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../logic/cubit/transfer_money_cubit.dart';
import 'transfer_mock_data.dart';
import 'transfer_money_format.dart';

class TransferFormCard extends StatelessWidget {
  final dynamic data;
  final bool isLoading;

  const TransferFormCard({
    super.key,
    required this.data,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferMoneyCubit>();
    final amount = parseAmount(data.amountText);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Amount'),
          8.verticalSpace,
          _AmountField(
            value: data.amountText,
            enabled: !isLoading,
            onChanged: cubit.setAmount,
          ),

          14.verticalSpace,
          _FieldLabel('From Account'),
          8.verticalSpace,
          _AccountDropdown(
            enabled: !isLoading,
            value: data.fromAccountId,
            hint: 'Select account',
            items: mockAccounts,
            onChanged: cubit.setFromAccount,
          ),

          12.verticalSpace,
          Center(
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward,
                color: AppColors.blueColor,
                size: 18.sp,
              ),
            ),
          ),
          12.verticalSpace,

          _FieldLabel('To Account'),
          8.verticalSpace,
          _AccountDropdown(
            enabled: !isLoading,
            value: data.toAccountId,
            hint: 'Select account',
            items: mockAccounts,
            onChanged: cubit.setToAccount,
          ),

          14.verticalSpace,
          _FieldLabel('Note (Optional)'),
          8.verticalSpace,
          _NoteField(
            value: data.note,
            enabled: !isLoading,
            onChanged: cubit.setNote,
          ),

          18.verticalSpace,
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : cubit.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor.withOpacity(0.55),
                foregroundColor: AppColors.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Transfer ${formatMoney(amount)}',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textDark,
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _AmountField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixText: '\$  ',
        filled: true,
        fillColor: AppColors.backgroundForTextField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }
}

class _AccountDropdown extends StatelessWidget {
  final bool enabled;
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _AccountDropdown({
    required this.enabled,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundForTextField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      ),
      hint: Text(
        hint,
        style: TextStyle(color: AppColors.secondartTextColor, fontSize: 12.sp),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.secondartTextColor,
        size: 20.sp,
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _NoteField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Add a note...',
        hintStyle: TextStyle(
          color: AppColors.secondartTextColor,
          fontSize: 12.sp,
        ),
        filled: true,
        fillColor: AppColors.backgroundForTextField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }
}
