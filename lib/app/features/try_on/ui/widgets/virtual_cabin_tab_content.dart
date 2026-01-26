import 'package:auto_route/auto_route.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/ui/closet_screen.dart';
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:comby/app/features/try_on/ui/widgets/user_selection_sheet.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/generated/l10n.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// Helper class for local colors since AppColors is not found
class LocalColors {
  static const Color background = Color(0xFF121212);
  static const Color primary = Color(0xFFE94057);
}

class VirtualCabinTabContent extends StatefulWidget {
  final ModelItem? initialModel;
  final List<WardrobeItem>? initialClothes;
  final String? alternativeModelUrl; // Combine photo URL for toggle

  const VirtualCabinTabContent({
    super.key,
    this.initialModel,
    this.initialClothes,
    this.alternativeModelUrl,
  });

  @override
  State<VirtualCabinTabContent> createState() => _VirtualCabinTabContentState();
}

class _VirtualCabinTabContentState extends State<VirtualCabinTabContent>
    with AutomaticKeepAliveClientMixin {
  final FalAiUsecase _falAiUsecase = GetIt.I<FalAiUsecase>();
  final ClosetUseCase _closetUseCase = GetIt.I<ClosetUseCase>();

  ModelItem? _selectedModel; // Changed from String? _selectedModelUrl
  List<WardrobeItem> _selectedClothes = [];
  bool _useAlternativePhoto = false; // Toggle state for photo switching

  bool _isLoading = false;
  String? _statusMessage;
  String? _requestId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
    _selectedClothes =
        widget.initialClothes != null ? List.from(widget.initialClothes!) : [];
  }

  void _togglePhoto() {
    setState(() {
      _useAlternativePhoto = !_useAlternativePhoto;
    });
  }

  // Random Selection Implementation
  Future<void> _selectRandomModel() async {
    try {
      final models = await _closetUseCase.getUserModelItems();
      if (models.isNotEmpty) {
        final random = Random();
        setState(() {
          _selectedModel = models[random.nextInt(models.length)];
          _statusMessage = 'Random model selected!';
        });
      } else {
        setState(() {
          _statusMessage = 'No models found in gallery.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error selecting random model: $e';
      });
    }
  }

  Future<void> _selectRandomCloth() async {
    try {
      final clothes = await _closetUseCase.getUserClosetItems();
      // Filter out already selected matches if needed
      final availableClothes = clothes
          .where(
              (c) => !_selectedClothes.any((sc) => sc.imageUrl == c.imageUrl))
          .toList();

      if (availableClothes.isNotEmpty) {
        final random = Random();
        final randomItem =
            availableClothes[random.nextInt(availableClothes.length)];
        setState(() {
          _selectedClothes.add(randomItem);
          _statusMessage = 'Random item added!';
        });
      } else {
        setState(() {
          _statusMessage = 'No items found in closet.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error selecting random cloth: $e';
      });
    }
  }

  Future<void> _generateImage() async {
    if (_selectedModel == null || _selectedClothes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).pleaseSelectModelAndCloth)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting generation...';
      _requestId = null;
    });

    try {
      // Create list: [Model URL, Cloth URL 1, Cloth URL 2, ...]
      final List<String> imageUrls = [
        _selectedModel!.imageUrl,
        ..._selectedClothes.map((e) => e.imageUrl)
      ];

      // Construct a more specific prompt to preserve identity
      String clothesDescription = _selectedClothes.map((e) {
        final category = e.category ?? 'cloth';
        final subcategory = e.subcategory ?? '';
        final color = e.color ?? '';
        return '$color $subcategory $category'.trim();
      }).join(', ');

      final refinedPrompt =
          "Put the following clothes: ($clothesDescription) onto the person in the first image. Keep the person's face, body shape, and pose exactly the same. Only change the clothing.";

      final result = await _falAiUsecase.generateGeminiImageEdit(
        imageUrls: imageUrls,
        prompt: refinedPrompt,
        sourceId: 1, // TryOn Screen
        modelAiPrompt: _selectedModel!.aiPrompt,
        usedClosetItems: _selectedClothes,
      );

      if (result != null && result['status'] == 'processing') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).requestSentSuccessfully),
              backgroundColor: Colors.green,
            ),
          );

          // Force open Combines tab (Index 2)
          ClosetScreen.tabNotifier.value = 2;

          // Navigate to Closet > Combines
          context.router.navigate(
            const HomeScreenRoute(
              children: [
                ClosetTabRouter(),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = 'Request failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    // Set dark status bar for cropping
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2F2B52),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2F2B52),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Color(0xFF2F2B52),
      ),
    );

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      maxWidth: 2048,
      maxHeight: 2048,
      uiSettings: cropperUiSettings,
    );

    // Reset status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<void> _openClosetGallerySelection() async {
    Navigator.pop(context);
    final result =
        await context.router.push(const GallerySelectionScreenRoute());

    if (result is WardrobeItem) {
      if (!_selectedClothes.any((e) => e.imageUrl == result.imageUrl)) {
        setState(() {
          _selectedClothes.add(result);
          _statusMessage = 'Cloth added from gallery';
        });
      }
    }
  }

  Future<void> _openClosetCameraSelection() async {
    Navigator.pop(context);
    // Directly pick from camera here, then go to form using system picker logic
    // But user wants "Camera" button which typically opens camera inside app or system camera
    // My plan said: Pick image -> Go to Form
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    if (context.mounted) {
      final result = await context.router.push(
        ClosetItemFormScreenRoute(imageFile: File(pickedFile.path)),
      );

      if (result is WardrobeItem) {
        if (!_selectedClothes.any((e) => e.imageUrl == result.imageUrl)) {
          setState(() {
            _selectedClothes.add(result);
            _statusMessage = 'Cloth added from camera';
          });
        }
      }
    }
  }

  Future<void> _openGallerySelection() async {
    // Close the bottom sheet first
    Navigator.pop(context);

    // Navigate to gallery selection and wait for result
    final result =
        await context.router.push(const ModelGallerySelectionScreenRoute());

    if (result is ModelItem) {
      setState(() {
        _selectedModel = result;
        // Optionally show success message
        _statusMessage = 'Model selected from gallery';
      });
    }
  }

  Future<void> _openModelCameraSelection() async {
    Navigator.pop(context);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) return;

      if (context.mounted) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile == null || !context.mounted) return;

        final result = await context.router.push(
          ModelItemFormScreenRoute(imageFile: croppedFile),
        );

        if (result is ModelItem) {
          setState(() {
            _selectedModel = result;
            _statusMessage = 'Model added from camera';
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error taking photo: $e';
      });
    }
  }

  void _showModelSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UserSelectionSheet(
          title: AppLocalizations.of(context).selectModel,
          fetchItems: () async => await _closetUseCase.getUserModelItems(),
          leadingItems: [
            _buildSelectionOption(
              context,
              icon: Icons.photo_library_rounded,
              label: AppLocalizations.of(context).gallery,
              onTap: _openGallerySelection,
            ),
            _buildSelectionOption(
              context,
              icon: Icons.camera_alt_rounded,
              label: AppLocalizations.of(context).camera,
              onTap: _openModelCameraSelection,
            ),
          ],
          onSelected: (item) {
            if (item is ModelItem) {
              setState(() {
                _selectedModel = item;
              });
            }
          },
        );
      },
    );
  }

  void _showClothSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserSelectionSheet(
        title: AppLocalizations.of(context).selectCloth,
        fetchItems: () async => await _closetUseCase.getUserClosetItems(),
        leadingItems: [
          _buildSelectionOption(
            context,
            icon: Icons.photo_library_rounded,
            label: AppLocalizations.of(context).gallery,
            onTap: _openClosetGallerySelection,
          ),
          _buildSelectionOption(
            context,
            icon: Icons.camera_alt_rounded,
            label: AppLocalizations.of(context).camera,
            onTap: _openClosetCameraSelection,
          ),
        ],
        onSelected: (item) {
          if (item is WardrobeItem) {
            if (!_selectedClothes.any((e) => e.imageUrl == item.imageUrl)) {
              setState(() {
                _selectedClothes.add(item);
              });
            }
          }
        },
      ),
    );
  }

  Widget _buildSelectionOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Connection to keepalive
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      context,
                      AppLocalizations.of(context).model.toUpperCase(),
                      AppLocalizations.of(context).modelSubtitle),
                  const SizedBox(height: 16),
                  _ModelSelector(
                    imageUrl: _useAlternativePhoto &&
                            widget.alternativeModelUrl != null
                        ? widget.alternativeModelUrl
                        : _selectedModel?.imageUrl,
                    onTap: _showModelSelection,
                    onRandomSelect: _selectRandomModel,
                    alternativeUrl: widget.alternativeModelUrl,
                    isShowingAlternative: _useAlternativePhoto,
                    onTogglePhoto: _togglePhoto,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildSectionTitle(
                            context,
                            AppLocalizations.of(context)
                                .homeCloset
                                .toUpperCase(),
                            AppLocalizations.of(context).wardrobeSubtitle),
                      ),
                      if (_selectedClothes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            AppLocalizations.of(context)
                                .nSelected(_selectedClothes.length),
                            style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ClothList(
                    clothes: _selectedClothes,
                    onAdd: _showClothSelection,
                    onRandomSelect: _selectRandomCloth,
                    onRemove: (index) {
                      setState(() {
                        _selectedClothes.removeAt(index);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_statusMessage != null) _buildStatusCard(context),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer ??
                            colorScheme.surface, // Was 0xFF1E1E1E
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ||
                                _selectedModel == null ||
                                _selectedClothes.isEmpty
                            ? null
                            : _generateImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              colorScheme.primary, // Was 0xFFE94057
                          foregroundColor: colorScheme.onPrimary,
                          disabledBackgroundColor:
                              colorScheme.onSurface.withOpacity(0.12),
                          disabledForegroundColor:
                              colorScheme.onSurface.withOpacity(0.38),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                        color: colorScheme.onPrimary,
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12.w),
                                  const Text("Gemini 3 Processing..."),
                                ],
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.h),
                                child: Text(
                                  AppLocalizations.of(context).tryOnMode,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.primary, // Was 0xFFE94057
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7), // Was Colors.white70
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isError =
        _statusMessage!.contains('Error') || _statusMessage!.contains('failed');

    final statusColor = isError ? colorScheme.error : colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_requestId != null) ...[
            const SizedBox(height: 8),
            Text(
              'Request ID: $_requestId',
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5), fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onRandomSelect;
  final String? alternativeUrl;
  final bool isShowingAlternative;
  final VoidCallback? onTogglePhoto;

  const _ModelSelector({
    required this.imageUrl,
    required this.onTap,
    required this.onRandomSelect,
    this.alternativeUrl,
    this.isShowingAlternative = false,
    this.onTogglePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 380,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer ??
              colorScheme.surface, // Was 0xFF1E1E1E
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: imageUrl != null
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.2), // Was Colors.grey[850]
            width: imageUrl != null ? 2 : 1,
          ),
          image: imageUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: imageUrl != null
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: imageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh ??
                          colorScheme.surface
                              .withOpacity(0.8), // Was Colors.grey[900]
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_add_rounded,
                        color: colorScheme.onSurface.withOpacity(0.5),
                        size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).selectModel,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).tapToChooseFromLibrary,
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  // Random Selection Button
                  TextButton.icon(
                    onPressed: onRandomSelect,
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.shuffle_rounded, size: 20),
                    label: Text(AppLocalizations.of(context).surpriseMe,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(
                                0.8), // Keep black for image overlay contrast
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(22)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Toggle button (only show if alternative exists)
                          if (alternativeUrl != null && onTogglePhoto != null)
                            GestureDetector(
                              onTap: onTogglePhoto,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isShowingAlternative
                                          ? Icons.person_outline
                                          : Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isShowingAlternative
                                          ? AppLocalizations.of(context)
                                              .useOriginalPhoto
                                          : AppLocalizations.of(context)
                                              .useAiPhoto,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.2), // Keep white for overlay
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Change",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ClothList extends StatelessWidget {
  final List<WardrobeItem> clothes;
  final VoidCallback onAdd;
  final VoidCallback onRandomSelect;
  final Function(int) onRemove;

  const _ClothList({
    required this.clothes,
    required this.onAdd,
    required this.onRandomSelect,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: clothes.length + 1 + (clothes.isEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer ??
                        colorScheme.surface, // Was 0xFF1E1E1E
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline
                          .withOpacity(0.2), // Was Colors.grey[800]
                      style: BorderStyle
                          .none, // Changed to solid in real impl usually
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: colorScheme.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "Add Item",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ));
          }

          final showRandomButton = clothes.isEmpty;
          if (showRandomButton && index == 1) {
            // Random Item Button
            return GestureDetector(
                onTap: onRandomSelect,
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer ?? colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.5),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shuffle, color: colorScheme.primary, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        "Random\nPick",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ));
          }

          // Adjust index for random button possibility
          final itemIndex = index - (showRandomButton ? 2 : 1);
          if (itemIndex < 0 || itemIndex >= clothes.length)
            return const SizedBox.shrink();

          final item = clothes[itemIndex];
          final url = item.imageUrl;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainerHigh ?? colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(url),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -6,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemove(itemIndex),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.onError, width: 2),
                    ),
                    child:
                        Icon(Icons.close, color: colorScheme.onError, size: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
