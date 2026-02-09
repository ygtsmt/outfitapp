import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/core/core.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:comby/generated/l10n.dart';

/// Selection mode for the gallery picker
enum GallerySelectionMode {
  /// Single photo selection
  single,

  /// Multiple photo selection with limit
  multi,
}

/// Result from gallery selection
class GallerySelectionResult {
  /// Selected files (single or multiple)
  final List<File> selectedFiles;

  /// Whether crop was applied (only for single selection)
  final bool wasCropped;

  GallerySelectionResult({
    required this.selectedFiles,
    this.wasCropped = false,
  });

  /// Get single file (for single selection mode)
  File? get singleFile => selectedFiles.isNotEmpty ? selectedFiles.first : null;
}

/// A reusable gallery picker widget that supports both single and multi-select modes.
///
/// Usage examples:
/// ```dart
/// // Single selection with crop
/// final result = await ReusableGalleryPicker.show(
///   context: context,
///   title: 'Fotoğraf Seç',
///   mode: GallerySelectionMode.single,
///   enableCrop: true,
/// );
///
/// // Multi selection (max 50)
/// final result = await ReusableGalleryPicker.show(
///   context: context,
///   title: 'Fotoğraflar Seç',
///   mode: GallerySelectionMode.multi,
///   maxSelection: 50,
/// );
/// ```
class ReusableGalleryPicker extends StatefulWidget {
  /// Title shown in the app bar
  final String title;

  /// Selection mode (single or multi)
  final GallerySelectionMode mode;

  /// Maximum number of selections (only used in multi mode)
  final int maxSelection;

  /// Whether to enable cropping (only used in single mode)
  final bool enableCrop;

  /// Whether to show camera button
  final bool showCameraButton;

  const ReusableGalleryPicker({
    super.key,
    required this.title,
    this.mode = GallerySelectionMode.single,
    this.maxSelection = 50,
    this.enableCrop = true,
    this.showCameraButton = true,
  });

  /// Show the gallery picker and return selected files
  static Future<GallerySelectionResult?> show({
    required BuildContext context,
    required String title,
    GallerySelectionMode mode = GallerySelectionMode.single,
    int maxSelection = 50,
    bool enableCrop = true,
    bool showCameraButton = true,
  }) {
    return Navigator.of(context).push<GallerySelectionResult>(
      MaterialPageRoute(
        builder: (context) => ReusableGalleryPicker(
          title: title,
          mode: mode,
          maxSelection: maxSelection,
          enableCrop: enableCrop,
          showCameraButton: showCameraButton,
        ),
      ),
    );
  }

  @override
  State<ReusableGalleryPicker> createState() => _ReusableGalleryPickerState();
}

class _ReusableGalleryPickerState extends State<ReusableGalleryPicker> {
  List<AssetEntity> _photos = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  // Multi-select state
  final Set<AssetEntity> _selectedPhotos = {};

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
  }

  bool get _isMultiMode => widget.mode == GallerySelectionMode.multi;

  Future<void> _requestPermissionAndLoadPhotos() async {
    try {
      PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (!ps.hasAccess) {
        ps = await PhotoManager.requestPermissionExtend();
      }

      if (ps.hasAccess) {
        if (mounted) {
          setState(() {
            _hasPermission = true;
          });
        }
        await _loadPhotos();
      } else {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
          });
        }
        _showPermissionRequiredDialog();
      }
    } catch (e) {
      debugPrint("Gallery Permission Error: $e");
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showPermissionRequiredDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).galleryAccessRequired),
          content: Text(
            AppLocalizations.of(context).galleryAccessDescription,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                context.router.pop();
                context.router.pop();
              },
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                context.router.pop();
                PhotoManager.openSetting();
                Future.delayed(const Duration(seconds: 1), () {
                  _requestPermissionAndLoadPhotos();
                });
              },
              child: Text(AppLocalizations.of(context).goToSettings),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _loadPhotos() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false, // Descending order - newest first
            ),
          ],
        ),
      );

      if (albums.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final AssetPathEntity recentAlbum = albums.first;
      final List<AssetEntity> photos = await recentAlbum.getAssetListRange(
        start: 0,
        end: 1000,
      );

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    if (_isMultiMode) {
      // In multi mode, add to selection and return
      _returnWithResult([file], wasCropped: false);
    } else {
      // In single mode, optionally crop then return
      await _processSingleImage(file);
    }
  }

  Future<void> _processSingleImage(File imageFile) async {
    if (!widget.enableCrop) {
      _returnWithResult([imageFile], wasCropped: false);
      return;
    }

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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (croppedFile == null) return;

    _returnWithResult([File(croppedFile.path)], wasCropped: true);
  }

  void _onPhotoTapped(AssetEntity asset) {
    if (_isMultiMode) {
      _toggleSelection(asset);
    } else {
      _onSinglePhotoSelected(asset);
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedPhotos.contains(asset)) {
        _selectedPhotos.remove(asset);
      } else if (_selectedPhotos.length < widget.maxSelection) {
        _selectedPhotos.add(asset);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .maxPhotoSelectionLimit(widget.maxSelection)),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _onSinglePhotoSelected(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file == null || !mounted) return;

    await _processSingleImage(file);
  }

  Future<void> _onContinueWithSelection() async {
    if (_selectedPhotos.isEmpty) return;

    final List<File> files = [];
    for (final asset in _selectedPhotos) {
      final file = await asset.file;
      if (file != null) {
        files.add(file);
      }
    }

    if (files.isEmpty || !mounted) return;

    _returnWithResult(files, wasCropped: false);
  }

  void _returnWithResult(List<File> files, {required bool wasCropped}) {
    context.router.pop(GallerySelectionResult(
      selectedFiles: files,
      wasCropped: wasCropped,
    ));
  }

  void _clearSelection() {
    setState(() {
      _selectedPhotos.clear();
    });
  }

  int _getSelectionIndex(AssetEntity asset) {
    final list = _selectedPhotos.toList();
    final index = list.indexOf(asset);
    return index + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMultiMode && _selectedPhotos.isNotEmpty
            ? AppLocalizations.of(context)
                .nOfMaxSelected(_selectedPhotos.length, widget.maxSelection)
            : widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedPhotos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: AppLocalizations.of(context).clearSelection,
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: context.baseColor,
                  size: 24.h,
                ),
              )
            : !_hasPermission
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(context).galleryAccessRequired,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppLocalizations.of(context).goToSettings,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(8.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 4.h,
                      childAspectRatio: 1,
                    ),
                    itemCount:
                        _photos.length + (widget.showCameraButton ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (widget.showCameraButton && index == 0) {
                        return _buildCameraButton(context);
                      }
                      final photoIndex =
                          widget.showCameraButton ? index - 1 : index;
                      final photo = _photos[photoIndex];
                      return _buildPhotoThumbnail(photo);
                    },
                  ),
      ),
      floatingActionButton: _isMultiMode && _selectedPhotos.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: FloatingActionButton.extended(
                onPressed: _onContinueWithSelection,
                backgroundColor: context.baseColor,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  '${AppLocalizations.of(context).continueButton} (${_selectedPhotos.length}/${widget.maxSelection})',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: _pickFromCamera,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).camera,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(AssetEntity asset) {
    final isSelected = _selectedPhotos.contains(asset);
    final selectionIndex = isSelected ? _getSelectionIndex(asset) : 0;

    return GestureDetector(
      onTap: () => _onPhotoTapped(asset),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: FutureBuilder<Uint8List?>(
              future: asset.thumbnailDataWithSize(
                const ThumbnailSize(200, 200),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.baseColor,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.baseColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: context.baseColor,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 32.sp,
                  ),
                );
              },
            ),
          ),
          // Selection badge with number (only in multi mode)
          if (_isMultiMode)
            Positioned(
              top: 6.w,
              right: 6.w,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? context.baseColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? context.baseColor : Colors.grey[400]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Center(
                        child: Text(
                          '$selectionIndex',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
