import 'dart:io';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddWardrobeItemFormDialog extends StatefulWidget {
  final File imageFile;
  final String imageUrl;

  const AddWardrobeItemFormDialog({
    super.key,
    required this.imageFile,
    required this.imageUrl,
  });

  @override
  State<AddWardrobeItemFormDialog> createState() =>
      _AddWardrobeItemFormDialogState();
}

class _AddWardrobeItemFormDialogState extends State<AddWardrobeItemFormDialog> {
  String? selectedSubcategory; // ZORUNLU
  String? selectedColor;
  String? selectedPattern;
  String? selectedSeason;
  String? selectedMaterial;
  String? selectedBrand;

  // Tüm subcategory'leri alfabetik sıralı tek listede topla
  final List<String> allSubcategories = [
    'bag',
    'belt',
    'blazer',
    'blouse',
    'boots',
    'bracelet',
    'cardigan',
    'chain',
    'coat',
    'dress',
    'earrings',
    'flats',
    'glasses',
    'gloves',
    'hat',
    'heels',
    'hoodie',
    'jacket',
    'puffer jacket',
    'jeans',
    'jewelry',
    'leggings',
    'necklace',
    'pants',
    'pendant',
    'ring',
    'sandals',
    'scarf',
    'shirt',
    'shoes',
    'shorts',
    'skirt',
    'slippers',
    'sneakers',
    'sunglasses',
    'sweater',
    'swimwear',
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
    'gold',
    'silver',
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
    'gold',
    'silver',
    'metal',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Closet Item Ekle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                widget.imageFile,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.h),
            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdown(
                      label: 'Kategori * (Zorunlu)',
                      value: selectedSubcategory,
                      items: allSubcategories,
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
                        });
                      },
                      isRequired: true,
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(
                      label: AppLocalizations.of(context).colorOptional,
                      value: selectedColor,
                      items: colors,
                      onChanged: (value) {
                        setState(() {
                          selectedColor = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(
                      label: AppLocalizations.of(context).patternOptional,
                      value: selectedPattern,
                      items: patterns,
                      onChanged: (value) {
                        setState(() {
                          selectedPattern = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(
                      label: AppLocalizations.of(context).seasonOptional,
                      value: selectedSeason,
                      items: seasons,
                      onChanged: (value) {
                        setState(() {
                          selectedSeason = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(
                      label: AppLocalizations.of(context).fabricOptional,
                      value: selectedMaterial,
                      items: materials,
                      onChanged: (value) {
                        setState(() {
                          selectedMaterial = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildBrandTextField(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Save button
            ElevatedButton(
              onPressed: _canSave() ? _saveItem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.baseColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Kaydet',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
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
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan zorunludur';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildBrandTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).brandOptional,
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
      },
    );
  }

  bool _canSave() {
    // Subcategory zorunlu, diğerleri opsiyonel
    return widget.imageUrl.isNotEmpty &&
        selectedSubcategory != null &&
        selectedSubcategory!.isNotEmpty;
  }

  void _saveItem() {
    if (!_canSave()) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectCategory),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Subcategory'den category'yi otomatik belirle
    final autoCategory =
        WardrobeItem.getCategoryFromSubcategory(selectedSubcategory);

    final item = WardrobeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: widget.imageUrl,
      category: autoCategory,
      subcategory: selectedSubcategory,
      color: selectedColor,
      pattern: selectedPattern,
      season: selectedSeason,
      material: selectedMaterial,
      brand: selectedBrand,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(item);
  }
}
