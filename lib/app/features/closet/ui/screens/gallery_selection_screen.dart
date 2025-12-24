import 'dart:io';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/core/core.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class GallerySelectionScreen extends StatefulWidget {
  const GallerySelectionScreen({super.key});

  @override
  State<GallerySelectionScreen> createState() => _GallerySelectionScreenState();
}

class _GallerySelectionScreenState extends State<GallerySelectionScreen> {
  List<AssetEntity> _photos = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  // Multi-select state
  bool _isMultiSelectMode = true; // Default to multi-select
  final Set<AssetEntity> _selectedPhotos = {};
  static const int _maxSelections = 50;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.hasAccess) {
      ps = await PhotoManager.requestPermissionExtend();
    }

    if (ps.hasAccess) {
      setState(() {
        _hasPermission = true;
      });
      await _loadPhotos();

      if (ps.isLimited) {
        _showLimitedAccessDialog();
      }
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
      _showPermissionRequiredDialog();
    }
  }

  void _showPermissionRequiredDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Galeri Erişimi Gerekli'),
          content: const Text(
            'Fotoğraflarınızı seçebilmek için galeri erişimine izin vermeniz gerekiyor. Lütfen ayarlara gidip galeri erişimi için izin verin.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.router.pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                PhotoManager.openSetting();
                Future.delayed(const Duration(seconds: 1), () {
                  _requestPermissionAndLoadPhotos();
                });
              },
              child: const Text('Ayarlara Git'),
            ),
          ],
        ),
      );
    });
  }

  void _showLimitedAccessDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tam Erişim Gerekli'),
          content: const Text(
            'Tüm fotoğraflarınızı görebilmek için galeri erişimine tam izin vermeniz gerekiyor. Ayarlara gidip tam erişim izni verebilirsiniz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                PhotoManager.openSetting();
              },
              child: const Text('Ayarlara Git'),
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

  Future<void> _pickFromSource(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    await _processImage(context, File(pickedFile.path));
  }

  Future<void> _processImage(BuildContext context, File imageFile) async {
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (croppedFile == null) return;

    final croppedImageFile = File(croppedFile.path);

    if (context.mounted) {
      final result = await context.router.push(
        ClosetItemFormScreenRoute(imageFile: croppedImageFile),
      );

      if (result != null && context.mounted) {
        context.router.pop(result);
      }
    }
  }

  void _onPhotoTapped(AssetEntity asset) {
    if (_isMultiSelectMode) {
      _toggleSelection(asset);
    } else {
      _onSinglePhotoSelected(asset);
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedPhotos.contains(asset)) {
        _selectedPhotos.remove(asset);
      } else if (_selectedPhotos.length < _maxSelections) {
        _selectedPhotos.add(asset);
      } else {
        // Show max selection warning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maksimum $_maxSelections fotoğraf seçebilirsiniz'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _onSinglePhotoSelected(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file == null || !context.mounted) return;

    await _processImage(context, file);
  }

  Future<void> _onContinueWithSelection() async {
    if (_selectedPhotos.isEmpty) return;

    // Convert selected assets to files
    final List<File> files = [];
    for (final asset in _selectedPhotos) {
      final file = await asset.file;
      if (file != null) {
        files.add(file);
      }
    }

    if (files.isEmpty || !mounted) return;

    // Navigate to batch upload progress screen
    context.router.push(
      BatchUploadProgressScreenRoute(imageFiles: files),
    );
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
        title: Text(_isMultiSelectMode && _selectedPhotos.isNotEmpty
            ? '${_selectedPhotos.length} / $_maxSelections seçildi'
            : 'Fotoğraf Seç'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          if (_selectedPhotos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Seçimi Temizle',
            ),
          // Toggle between single and multi-select
          IconButton(
            icon: Icon(_isMultiSelectMode ? Icons.photo : Icons.photo_library),
            onPressed: () {
              setState(() {
                _isMultiSelectMode = !_isMultiSelectMode;
                if (!_isMultiSelectMode) {
                  _selectedPhotos.clear();
                }
              });
            },
            tooltip: _isMultiSelectMode ? 'Tekli Seçim' : 'Çoklu Seçim',
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
                          'Galeri erişimi gerekli',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Ayarlardan izin verin',
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
                    itemCount: _photos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCameraButton(context);
                      }
                      final photo = _photos[index - 1];
                      return _buildPhotoThumbnail(photo);
                    },
                  ),
      ),
      // Floating action button for multi-select
      floatingActionButton: _isMultiSelectMode && _selectedPhotos.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: FloatingActionButton.extended(
                onPressed: _onContinueWithSelection,
                backgroundColor: context.baseColor,
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  'Devam Et (${_selectedPhotos.length}/$_maxSelections)',
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
      onTap: () => _pickFromSource(context, ImageSource.camera),
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
              'Kamera',
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
                      // Selection overlay
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
          // Selection badge with number
          if (_isMultiSelectMode)
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
