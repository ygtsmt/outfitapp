import 'package:flutter/material.dart';
import 'package:comby/app/features/dashboard/ui/widgets/grid_layout_constants.dart';
import 'package:comby/generated/l10n.dart';

class AppBarActionsWidget extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onToggleGridLayout;
  final int crossAxisCount;
  final Color baseColor;

  const AppBarActionsWidget({
    super.key,
    required this.onFilterPressed,
    required this.onToggleGridLayout,
    required this.crossAxisCount,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onFilterPressed,
          icon: Icon(
            Icons.filter_list,
            color: baseColor,
          ),
          tooltip: AppLocalizations.of(context).filterByCategoryTooltip,
        ),
        IconButton(
          onPressed: onToggleGridLayout,
          icon: Icon(
            _getLayoutIcon(),
            color: baseColor,
          ),
          tooltip:
              '${AppLocalizations.of(context).toggleGridLayoutTooltip} (${crossAxisCount}x)',
        ),
      ],
    );
  }

  IconData _getLayoutIcon() {
    switch (crossAxisCount) {
      case GridLayoutConstants.minColumns:
        return Icons.grid_view;
      case GridLayoutConstants.defaultColumns:
        return Icons.view_column;
      case GridLayoutConstants.maxColumns:
        return Icons.view_agenda;
      default:
        return Icons.grid_view;
    }
  }
}
