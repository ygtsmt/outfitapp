import "package:flutter/material.dart";
import "package:flutter_adaptive_ui/flutter_adaptive_ui.dart";
import "package:injectable/injectable.dart";

@lazySingleton
class BottomSheetService {
  Future<void> show(final BuildContext context, final Widget child,
      {bool? isBig = false}) {
    final screen = Screen.fromContext(context);

    final double widthPercentange;

    if (screen.isHandset) {
      widthPercentange = 1;
    } else if (screen.isTablet) {
      widthPercentange = 0.8;
    } else {
      widthPercentange = 0.5;
    }

    return showModalBottomSheet(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * widthPercentange,
        maxHeight:
            MediaQuery.of(context).size.height * ((isBig ?? false) ? 0.8 : 0.5),
      ),
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (final BuildContext context) {
        return child;
      },
    );
  }
}
