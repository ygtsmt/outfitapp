import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/core/core.dart';

class CategoryManager {
  final List<String> categories = [];
  final List<String> originalCategories = [];
  final Set<String> selectedCategories = {};

  void loadCategories(BuildContext context) {
    final appDocs = context.read<AppBloc>().state.appDocs;
    if (appDocs != null) {
      originalCategories.clear();
      categories.clear();
      selectedCategories.clear();

      originalCategories.addAll(
        appDocs.map((doc) => doc.title ?? '').toList(),
      );

      categories.addAll(
        appDocs.map((doc) => resolveByLocale(
              context.read<AppBloc>().state.languageLocale,
              doc.title ?? '',
              tr: doc.title_tr,
              de: doc.title_de,
              fr: doc.title_fr,
              ar: doc.title_ar,
              ru: doc.title_ru,
              zh: doc.title_zh,
              es: doc.title_es,
              hi: doc.title_hi,
              pt: doc.title_pt,
              id: doc.title_id,
            )),
      );
    }
  }

  void selectAllCategories() {
    selectedCategories.clear();
    selectedCategories.addAll(originalCategories);
  }

  void clearAllCategories() {
    selectedCategories.clear();
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  String getCategoryDisplayName(String originalName) {
    final index = originalCategories.indexOf(originalName);
    if (index != -1) {
      return categories[index];
    }
    return originalName;
  }

  bool get hasSelectedCategories => selectedCategories.isNotEmpty;
  int get selectedCount => selectedCategories.length;
}
