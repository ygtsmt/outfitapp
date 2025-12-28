import 'package:flutter/material.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class TextToImageErrorWidget extends StatelessWidget {
  final String? filterErrorMessage;

  const TextToImageErrorWidget({
    super.key,
    this.filterErrorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (filterErrorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              filterErrorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        AppLocalizations.of(context).noImageGenerated,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.baseColor,
            ),
      );
    }
  }
}
