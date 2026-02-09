import 'package:auto_route/auto_route.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/ui/closet_screen.dart';
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:comby/app/features/try_on/ui/widgets/user_selection_sheet.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/core/utils.dart';
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

  const VirtualCabinTabContent({
    super.key,
    this.initialModel,
    this.initialClothes,
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
  // _useAlternativePhoto removed

  bool _isLoading = false;
  String? _statusMessage;
  String? _requestId;

  // Carousel State
  List<ModelItem> _allModels = [];
  late PageController _pageController;

  // Cloth Carousel State
  List<WardrobeItem> _allClothes = [];
  late PageController _clothPageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
    _selectedClothes =
        widget.initialClothes != null ? List.from(widget.initialClothes!) : [];

    // Default controller
    _pageController = PageController(viewportFraction: 0.85);
    _clothPageController =
        PageController(viewportFraction: 0.4); // Smaller fraction for clothes

    // Trigger fetch if needed
    getIt<ClosetBloc>().add(const GetUserClosetItemsEvent());
    getIt<ClosetBloc>().add(const GetUserModelItemsEvent());
  }

  // Removed _loadModels as we will use BlocBuilder

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
        statusBarColor: Color(0xFF452D54),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF452D54),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Color(0xFF452D54),
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

    return BlocBuilder<ClosetBloc, ClosetState>(
      builder: (context, state) {
        // Update local lists from state if available
        if (state.closetItems != null) {
          _allClothes = state.closetItems!;

          // Reorder logic (optional, keep selected first)
          if (_selectedClothes.isNotEmpty) {
            final selectedIds = _selectedClothes.map((e) => e.imageUrl).toSet();
            final selectedItems = _allClothes
                .where((item) => selectedIds.contains(item.imageUrl))
                .toList();
            final otherItems = _allClothes
                .where((item) => !selectedIds.contains(item.imageUrl))
                .toList();
            _allClothes = [...selectedItems, ...otherItems];
          }
        }

        if (state.modelItems != null) {
          _allModels = state.modelItems!;
          if (_selectedModel == null && _allModels.isNotEmpty) {
            _selectedModel = _allModels[0];
          }
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FilledButton(
            onPressed:
                _isLoading || _selectedModel == null || _selectedClothes.isEmpty
                    ? () {
                        if (_selectedModel == null) {
                          Utils.showToastMessage(
                            content: 'Please select a model',
                            context: context,
                          );
                        }
                        if (_selectedClothes.isEmpty) {
                          Utils.showToastMessage(
                            content: 'Please select a clothing item',
                            context: context,
                          );
                        }
                      }
                    : _generateImage,
            style: FilledButton.styleFrom(
              backgroundColor: (_isLoading ||
                      _selectedModel == null ||
                      _selectedClothes.isEmpty)
                  ? context.white
                  : colorScheme.primary,
              foregroundColor: (_isLoading ||
                      _selectedModel == null ||
                      _selectedClothes.isEmpty)
                  ? colorScheme.primary
                  : colorScheme.onPrimary,
              elevation: 4,
              shape: const StadiumBorder(), // yuvarlak-pill görünüm
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    'Generate',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _buildSectionTitle(
                    context,
                    AppLocalizations.of(context).model.toUpperCase(),
                    AppLocalizations.of(context).modelSubtitle),
                const SizedBox(height: 8),
                Expanded(
                  flex: 5,
                  child: _ModelSelector(
                    models: _allModels,
                    pageController: _pageController,
                    selectedModel: _selectedModel,
                    onPageChanged: (index) {
                      setState(() {
                        // Index 0 = Add Card
                        // Index length + 1 = Add Card
                        // Valid models are at 1..length
                        if (index > 0 && index <= _allModels.length) {
                          _selectedModel = _allModels[index - 1]; // Offset by 1
                        }
                      });
                    },
                    onTap: _showModelSelection,
                    onAddPressed: _showModelSelection,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildSectionTitle(
                          context,
                          AppLocalizations.of(context).homeCloset.toUpperCase(),
                          AppLocalizations.of(context).wardrobeSubtitle),
                    ),
                    if (_selectedClothes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, right: 16),
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
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: _ClothList(
                    allClothes: _allClothes,
                    selectedClothes: _selectedClothes,
                    pageController: _clothPageController,
                    onAdd: _showClothSelection,
                    onToggleSelection: (item) {
                      setState(() {
                        if (_selectedClothes
                            .any((e) => e.imageUrl == item.imageUrl)) {
                          _selectedClothes
                              .removeWhere((e) => e.imageUrl == item.imageUrl);
                        } else {
                          _selectedClothes.add(item);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (_statusMessage != null) _buildStatusCard(context),
                // Replaced button with FAB, so we keep the column clean but might need spacing at bottom if FAB overlaps content too much.
                // However, with Expanded flex, the layout fills screen.
                // The FAB is bottom-right. It might overlap the ClothList or StatusCard.
                // StatusCard is at valid bottom.
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
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
              color:
                  colorScheme.onSurface.withOpacity(0.7), // Was Colors.white70
              fontSize: 14,
            ),
          ),
        ],
      ),
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

// Carousel Dimensions Configuration using ScreenUtil
// Carousel Dimensions Configuration using ScreenUtil
// All dimensions are now responsive using LayoutBuilder and Expanded.

class _ModelSelector extends StatelessWidget {
  final List<ModelItem> models;
  final PageController? pageController;
  final ModelItem? selectedModel;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback onTap;
  final VoidCallback? onAddPressed;

  const _ModelSelector({
    required this.models,
    this.pageController,
    this.selectedModel,
    this.onPageChanged,
    required this.onTap,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (models.isEmpty) {
      // Empty State -> Show "Add Model" button
      return GestureDetector(
        onTap: onAddPressed,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh ??
                      colorScheme.surface.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_rounded,
                    color: colorScheme.onSurface.withOpacity(0.5), size: 40.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).selectModel,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Logic matching _ClothList:
    // If empty -> 1 item (Add Card)
    // If not empty -> length + 2 (Start Add + Models + End Add)
    final int distinctItems = models.length;
    final int totalCount = distinctItems == 0 ? 1 : distinctItems + 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        return PageView.builder(
          controller: pageController,
          itemCount: totalCount,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            bool isAddCard = false;
            if (models.isEmpty) {
              isAddCard = true;
            } else {
              if (index == 0 || index == totalCount - 1) {
                isAddCard = true;
              }
            }

            Widget content;
            if (isAddCard) {
              content = GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer ?? colorScheme.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh ??
                              colorScheme.surface.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_a_photo_rounded,
                            color: colorScheme.primary, size: 40.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(context).selectModel,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final model = models[index - 1];
              content = GestureDetector(
                onTap: () {
                  onTap();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: selectedModel?.id == model.id
                          ? colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                    /*  boxShadow: [
                      if (selectedModel?.id == model.id)
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                    ], */
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(model.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }

            return AnimatedBuilder(
              animation: pageController!,
              builder: (context, child) {
                double value = 1.0;
                if (pageController!.position.haveDimensions) {
                  value = pageController!.page! - index;
                  value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                } else {
                  value = (index == (pageController!.initialPage)) ? 1.0 : 0.7;
                }

                return Center(
                  child: SizedBox(
                    height:
                        Curves.easeOut.transform(value) * constraints.maxHeight,
                    width: Curves.easeOut.transform(value) *
                        (constraints.maxHeight * 0.9), // Aspect ratio
                    child: child,
                  ),
                );
              },
              child: content,
            );
          },
        );
      },
    );
  }
}

class _ClothList extends StatelessWidget {
  final List<WardrobeItem> allClothes;
  final List<WardrobeItem> selectedClothes;
  final PageController? pageController;
  final VoidCallback onAdd;
  final Function(WardrobeItem) onToggleSelection;

  const _ClothList({
    required this.allClothes,
    required this.selectedClothes,
    this.pageController,
    required this.onAdd,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Item count:
    // 1 for Start "Add Card"
    // allClothes.length for items
    // 1 for End "Add Card"
    // Total = allClothes.length + 2;
    // If empty: 1 (Start Add) + 0 + 1 (End Add) => 2 Add cards might be weird.
    // Let's stick to "Add" at start and end. If empty, you see two add cards or maybe just one?
    // User asked for "Add item card at both ends". So even if empty, technicaly start/end is same.
    // If empty, let's just show ONE add card.
    final int distinctItems = allClothes.length;
    final int totalCount = distinctItems == 0 ? 1 : distinctItems + 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        return PageView.builder(
          controller: pageController,
          padEnds: false, // Align left nicely if needed, or keep centered
          itemCount: totalCount,
          itemBuilder: (context, index) {
            // Identify if it is an Add Card
            bool isAddCard = false;
            if (distinctItems == 0) {
              isAddCard = true;
            } else {
              if (index == 0 || index == totalCount - 1) {
                isAddCard = true;
              }
            }

            // If item, which one?
            // Index 0 = Add
            // Index 1 = Cloth[0]
            // ...
            // Index N = Add
            // So clothIndex = index - 1
            WardrobeItem? clothItem;
            if (!isAddCard) {
              clothItem = allClothes[index - 1];
            }

            Widget content;
            if (isAddCard) {
              content = GestureDetector(
                onTap: onAdd,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer ?? colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh ??
                              colorScheme.surface.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded,
                            color: colorScheme.primary, size: 28.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Add Cloth",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              content = GestureDetector(
                onTap: () => onToggleSelection(clothItem!),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: selectedClothes
                                  .any((e) => e.imageUrl == clothItem!.imageUrl)
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image:
                              CachedNetworkImageProvider(clothItem!.imageUrl),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    // Checkbox Overlay
                    Positioned(
                      top: 8.h,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: selectedClothes
                                  .any((e) => e.imageUrl == clothItem!.imageUrl)
                              ? colorScheme.primary
                              : Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxHeight, // Wider for cloth
                child: content,
              ),
            );
          },
        );
      },
    );
  }
}
