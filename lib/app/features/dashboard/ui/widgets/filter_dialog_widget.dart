import 'package:flutter/material.dart';
import 'package:ginfit/generated/l10n.dart';

class FilterDialogWidget extends StatefulWidget {
  final List<String> categories;
  final List<String> originalCategories;
  final Set<String> selectedCategories;
  final Function(String) onCategoryToggled;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  const FilterDialogWidget({
    super.key,
    required this.categories,
    required this.originalCategories,
    required this.selectedCategories,
    required this.onCategoryToggled,
    required this.onSelectAll,
    required this.onClearAll,
  });

  @override
  State<FilterDialogWidget> createState() => _FilterDialogWidgetState();
}

class _FilterDialogWidgetState extends State<FilterDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context).filterByCategory,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Select All / Clear All butonları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onSelectAll();
                      setState(() {}); // Dialog state'ini güncelle
                    },
                    child: Text(AppLocalizations.of(context).selectAll),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onClearAll();
                      setState(() {}); // Dialog state'ini güncelle
                    },
                    child: Text(AppLocalizations.of(context).clearAll),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Kategori listesi
            Expanded(
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final translatedCategory = widget.categories[index];
                  final originalCategory = widget.originalCategories[index];
                  final isSelected =
                      widget.selectedCategories.contains(originalCategory);

                  return CheckboxListTile(
                    title: Text(translatedCategory),
                    value: isSelected,
                    onChanged: (bool? value) {
                      widget.onCategoryToggled(originalCategory);
                      setState(() {}); // Dialog state'ini güncelle
                    },
                  );
                },
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context).done),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
