import 'package:flutter/material.dart';
import 'package:ginfit/app/features/library/bloc/library_bloc.dart';
import 'package:ginfit/core/core.dart';

class ReloadImagesWidget extends StatefulWidget {
  const ReloadImagesWidget({super.key});

  @override
  State<ReloadImagesWidget> createState() => _ReloadImagesWidgetState();
}

class _ReloadImagesWidgetState extends State<ReloadImagesWidget>
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
    getIt<LibraryBloc>().add(const GetUserGeneratedImagesEvent());
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
