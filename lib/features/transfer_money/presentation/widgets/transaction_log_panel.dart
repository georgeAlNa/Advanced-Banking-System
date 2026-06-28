import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/consistency/two_phase_commit.dart';
import '../../../../core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TransactionLogPanel
//
// يعرض الـ 2PC log في الوقت الفعلي أثناء التحويل.
// يظهر فقط لما تكون عملية نشطة، يختفي لما تنتهي.
//
// الاستخدام في transfer_screen.dart:
//   TransactionLogPanel(
//     logStream:   context.read<TransferMoneyCubit>().txLogStream,
//     stateStream: context.read<TransferMoneyCubit>().txStateStream,
//   ),
// ─────────────────────────────────────────────────────────────────────────────

class TransactionLogPanel extends StatefulWidget {
  final Stream<TxLogEntry> logStream;
  final Stream<TxState>    stateStream;

  const TransactionLogPanel({
    super.key,
    required this.logStream,
    required this.stateStream,
  });

  @override
  State<TransactionLogPanel> createState() => _TransactionLogPanelState();
}

class _TransactionLogPanelState extends State<TransactionLogPanel> {
  final _entries   = <TxLogEntry>[];
  TxState _state   = TxState.idle;
  bool _isVisible  = false;
  final _scrollKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    widget.logStream.listen((entry) {
      if (!mounted) return;
      setState(() {
        _entries.add(entry);
        _isVisible = true;
      });
      _scrollToBottom();
    });

    widget.stateStream.listen((state) {
      if (!mounted) return;
      setState(() => _state = state);

      // اختفي 2 ثانية بعد ما تنتهي العملية
      if (state == TxState.committed || state == TxState.aborted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isVisible = false);
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _scrollKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 1.0,
            duration: const Duration(milliseconds: 200));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _entries.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _borderColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9.r)),
            ),
            child: Row(
              children: [
                _StateDot(state: _state),
                SizedBox(width: 8.w),
                Text(
                  _stateLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: _borderColor,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                Text(
                  '2PC Transaction Log',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // ── Log entries ────────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 160.h),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shrinkWrap: true,
              itemCount: _entries.length,
              itemBuilder: (_, i) {
                final entry = _entries[i];
                final isLast = i == _entries.length - 1;
                return Padding(
                  key: isLast ? _scrollKey : null,
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timeLabel(entry.timestamp),
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF475569),
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          entry.message,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _entryColor(entry.level),
                            fontFamily: 'monospace',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color get _borderColor => switch (_state) {
    TxState.committed   => const Color(0xFF22C55E),
    TxState.aborted     => const Color(0xFFEF4444),
    TxState.rollingBack => const Color(0xFFF59E0B),
    _                   => const Color(0xFF3B82F6),
  };

  String get _stateLabel => switch (_state) {
    TxState.idle        => 'IDLE',
    TxState.preparing   => 'PHASE 1: PREPARE',
    TxState.voting      => 'PHASE 1: VOTING',
    TxState.committing  => 'PHASE 2: COMMIT',
    TxState.rollingBack => 'PHASE 2: ROLLBACK',
    TxState.committed   => 'COMMITTED ✓',
    TxState.aborted     => 'ABORTED ✗',
  };

  Color _entryColor(TxLogLevel level) => switch (level) {
    TxLogLevel.success => const Color(0xFF22C55E),
    TxLogLevel.error   => const Color(0xFFEF4444),
    TxLogLevel.info    => const Color(0xFF94A3B8),
  };

  String _timeLabel(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';
}

// ── State indicator dot ───────────────────────────────────────────────────────

class _StateDot extends StatefulWidget {
  final TxState state;
  const _StateDot({required this.state});

  @override
  State<_StateDot> createState() => _StateDotState();
}

class _StateDotState extends State<_StateDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.state != TxState.committed &&
        widget.state != TxState.aborted &&
        widget.state != TxState.idle;

    final color = switch (widget.state) {
      TxState.committed   => const Color(0xFF22C55E),
      TxState.aborted     => const Color(0xFFEF4444),
      TxState.rollingBack => const Color(0xFFF59E0B),
      _                   => const Color(0xFF3B82F6),
    };

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: isActive ? _anim.value : 1.0),
        ),
      ),
    );
  }
}