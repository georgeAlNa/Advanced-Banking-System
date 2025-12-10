import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/font_weight_helper.dart';
import '../helpers/input_validation_type.dart';
import '../helpers/input_validator.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final IconData? suffixIcon;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final void Function()? onPressedSuffixIcon;
  final void Function()? onPressedPrefixIcon;
  final int? maxLines;
  final int? minLines;
  final double? height;
  final double? width;
  final bool expands;
  final TextInputAction? textInputAction;
  final Color? inputColor;

  final InputValidationType validationType;
  final String? customPattern;
  final bool? readOnly;

  const TextFieldWidget({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIconColor,
    this.suffixIcon,
    required this.hintText,
    required this.labelText,
    required this.obscureText,
    this.keyboardType,
    this.onPressedSuffixIcon,
    this.onPressedPrefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.height,
    this.width,
    this.expands = false,
    this.textInputAction,
    this.inputColor,
    this.validationType = InputValidationType.none,
    this.customPattern,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height?.h,
      width: width?.w,
      child: TextFormField(
        readOnly: readOnly ?? false,
        style: TextStyle(color: inputColor ?? AppColors.greyColor),
        keyboardType: keyboardType ?? TextInputType.text,
        cursorColor: AppColors.primaryColor,
        validator: (value) => InputValidator.validate(
          value: value ?? "",
          type: validationType,
          customPattern: customPattern,
        ),
        controller: controller,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        minLines: minLines,
        expands: expands,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.whiteColor,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onPressedSuffixIcon,
                  color: suffixIconColor,
                )
              : null,
          prefixIcon: prefixIcon != null
              ? IconButton(
                  icon: Icon(prefixIcon),
                  onPressed: onPressedPrefixIcon,
                  color: prefixIconColor,
                )
              : null,
          iconColor: AppColors.whiteForTextFieldBorderColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.whiteForTextFieldBorderColor,
              width: 1.w,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.greyColor),
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyColor,
            fontWeight: AppFontWeightHelper.medium,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: maxLines != null && maxLines! > 1 ? 16.h : 12.h,
          ),
          alignLabelWithHint: maxLines != null && maxLines! > 1,
        ),
      ),
    );
  }
}
