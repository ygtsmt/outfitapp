import 'package:flutter/material.dart';
import 'package:ginly/app/features/library/bloc/library_bloc.dart';
import 'package:ginly/core/core.dart';

class CheckVideosWidget extends StatefulWidget {
  const CheckVideosWidget({super.key});

  @override
  State<CheckVideosWidget> createState() => _CheckVideosWidgetState();
}

class _CheckVideosWidgetState extends State<CheckVideosWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _onPressed() {
    _controller.repeat(); // Başlat ve döndür

    Future.delayed(const Duration(seconds: 1), () {
      _controller.stop(); // 2 saniye sonra durdur
      _controller.reset();
    });
    getIt<LibraryBloc>().add(const GetUserGeneratedVideosEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: IconButton(
        color: context.baseColor,
        onPressed: () {
          _onPressed();
        },
        icon: Icon(
          Icons.refresh,
          color: context.baseColor,
        ),
      ),
    );
  }
}
