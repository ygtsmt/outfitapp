import 'package:flutter/material.dart';
import 'package:comby/core/core.dart';

class RandomWidget extends StatefulWidget {
  const RandomWidget({
    super.key,
    required this.textToImagePromptController,
  });

  final TextEditingController textToImagePromptController;

  @override
  State<RandomWidget> createState() => _RandomWidgetState();
}

class _RandomWidgetState extends State<RandomWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
    final randomPrompt = PromptSuggestionsService.getRandomPrompt();
    widget.textToImagePromptController.text = randomPrompt;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          );
        },
        child: Icon(
          Icons.casino,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
