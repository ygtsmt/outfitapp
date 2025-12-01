import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginly/app/features/realtime/ui/widgets/realtime_header_widget.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class RealtimePlaceholderWidget extends StatelessWidget {
  const RealtimePlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealtimeBloc, RealtimeState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: LayoutConstants.lowAllPadding,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius:
                          BorderRadius.circular(LayoutConstants.highRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(LayoutConstants.highRadius),
                      child: Image.asset(
                        PngPaths.realtime,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                LayoutConstants.midEmptyHeight,
                Text(
                  AppLocalizations.of(context).startGenerating,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                LayoutConstants.defaultEmptyHeight,
                Text(
                  AppLocalizations.of(context).typeYourPrompt,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                LayoutConstants.defaultEmptyHeight,
              ],
            ),
          ),
        );
      },
    );
  }
}
