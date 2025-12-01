import 'package:flutter/material.dart';
import 'package:ginly/app/features/library/bloc/library_bloc.dart';
import 'package:ginly/core/core.dart';

class ReloadRealtimeImagesWidget extends StatefulWidget {
  const ReloadRealtimeImagesWidget({super.key});

  @override
  State<ReloadRealtimeImagesWidget> createState() =>
      _ReloadRealtimeImagesWidgetState();
}

class _ReloadRealtimeImagesWidgetState extends State<ReloadRealtimeImagesWidget>
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
    getIt<LibraryBloc>().add(const GetUserGeneratedRealtimeImagesEvent());
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
        onPressed: _onPressed,
        icon: Icon(
          Icons.refresh,
          color: context.baseColor,
        ),
      ),
    );
  }
}
