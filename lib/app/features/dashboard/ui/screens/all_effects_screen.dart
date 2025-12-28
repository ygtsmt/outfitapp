import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/app_bar_actions_widget.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/category_manager.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/effects_grid_widget.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/filter_dialog_widget.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/grid_layout_constants.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/search_bar_widget.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class AllEffectsScreen extends StatefulWidget {
  const AllEffectsScreen({super.key});

  @override
  State<AllEffectsScreen> createState() => _AllEffectsScreenState();
}

class _AllEffectsScreenState extends State<AllEffectsScreen> {
  int crossAxisCount = GridLayoutConstants.defaultColumns;
  final CategoryManager _categoryManager = CategoryManager();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // All Effects ekranı görüntülendi

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    setState(() {
      _categoryManager.loadCategories(context);
    });
  }

  void _toggleGridLayout() {
    setState(() {
      crossAxisCount = GridLayoutConstants.getNextColumnCount(crossAxisCount);
    });
  }

  void _onSearchChanged(String query) {
    context.read<AppBloc>().add(SearchEffectsEvent(query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AppBloc>().add(ClearSearchEvent());
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FilterDialogWidget(
              categories: _categoryManager.categories,
              originalCategories: _categoryManager.originalCategories,
              selectedCategories: _categoryManager.selectedCategories,
              onCategoryToggled: (category) {
                setState(() {
                  _categoryManager.toggleCategory(category);
                });
                setDialogState(() {});
              },
              onSelectAll: () {
                setState(() {
                  _categoryManager.selectAllCategories();
                });
                setDialogState(() {});
              },
              onClearAll: () {
                setState(() {
                  _categoryManager.clearAllCategories();
                });
                setDialogState(() {});
              },
            );
          },
        );
      },
    );
  }

  String _getAppBarTitle() {
    if (!_categoryManager.hasSelectedCategories) {
      return AppLocalizations.of(context).allEffects;
    } else if (_categoryManager.selectedCount == 1) {
      return '${_categoryManager.getCategoryDisplayName(_categoryManager.selectedCategories.first)} ${AppLocalizations.of(context).effects}';
    } else {
      return '${_categoryManager.selectedCount} ${AppLocalizations.of(context).categoriesEffects}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          _getAppBarTitle(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                fontSize: 14.sp,
              ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.baseColor),
          onPressed: () => context.router
              .pushNamed('/homeScreen/dashboard/dashboard-screen'),
        ),
        actions: [
          AppBarActionsWidget(
            onFilterPressed: _showFilterDialog,
            onToggleGridLayout: _toggleGridLayout,
            crossAxisCount: crossAxisCount,
            baseColor: context.baseColor,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
            baseColor: context.baseColor,
          ),
          Expanded(
            child: EffectsGridWidget(
              crossAxisCount: crossAxisCount,
              selectedCategories: _categoryManager.selectedCategories,
              originalCategories: _categoryManager.originalCategories,
            ),
          ),
        ],
      ),
    );
  }
}
