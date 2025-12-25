import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ginly/app/features/closet/data/closet_usecase.dart';
import 'package:ginly/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:ginly/app/features/try_on/ui/widgets/user_selection_sheet.dart';
import 'package:ginly/core/core.dart';
import 'dart:io';
import 'package:ginly/app/features/closet/models/model_item_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'package:ginly/app/features/closet/models/closet_item_model.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ginly/app/features/closet/ui/widgets/models_tab_content.dart'; // Might be needed for some widgets or just use generic
// import 'package:sizer/sizer.dart'; // Removed Sizer

// Helper class for local colors since AppColors is not found
class LocalColors {
  static const Color background = Color(0xFF121212);
  static const Color primary = Color(0xFFE94057);
}

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  final FalAiUsecase _falAiUsecase = GetIt.I<FalAiUsecase>();
  final ClosetUseCase _closetUseCase = GetIt.I<ClosetUseCase>();

  ModelItem? _selectedModel; // Changed from String? _selectedModelUrl
  final List<String> _selectedClothesUrls = [];

  bool _isLoading = false;
  String? _statusMessage;
  String? _requestId;

  Future<void> _generateImage() async {
    if (_selectedModel == null || _selectedClothesUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a model and at least one cloth')),
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
        ..._selectedClothesUrls
      ];

      final result = await _falAiUsecase.generateGeminiImageEdit(
        imageUrls: imageUrls,
        prompt: "Wear clothes", // Base prompt
        modelAiPrompt: _selectedModel!.aiPrompt, // Pass the model's AI prompt
      );

      if (result != null && result['status'] == 'processing') {
        setState(() {
          _statusMessage = 'Request sent successfully!';
          _requestId = result['id'];
        });
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

    if (result is ClosetItem) {
      if (!_selectedClothesUrls.contains(result.imageUrl)) {
        setState(() {
          _selectedClothesUrls.add(result.imageUrl);
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

      if (result is ClosetItem) {
        if (!_selectedClothesUrls.contains(result.imageUrl)) {
          setState(() {
            _selectedClothesUrls.add(result.imageUrl);
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
          title: 'Select Model',
          fetchItems: () async => await _closetUseCase.getUserModelItems(),
          leadingItems: [
            _buildSelectionOption(
              context,
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: _openGallerySelection,
            ),
            _buildSelectionOption(
              context,
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
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
        title: 'Select Cloth',
        fetchItems: () async => await _closetUseCase.getUserClosetItems(),
        leadingItems: [
          _buildSelectionOption(
            context,
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: _openClosetGallerySelection,
          ),
          _buildSelectionOption(
            context,
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onTap: _openClosetCameraSelection,
          ),
        ],
        onSelected: (item) {
          if (item is ClosetItem) {
            if (!_selectedClothesUrls.contains(item.imageUrl)) {
              setState(() {
                _selectedClothesUrls.add(item.imageUrl);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Was LocalColors.background
      appBar: AppBar(
        title: const Text(
          'Virtual Studio',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                        context, "MODEL", "Select who will try on the clothes"),
                    const SizedBox(height: 16),
                    _ModelSelector(
                      imageUrl: _selectedModel?.imageUrl,
                      onTap: _showModelSelection,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildSectionTitle(
                              context, "WARDROBE", "Pick items to mix & match"),
                        ),
                        if (_selectedClothesUrls.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "${_selectedClothesUrls.length} selected",
                              style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ClothList(
                      clothes: _selectedClothesUrls,
                      onAdd: _showClothSelection,
                      onRemove: (index) {
                        setState(() {
                          _selectedClothesUrls.removeAt(index);
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_statusMessage != null) _buildStatusCard(context),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
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

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer ??
            colorScheme.surface, // Was 0xFF1E1E1E
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isLoading ||
                  _selectedModel == null ||
                  _selectedClothesUrls.isEmpty
              ? null
              : _generateImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // Was 0xFFE94057
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: colorScheme.onPrimary, strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    const Text("Processing Studio..."),
                  ],
                )
              : const Text(
                  'Visualize Outfit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const _ModelSelector({required this.imageUrl, required this.onTap});

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
                    "Select a Model",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to choose from library",
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
  final List<String> clothes;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const _ClothList({
    required this.clothes,
    required this.onAdd,
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
        itemCount: clothes.length + 1,
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

          final url = clothes[index - 1];
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
                  onTap: () => onRemove(index - 1),
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
