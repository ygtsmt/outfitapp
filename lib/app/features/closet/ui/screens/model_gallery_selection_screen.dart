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

class ModelGallerySelectionScreen extends StatefulWidget {
  const ModelGallerySelectionScreen({super.key});

  @override
  State<ModelGallerySelectionScreen> createState() =>
      _ModelGallerySelectionScreenState();
}

class _ModelGallerySelectionScreenState
    extends State<ModelGallerySelectionScreen> {
  List<AssetEntity> _photos = [];
  bool _isLoading = true;
  bool _hasPermission = false;

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
            'Fotoğraflarınızı seçebilmek için galeri erişimine izin vermeniz gerekiyor.',
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
            'Tüm fotoğraflarınızı görebilmek için tam erişim izni verebilirsiniz.',
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

    // Model form ekranına git ve sonucu bekle
    if (context.mounted) {
      final result = await context.router.push(
        ModelItemFormScreenRoute(imageFile: croppedImageFile),
      );

      // Eğer başarılı bir şekilde model eklendiyse, bu ekranı da kapat ve sonucu ilet
      if (result != null && context.mounted) {
        context.router.pop(result);
      }
    }
  }

  Future<void> _onPhotoSelected(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file == null || !context.mounted) return;

    await _processImage(context, file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Fotoğrafı Seç'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
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
    return GestureDetector(
      onTap: () => _onPhotoSelected(asset),
      child: ClipRRect(
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
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
    );
  }
}
