import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginly/app/features/closet/models/closet_item_model.dart';
import 'package:ginly/core/core.dart';

class ClosetItemDetailScreen extends StatefulWidget {
  final ClosetItem closetItem;

  const ClosetItemDetailScreen({
    super.key,
    required this.closetItem,
  });

  @override
  State<ClosetItemDetailScreen> createState() => _ClosetItemDetailScreenState();
}

class _ClosetItemDetailScreenState extends State<ClosetItemDetailScreen> {
  late ClosetItem _editedItem;

  // Form fields
  String? selectedSubcategory;
  String? selectedColor;
  String? selectedPattern;
  String? selectedSeason;
  String? selectedMaterial;
  String? selectedBrand;

  final List<String> allSubcategories = [
    'bag',
    'belt',
    'blazer',
    'blouse',
    'boots',
    'cardigan',
    'coat',
    'flats',
    'hat',
    'heels',
    'hoodie',
    'jacket',
    'jeans',
    'jewelry',
    'leggings',
    'pants',
    'sandals',
    'scarf',
    'shirt',
    'shorts',
    'skirt',
    'slippers',
    'sneakers',
    'sweater',
    'tank top',
    't-shirt',
    'trousers',
    'vest',
    'watch',
  ];

  final List<String> colors = [
    'black',
    'white',
    'beige',
    'gray',
    'red',
    'blue',
    'green',
    'yellow',
    'orange',
    'pink',
    'purple',
    'brown',
    'navy',
    'khaki',
  ];

  final List<String> patterns = [
    'plain',
    'striped',
    'floral',
    'logo',
    'checkered',
    'graphic',
    'polka dot',
    'geometric',
  ];

  final List<String> seasons = [
    'summer',
    'winter',
    'spring',
    'autumn',
    'all',
  ];

  final List<String> materials = [
    'cotton',
    'denim',
    'leather',
    'wool',
    'polyester',
    'silk',
    'linen',
    'cashmere',
    'synthetic',
  ];

  @override
  void initState() {
    super.initState();
    _editedItem = widget.closetItem;
    selectedSubcategory = widget.closetItem.subcategory;
    selectedColor = widget.closetItem.color;
    selectedPattern = widget.closetItem.pattern;
    selectedSeason = widget.closetItem.season;
    selectedMaterial = widget.closetItem.material;
    selectedBrand = widget.closetItem.brand;
  }

  void _onFieldChanged() {
    // Değişiklik takibi için (şu an kullanılmıyor ama ileride kullanılabilir)
  }

  bool _hasChanges() {
    return selectedSubcategory != widget.closetItem.subcategory ||
        selectedColor != widget.closetItem.color ||
        selectedPattern != widget.closetItem.pattern ||
        selectedSeason != widget.closetItem.season ||
        selectedMaterial != widget.closetItem.material ||
        selectedBrand != widget.closetItem.brand;
  }

  void _handleBack() {
    if (_hasChanges() && _canSave()) {
      _saveItem(showSnackBar: false);
    }

    // Hemen geri dön
    context.router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detay'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: BlocListener<ClosetBloc, ClosetState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fotoğraf
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: _editedItem.imageUrl,
                  height: 300.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24.h),
              // Form alanları
              _buildDropdown(
                label: 'Alt Kategori *',
                value: selectedSubcategory,
                items: allSubcategories,
                onChanged: (value) {
                  setState(() {
                    selectedSubcategory = value;
                  });
                  _onFieldChanged();
                },
              ),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: 'Renk (Opsiyonel)',
                value: selectedColor,
                items: colors,
                onChanged: (value) {
                  setState(() {
                    selectedColor = value;
                  });
                  _onFieldChanged();
                },
              ),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: 'Desen (Opsiyonel)',
                value: selectedPattern,
                items: patterns,
                onChanged: (value) {
                  setState(() {
                    selectedPattern = value;
                  });
                  _onFieldChanged();
                },
              ),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: 'Mevsim (Opsiyonel)',
                value: selectedSeason,
                items: seasons,
                onChanged: (value) {
                  setState(() {
                    selectedSeason = value;
                  });
                  _onFieldChanged();
                },
              ),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: 'Kumaş (Opsiyonel)',
                value: selectedMaterial,
                items: materials,
                onChanged: (value) {
                  setState(() {
                    selectedMaterial = value;
                  });
                  _onFieldChanged();
                },
              ),
              SizedBox(height: 12.h),
              _buildBrandTextField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildBrandTextField() {
    return TextFormField(
      initialValue: selectedBrand,
      decoration: InputDecoration(
        labelText: 'Marka (Opsiyonel)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (value) {
        setState(() {
          selectedBrand = value.isEmpty ? null : value;
        });
        _onFieldChanged();
      },
    );
  }

  bool _canSave() {
    return selectedSubcategory != null && selectedSubcategory!.isNotEmpty;
  }

  bool _isSaving = false;

  Future<void> _saveItem({bool showSnackBar = true}) async {
    if (!_canSave() || !mounted || _isSaving) return;

    _isSaving = true;

    try {
      final autoCategory =
          ClosetItem.getCategoryFromSubcategory(selectedSubcategory);

      final updatedItem = ClosetItem(
        id: _editedItem.id,
        imageUrl: _editedItem.imageUrl,
        category: autoCategory,
        subcategory: selectedSubcategory,
        color: selectedColor,
        pattern: selectedPattern,
        season: selectedSeason,
        material: selectedMaterial,
        brand: selectedBrand,
        createdAt: _editedItem.createdAt,
      );

      // Sadece Bloc üzerinden güncelle (double update'i önle)
      getIt<ClosetBloc>().add(UpdateClosetItemEvent(updatedItem));

      if (mounted) {
        setState(() {
          _editedItem = updatedItem;
        });
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    } finally {
      _isSaving = false;
    }
  }
}
