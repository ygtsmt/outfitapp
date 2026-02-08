import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThoughtBubbleWidget extends StatefulWidget {
  final String? thought;
  final String? toolName;
  final bool isVisible;

  const ThoughtBubbleWidget({
    Key? key,
    this.thought,
    this.toolName,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<ThoughtBubbleWidget> createState() => _ThoughtBubbleWidgetState();
}

class _ThoughtBubbleWidgetState extends State<ThoughtBubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(ThoughtBubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  Color _getThoughtColor() {
    switch (widget.toolName) {
      case 'search_wardrobe':
        return Colors.purple.shade100;
      case 'get_weather':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  IconData _getThoughtIcon() {
    switch (widget.toolName) {
      case 'search_wardrobe':
        return Icons.search;
      case 'get_weather':
        return Icons.wb_sunny;
      default:
        return Icons.psychology;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.thought == null || !widget.isVisible) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _getThoughtColor(),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(_getThoughtIcon(), size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '💭 ${widget.thought}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
