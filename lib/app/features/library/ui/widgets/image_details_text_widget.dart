// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

class ImageDetailsTextWidget extends StatelessWidget {
  final String title;
  final String value;
  const ImageDetailsTextWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
