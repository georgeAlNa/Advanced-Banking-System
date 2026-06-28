import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/networking/resilient_fetcher.dart';
import '../../../../core/constants/colors.dart';

class CircuitBreakerBanner extends StatefulWidget {
  final ResilientFetcher fetcher;

  final Duration pollInterval;

  const CircuitBreakerBanner({
    super.key,
    required this.fetcher,
    this.pollInterval = const Duration(milliseconds: 500),
  });

  @override
  State<CircuitBreakerBanner> createState() => _CircuitBreakerBannerState();
}

class _CircuitBreakerBannerState extends State<CircuitBreakerBanner>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  CircuitState _state = CircuitState.closed;
  Duration? _cooldown;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _timer = Timer.periodic(widget.pollInterval, (_) => _refresh());
    _refresh();
  }

  void _refresh() {
    final newState   = widget.fetcher.circuitState;
    final newCooldown = widget.fetcher.remainingCooldown;

    if (!mounted) return;
    setState(() {
      _state    = newState;
      _cooldown = newCooldown;
    });

    if (newState != CircuitState.closed) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == CircuitState.closed) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: _BannerContent(
        state: _state,
        cooldown: _cooldown,
        failureCount: widget.fetcher.failureCount,
      ),
    );
  }
}


class _BannerContent extends StatelessWidget {
  final CircuitState state;
  final Duration? cooldown;
  final int failureCount;

  const _BannerContent({
    required this.state,
    required this.cooldown,
    required this.failureCount,
  });

  @override
  Widget build(BuildContext context) {
    final config = _bannerConfig(state, cooldown, failureCount);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.iconColor, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: config.titleColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  config.subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: config.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          if (state == CircuitState.open && cooldown != null)
            _CooldownBadge(cooldown: cooldown!),
        ],
      ),
    );
  }
}


class _CooldownBadge extends StatelessWidget {
  final Duration cooldown;

  const _CooldownBadge({required this.cooldown});

  @override
  Widget build(BuildContext context) {
    final seconds = cooldown.inSeconds.clamp(0, 99);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.redColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '${seconds}s',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.redColor,
        ),
      ),
    );
  }
}


class _BannerConfig {
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final IconData icon;
  final String title;
  final String subtitle;

  const _BannerConfig({
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

_BannerConfig _bannerConfig(
  CircuitState state,
  Duration? cooldown,
  int failureCount,
) {
  switch (state) {

    case CircuitState.open:
      return _BannerConfig(
        bgColor:      AppColors.redColor.withValues(alpha: 0.06),
        borderColor:  AppColors.redColor.withValues(alpha: 0.25),
        iconColor:    AppColors.redColor,
        titleColor:   AppColors.redColor,
        subtitleColor: const Color(0xFF7F1D1D),
        icon:    Icons.shield_outlined,
        title:   'خدمة التحويل محجوبة مؤقتاً',
        subtitle: 'فشل الاتصال $failureCount مرات — سيُعاد المحاولة تلقائياً',
      );

    case CircuitState.halfOpen:
      return _BannerConfig(
        bgColor:      AppColors.vibrantOrangeColor.withValues(alpha: 0.08),
        borderColor:  AppColors.vibrantOrangeColor.withValues(alpha: 0.3),
        iconColor:    AppColors.vibrantOrangeColor,
        titleColor:   const Color(0xFF92400E),
        subtitleColor: const Color(0xFFB45309),
        icon:    Icons.sync_outlined,
        title:   'جاري التحقق من الاتصال...',
        subtitle: 'إعادة فحص الخدمة — قد يستغرق لحظة',
      );

    case CircuitState.closed:
      return const _BannerConfig(
        bgColor:      Colors.transparent,
        borderColor:  Colors.transparent,
        iconColor:    Colors.transparent,
        titleColor:   Colors.transparent,
        subtitleColor: Colors.transparent,
        icon:    Icons.check,
        title:   '',
        subtitle: '',
      );
  }
}