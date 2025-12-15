import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginly/app/features/closet/data/closet_usecase.dart';
import 'package:ginly/app/features/closet/models/closet_item_model.dart';
import 'package:ginly/core/core.dart';

class ClosetItemFormScreen extends StatefulWidget {
  final File imageFile;

  const ClosetItemFormScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ClosetItemFormScreen> createState() => _ClosetItemFormScreenState();
}

class _ClosetItemFormScreenState extends State<ClosetItemFormScreen> {
  String? selectedSubcategory; // ZORUNLU
  String? selectedColor;
  String? selectedPattern;
  String? selectedSeason;
  String? selectedMaterial;
  String? selectedBrand;
  bool isUploading = false;

  // Tüm subcategory'leri alfabetik sıralı tek listede topla
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closet Item Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fotoğraf önizleme
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                widget.imageFile,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24.h),
            // Form fields
            _buildDropdown(
              label: 'Kategori * (Zorunlu)',
              value: selectedSubcategory,
              items: allSubcategories,
              onChanged: (value) {
                setState(() {
                  selectedSubcategory = value;
                });
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
              },
            ),
            SizedBox(height: 12.h),
            _buildBrandTextField(),
            SizedBox(height: 24.h),
            // Kaydet butonu
            ElevatedButton(
              onPressed: _canSave() && !isUploading ? _saveItem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.baseColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: isUploading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
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
      },
    );
  }

  bool _canSave() {
    return selectedSubcategory != null && selectedSubcategory!.isNotEmpty;
  }

  Future<void> _saveItem() async {
    if (!_canSave()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kategori seçiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Firebase Storage'a yükle
      final closetUseCase = getIt<ClosetUseCase>();
      final imageUrl = await closetUseCase.uploadClosetImage(widget.imageFile);

      // Subcategory'den category'yi otomatik belirle
      final autoCategory = ClosetItem.getCategoryFromSubcategory(selectedSubcategory);

      final item = ClosetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageUrl,
        category: autoCategory,
        subcategory: selectedSubcategory,
        color: selectedColor,
        pattern: selectedPattern,
        season: selectedSeason,
        material: selectedMaterial,
        brand: selectedBrand,
        createdAt: DateTime.now(),
      );

      // Item'ı ekle
      if (context.mounted) {
        getIt<ClosetBloc>().add(AddClosetItemEvent(item));

        // Başarı mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Closet item başarıyla eklendi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Geri dön - 2 ekran geri (form ve galeri)
        if (context.mounted) {
          context.router.pop(); // Form ekranını kapat
          context.router.pop(); // Galeri ekranını kapat
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

