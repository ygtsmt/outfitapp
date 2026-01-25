import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/dashboard/data/models/weather_model.dart';
import 'package:comby/app/features/dashboard/ui/screens/full_screen_image_screen.dart';
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/core/services/outfit_suggestion_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart';

class OutfitSuggestionResultScreen extends StatefulWidget {
  final OutfitSuggestion suggestion;
  final WeatherModel weather;

  const OutfitSuggestionResultScreen({
    super.key,
    required this.suggestion,
    required this.weather,
  });

  @override
  State<OutfitSuggestionResultScreen> createState() =>
      _OutfitSuggestionResultScreenState();
}

class _OutfitSuggestionResultScreenState
    extends State<OutfitSuggestionResultScreen> {
  // State
  late ModelItem _selectedModel;
  late List<WardrobeItem> _selectedClosetItems;

  bool _isGenerating = false;

  String? _generatedImageUrl;
  String? _requestId;
  StreamSubscription? _firestoreSubscription;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.suggestion.model;
    _selectedClosetItems = List.from(widget.suggestion.closetItems);

    // Auto-start generation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration(sourceId: 3); // Source 3: Initial Weather Suggestion
    });
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startGeneration({required int sourceId}) async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _generatedImageUrl = null;
      _requestId = null;
    });

    try {
      final falAiUsecase = GetIt.I<FalAiUsecase>();
      final clothesList = _selectedClosetItems
          .map((e) =>
              "${e.color ?? ''} ${e.subcategory ?? ''} ${e.category ?? ''}"
                  .trim())
          .join(", ");

      final imageUrls = [_selectedModel.imageUrl];
      for (var item in _selectedClosetItems) {
        imageUrls.add(item.imageUrl);
      }

      final result = await falAiUsecase.generateGeminiImageEdit(
        imageUrls: imageUrls,
        prompt:
            'Put the following clothes: ($clothesList) onto the person in the first image (which is the model). Keep the person\'s face, body shape, and pose exactly the same. Only change the clothing to match the provided items.',
        modelAiPrompt: _selectedModel.aiPrompt,
        usedClosetItems: _selectedClosetItems,
        sourceId: sourceId,
      );

      if (result != null && result['id'] != null) {
        final requestId = result['id'] as String;
        setState(() {
          _requestId = requestId;
        });
        _listenToResult(requestId);
      } else {
        _handleError('İstek oluşturulamadı.');
      }
    } catch (e) {
      _handleError('Hata oluştu: $e');
    }
  }

  void _listenToResult(String requestId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _firestoreSubscription?.cancel();
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('combines')
        .doc(requestId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final dynamic rawOutput = data['output'];
      final status = data['status'];

      if (rawOutput != null) {
        print('Raw Output received: $rawOutput');

        // Check if output is a List (like in CombinesTabContent)
        if (rawOutput is List) {
          if (rawOutput.isNotEmpty && rawOutput[0] is String) {
            final url = rawOutput[0] as String;
            print('Image URL found (List): $url');
            if (mounted) {
              setState(() {
                _generatedImageUrl = url;
                _isGenerating = false;
              });
              GetIt.I<ActivityService>().logActivity('outfit_generated');
              _firestoreSubscription?.cancel();
            }
            return;
          }
        }

        // Check if output is a Map (original logic)
        if (rawOutput is Map<String, dynamic>) {
          if (rawOutput['images'] != null && rawOutput['images'] is List) {
            final images = rawOutput['images'] as List;
            if (images.isNotEmpty && images[0] is Map) {
              final firstImage = images[0] as Map<String, dynamic>;
              if (firstImage['url'] != null) {
                final url = firstImage['url'] as String;
                print('Image URL found (Map): $url');
                if (mounted) {
                  setState(() {
                    _generatedImageUrl = url;
                    _isGenerating = false;
                  });
                  GetIt.I<ActivityService>().logActivity('outfit_generated');
                  _firestoreSubscription?.cancel();
                }
              } else {
                print('Image URL is null in first image: $firstImage');
              }
            } else {
              print('Images list is empty or first item is not a map: $images');
            }
          } else {
            print(
                'images key is missing or not a list: ${rawOutput['images']}');
          }
        }
      } else if (status == 'failed' || status == 'error') {
        print('Status failed or error: $status');
        _handleError('İşlem başarısız oldu.');
        _firestoreSubscription?.cancel();
      } else {
        print('Snapshot data: $data');
      }
    });
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _isGenerating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _changeModel() async {
    final result = await context.router.push<ModelItem>(
      const ModelGallerySelectionScreenRoute(),
    );

    if (result != null && result.id != _selectedModel.id) {
      setState(() {
        _selectedModel = result;
      });
      // Optionally auto-regenerate or let user click button
      // _startGeneration();
    }
  }

  Future<void> _changeItems() async {
    final result = await context.router.push<WardrobeItem>(
      const GallerySelectionScreenRoute(),
    );

    if (result != null) {
      // Add to list if not already present
      if (!_selectedClosetItems.any((e) => e.id == result.id)) {
        setState(() {
          if (_selectedClosetItems.length < 5) {
            _selectedClosetItems.add(result);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimum 5 kıyafet seçebilirsiniz'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Gemini 3 Kombin Sonucu',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Image Area
            Center(
              child: _buildResultImage(colorScheme),
            ),
            SizedBox(height: 8.h),

            // Controls Section
            Text(
              'Kombin Detayları',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 4.h),
            Divider(),
            SizedBox(height: 4.h),

            // Model Selection
            _buildSelectionRow(
              context,
              title: "Model",
              child: _buildModelPreview(),
              onTap: _isGenerating ? null : _changeModel,
            ),

            // Closet Items Selection
            _buildSelectionRow(
              context,
              title: "Kıyafetler",
              child: _buildClosetItemsPreview(),
              onTap: _isGenerating ? null : _changeItems,
            ),

            SizedBox(height: 8.h),

            // Regenerate Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: _isGenerating
                    ? null
                    : () =>
                        _startGeneration(sourceId: 4), // Source 4: Regenerate
                icon: _isGenerating
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                            color: colorScheme.onPrimary, strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded),
                label: Text(
                  _isGenerating ? 'Hazırlanıyor...' : 'Kombini Yenile',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildResultImage(ColorScheme colorScheme) {
    if (_isGenerating && _generatedImageUrl == null) {
      return Container(
        height: 400.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: colorScheme.primary,
              size: 50.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Gemini 3 kombini oluşturuyor...',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Bu işlem 10-15 saniye sürebilir',
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12.sp),
            ),
          ],
        ),
      );
    }

    if (_generatedImageUrl != null) {
      return GestureDetector(
        onTap: () {
          context.router
              .push(FullScreenImageScreenRoute(imageUrl: _generatedImageUrl!));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: CachedNetworkImage(
            imageUrl: _generatedImageUrl!,
            height: 400.h,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 400.h,
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      );
    }

    // Initial state or error (should not happen often due to auto-start)
    return Container(
      height: 400.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(child: Text("Görsel oluşturulamadı.")),
    );
  }

  Widget _buildSelectionRow(BuildContext context,
      {required String title, required Widget child, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (onTap != null)
              TextButton(
                onPressed: onTap,
                child: Text("Değiştir",
                    style: TextStyle(color: colorScheme.primary)),
              )
          ],
        ),
        child,
      ],
    );
  }

  Widget _buildModelPreview() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.router.push(
                FullScreenImageScreenRoute(imageUrl: _selectedModel.imageUrl));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: _selectedModel.imageUrl,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          "Seçili Model",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildClosetItemsPreview() {
    return SizedBox(
      height: 70.h,
      width: double.infinity,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _selectedClosetItems.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final item = _selectedClosetItems[index];
          return GestureDetector(
            onTap: () {
              context.router
                  .push(FullScreenImageScreenRoute(imageUrl: item.imageUrl));
            },
            child: Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
