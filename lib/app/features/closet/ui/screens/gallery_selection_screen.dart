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

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    // İzin kontrolü - önce mevcut durumu kontrol et
    PermissionState ps = await PhotoManager.requestPermissionExtend();

    // İzin yoksa, otomatik olarak izin iste
    if (!ps.hasAccess) {
      // İzin iste (tekrar tam izin isteği)
      ps = await PhotoManager.requestPermissionExtend();
    }

    // İzin kontrolü
    if (ps.hasAccess) {
      setState(() {
        _hasPermission = true;
      });
      await _loadPhotos();

      // Yarım izin varsa, kullanıcıya tam izin isteği göster
      if (ps.isLimited) {
        _showLimitedAccessDialog();
      }
    } else {
      // İzin reddedildi, ayarlara yönlendir
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });

      // Kullanıcıya izin gerekli olduğunu göster
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
                context.router.pop(); // Galeri ekranından çık
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                PhotoManager.openSetting();
                // Ayarlardan dönünce tekrar kontrol et
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
      // Tüm albümleri al
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

      // İlk albümden tüm fotoğrafları al (genellikle "All Photos")
      final AssetPathEntity recentAlbum = albums.first;
      final List<AssetEntity> photos = await recentAlbum.getAssetListRange(
        start: 0,
        end: 1000, // İlk 1000 fotoğraf
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
    // Crop işlemi
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

    // Form ekranına git
    if (context.mounted) {
      context.router.push(
        ClosetItemFormScreenRoute(imageFile: croppedImageFile),
      );
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
        title: const Text('Fotoğraf Seç'),
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
                    itemCount: _photos.length + 1, // +1 for camera button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Kamera butonu
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
