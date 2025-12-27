import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:ginly/app/features/fit_check/services/fit_check_service.dart';

class StreakWidget extends StatefulWidget {
  final bool isOverlay;
  const StreakWidget({super.key, this.isOverlay = false});

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  int _streak = 0;
  bool _isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadStreak();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    try {
      final streak = await GetIt.I<FitCheckService>().calculateStreak();
      if (mounted) {
        setState(() {
          _streak = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    final bgColor = widget.isOverlay
        ? Colors.white.withOpacity(0.2)
        : (_streak > 0
            ? Colors.orange.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1));

    final borderColor = widget.isOverlay
        ? Colors.white.withOpacity(0.3)
        : (_streak > 0
            ? Colors.orange.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2));

    final textColor = widget.isOverlay
        ? Colors.white
        : (_streak > 0 ? Colors.orange.shade800 : Colors.grey.shade600);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_streak > 0)
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 14.sp),
              ),
            )
          else
            Text(
              '🚀',
              style: TextStyle(fontSize: 14.sp),
            ),
          SizedBox(width: 6.w),
          Text(
            _streak > 0 ? '$_streak Günlük Seri' : 'Seriyi Başlat!',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
