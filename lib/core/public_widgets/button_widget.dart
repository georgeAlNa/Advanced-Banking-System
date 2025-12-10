import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';


class ButtonWidget extends StatelessWidget {
  final String title;
  final void Function() onTap;
  final Color? backgroundColor;
  final double? radius;
  final TextStyle textStyle;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double? borderWidth;
  const ButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.radius,
    required this.textStyle,
    this.width,
    this.height,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 327.w,
      height: height ?? 52.h,
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 16.r)),
        color: backgroundColor ?? AppColors.orangeColor,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 16.r)),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.orangeColor,
              borderRadius: BorderRadius.all(Radius.circular(radius ?? 16.r)),
              border: Border.all(
                color: borderColor ?? AppColors.orangeColor,
                width: borderWidth ?? 1.5.w,
              ),
            ),
            child: Center(child: Text(title, style: textStyle)),
          ),
        ),
      ),
    );
  }
}
