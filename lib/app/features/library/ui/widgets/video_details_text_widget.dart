import 'package:flutter/material.dart';

class VideoDetailsTextWidget extends StatelessWidget {
  final String title;
  final String value;

  const VideoDetailsTextWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    // Eğer value boş ise widget'ı gösterme
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          TextSpan(text: value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
