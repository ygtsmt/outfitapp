import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginly/app/features/closet/data/closet_usecase.dart';
import 'package:ginly/app/features/closet/models/closet_item_model.dart';
import 'package:ginly/app/features/closet/services/clothing_analysis_service.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/core/services/background_removal_service.dart';
import 'package:flutter_image_map/flutter_image_map.dart';

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
  bool isDebugMode = false; // Toggle to see clickable regions
  bool isAnalyzing = false; // AI analysis in progress
  final ClothingAnalysisService _analysisService = ClothingAnalysisService();
  final BackgroundRemovalService _backgroundRemovalService =
      BackgroundRemovalService();
  final TextEditingController _brandController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  // Vücut bölgelerine göre subcategory'leri organize et
  final Map<String, List<String>> bodyRegionCategories = {
    'head': [
      'hat',
      'glasses',
      'sunglasses',
      'scarf',
      'earrings',
    ],
    'hands': [
      'gloves',
      'watch',
      'ring',
      'bracelet',
    ],
    'upper_body': [
      'blazer',
      'blouse',
      'cardigan',
      'coat',
      'dress',
      'hoodie',
      'jacket',
      'shirt',
      'sweater',
      'swimwear',
      'tank top',
      't-shirt',
      'vest',
    ],
    'legs': [
      'jeans',
      'leggings',
      'pants',
      'shorts',
      'skirt',
      'trousers',
    ],
    'feet': [
      'boots',
      'flats',
      'heels',
      'sandals',
      'shoes',
      'slippers',
      'sneakers',
    ],
    'accessories': [
      'bag',
      'belt',
      'necklace',
      'pendant',
      'chain',
      'jewelry',
    ],
  };

  // Tüm subcategory'leri alfabetik sıralı tek listede topla (dropdown için)
  List<String> get allSubcategories {
    final all = <String>[];
    bodyRegionCategories.forEach((key, value) {
      all.addAll(value);
    });
    all.sort();
    return all;
  }

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
    'plastic',
  ];

  Widget _buildBodyMapSelector() {
    return Container(
      height: 400.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ImageMap with polygon-based region detection
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ImageMap(
              image: Image.asset(
                'assets/png/body_map.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Body Map Image Not Found'));
                },
              ),
              isDebug: isDebugMode,
              onTap: (region) {
                // Show bottom sheet with region-specific subcategories
                final regionKey = region.title;
                if (regionKey == null ||
                    !bodyRegionCategories.containsKey(regionKey)) {
                  return;
                }

                final categories = bodyRegionCategories[regionKey]!;
                _showCategoryBottomSheet(regionKey, categories);
              },
              regions: [
                // ------------------------------------------------------------
                // 🧑 HEAD AREA (for hats, hair items, face accessories)
                // - Head/face zone. Keep above torso.
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'head',
                  color: isDebugMode
                      ? Colors.red.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(220, 50), // top-left
                    Offset(462, 50), // top-right
                    Offset(480, 150), // right-mid
                    Offset(462, 205), // bottom-right
                    Offset(220, 205), // bottom-left
                    Offset(202, 150), // left-mid
                  ],
                ),

                // ------------------------------------------------------------
                // 👕 UPPER BODY / TORSO (for tshirts, jackets, hoodies)
                // - Covers chest + waist. Avoids arms & pants overlap.
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'upper_body',
                  color: isDebugMode
                      ? Colors.amber.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(200, 215), // left shoulder
                    Offset(480, 215), // right shoulder
                    Offset(515, 300), // right side (avoid arm)
                    Offset(470, 470), // right waist
                    Offset(210, 470), // left waist
                    Offset(165, 300), // left side (avoid arm)
                  ],
                ),

                // ------------------------------------------------------------
                // ✋ LEFT HAND (for rings, watch, glove — left)
                // - Separate region to prevent spilling onto shorts/torso.
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'hands',
                  color: isDebugMode
                      ? Colors.purple.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(118, 452),
                    Offset(155, 455),
                    Offset(210, 490),
                    Offset(190, 560),
                    Offset(160, 590),
                    Offset(125, 570),
                    Offset(110, 520),
                    Offset(108, 478),
                  ],
                ),

                // ------------------------------------------------------------
                // ✋ RIGHT HAND (for rings, watch, glove — right)
                // - Separate region to prevent spilling onto shorts/torso.
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'hands',
                  color: isDebugMode
                      ? Colors.purple.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(500, 470),
                    Offset(540, 455),
                    Offset(580, 485),
                    Offset(575, 525),
                    Offset(552, 565),
                    Offset(520, 585),
                    Offset(498, 545),
                    Offset(495, 500),
                  ],
                ),

                // ------------------------------------------------------------
                // 👖 PANTS / SHORTS AREA (for pants, jeans, shorts)
                // - Starts at waist, ends above knees. Avoids upper_body overlap.
                // ------------------------------------------------------------

                // ------------------------------------------------------------
                // 🦵 LEGS AREA (for legwear/skin edits, leggings etc.)
                // - From hips down to ankles (keep feet separate).
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'legs',
                  color: isDebugMode
                      ? Colors.green.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(220, 470), // left waist
                    Offset(450, 470), // right waist
                    Offset(450, 720), // right thigh
                    Offset(390, 720), // right above-knee
                    Offset(300, 720), // left above-knee
                    Offset(235, 720), // left thigh
                    Offset(200, 720), // left hip
                    Offset(450, 720), // right hip
                    Offset(450, 870), // right ankle
                    Offset(380, 870), // right leg bottom
                    Offset(302, 870), // left leg bottom
                    Offset(232, 870), // left ankle
                  ],
                ),

                // ------------------------------------------------------------
                // 👟 LEFT FOOT (for shoes — left)
                // - Separate from right to avoid distortion/cross polygons.
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'feet',
                  color: isDebugMode
                      ? Colors.orange.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(245, 925),
                    Offset(305, 925),
                    Offset(322, 975),
                    Offset(315, 1020),
                    Offset(255, 1023),
                    Offset(232, 1005),
                    Offset(232, 960),
                  ],
                ),

                // ------------------------------------------------------------
                // 👟 RIGHT FOOT (for shoes — right)
                // - Separate from left to avoid distortion/cross polygons.
                // ------------------------------------------------------------
                ImageMapRegion.fromPoly(
                  title: 'feet',
                  color: isDebugMode
                      ? Colors.orange.withOpacity(0.30)
                      : Colors.transparent,
                  points: const [
                    Offset(395, 930),
                    Offset(465, 930),
                    Offset(482, 975),
                    Offset(472, 1020),
                    Offset(410, 1023),
                    Offset(382, 1005),
                    Offset(382, 960),
                  ],
                ),
              ],
            ),
          ),

          // Selection Indicator Overlay (Optional Visual Feedback)
          if (selectedSubcategory != null)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

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
            SizedBox(height: 16.h),

            // AI ANALYZE BUTTON
            ElevatedButton.icon(
              onPressed: isAnalyzing || isUploading ? null : _analyzeWithAI,
              icon: isAnalyzing
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.auto_awesome, size: 20.sp),
              label: Text(
                isAnalyzing ? 'Analyzing...' : '✨ Analyze with AI',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.baseColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // INTERACTIVE BODY MAP SELECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Item Type',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Debug Mode',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Switch(
                      value: isDebugMode,
                      onChanged: (value) {
                        setState(() {
                          isDebugMode = value;
                        });
                      },
                      activeColor: context.baseColor,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildBodyMapSelector(),
            SizedBox(height: 12.h),

            Center(
              child: Text(
                selectedSubcategory != null
                    ? 'Selected: ${(selectedSubcategory ?? "").toUpperCase()}'
                    : 'Tap a body part to select category',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.baseColor,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Collapsible Details
            ExpansionTile(
              title: const Text('Item Details (Optional)'),
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  child: Column(
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
                    ],
                  ),
                ),
              ],
            ),

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
      controller: _brandController,
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

  /// Helper method to validate if a value exists in a list
  /// Returns the value if it exists, otherwise null
  String? _validateDropdownValue(String? value, List<String> validOptions) {
    if (value == null || value.isEmpty) return null;
    final lowerValue = value.toLowerCase();
    // Try exact match first
    if (validOptions.contains(value)) return value;
    // Try case-insensitive match
    for (final option in validOptions) {
      if (option.toLowerCase() == lowerValue) return option;
    }
    return null; // Value not found in options
  }

  /// Show dialog when uploaded image is not a valid fashion item
  void _showInvalidItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 48.sp,
        ),
        title: Text(
          'Geçersiz Fotoğraf',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Lütfen sadece giyim, ayakkabı, çanta, takı veya aksesuar fotoğrafı yükleyin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.router.pop(); // Go back to previous screen
            },
            child: Text(
              'Geri Dön',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog, stay on form
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.baseColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Manuel Devam Et',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Analyze clothing image with Gemini AI and auto-fill form
  Future<void> _analyzeWithAI() async {
    setState(() {
      isAnalyzing = true;
    });

    try {
      final result = await _analysisService.analyzeClothing(widget.imageFile);

      if (mounted) {
        // Check if this is a valid fashion item
        final isValid = result['isValidFashionItem']?.toLowerCase() == 'true';

        if (!isValid) {
          setState(() {
            isAnalyzing = false;
          });

          // Show dialog explaining this is not a fashion item
          _showInvalidItemDialog();
          return;
        }

        setState(() {
          // Validate each value against its dropdown options
          selectedSubcategory = _validateDropdownValue(
            result['subcategory'],
            allSubcategories,
          );
          selectedColor = _validateDropdownValue(
            result['color'],
            colors,
          );
          selectedPattern = _validateDropdownValue(
            result['pattern'],
            patterns,
          );
          selectedSeason = _validateDropdownValue(
            result['season'],
            seasons,
          );
          selectedMaterial = _validateDropdownValue(
            result['material'],
            materials,
          );
          // Brand is free-form text, no validation needed
          final detectedBrand = result['brand'];
          if (detectedBrand != null && detectedBrand.isNotEmpty) {
            selectedBrand = detectedBrand;
            _brandController.text = detectedBrand;
          }
          isAnalyzing = false;
        });

        // Show success message
        final brandInfo =
            selectedBrand != null ? ' | Brand: $selectedBrand' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✨ AI Analysis Complete! Found: ${selectedSubcategory?.toUpperCase()}$brandInfo',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Analysis Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _analyzeWithAI,
            ),
          ),
        );
      }
    }
  }

  void _showCategoryBottomSheet(String regionKey, List<String> categories) {
    // Region display names
    final regionNames = {
      'head': 'Baş / Yüz',
      'hands': 'Eller / Bileklik',
      'torso': 'Üst Gövde',
      'legs': 'Alt Gövde',
      'feet': 'Ayaklar',
      'accessories': 'Aksesuarlar',
      'upper_body': 'Üst Gövde',
    };

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori Seç: ${regionNames[regionKey] ?? regionKey}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedSubcategory == category;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedSubcategory = category;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Seçildi: ${category.toUpperCase()}'),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected ? context.baseColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? context.baseColor
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
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
      final closetUseCase = getIt<ClosetUseCase>();

      // 1. Upload original image to Firebase Storage (temporary - for fal.ai to access)
      final tempOriginalUrl =
          await closetUseCase.uploadClosetImage(widget.imageFile);

      // 2. Remove background using fal.ai API
      String finalImageUrl;
      try {
        // Get temporary transparent image URL from fal.ai
        final falAiTransparentUrl =
            await _backgroundRemovalService.removeBackground(tempOriginalUrl);

        // Download the transparent image bytes
        final transparentBytes = await _backgroundRemovalService
            .downloadImageBytes(falAiTransparentUrl);

        // Upload transparent version to our Firebase Storage
        finalImageUrl =
            await closetUseCase.uploadTransparentClosetImage(transparentBytes);

        // 3. Delete the original image from Firebase (we only need transparent)
        await closetUseCase.deleteImageFromStorage(tempOriginalUrl);
      } catch (e) {
        // Background removal failed, keep the original image
        debugPrint('Background removal failed: $e');
        finalImageUrl = tempOriginalUrl;
      }

      // Subcategory'den category'yi otomatik belirle
      final autoCategory =
          ClosetItem.getCategoryFromSubcategory(selectedSubcategory);

      final item = ClosetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: finalImageUrl,
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
          SnackBar(
            content: Text(
              finalImageUrl.contains('.png')
                  ? 'Closet item başarıyla eklendi (transparent ✓)'
                  : 'Closet item başarıyla eklendi',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Return the created item
        if (context.mounted) {
          context.router.pop(item);
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
