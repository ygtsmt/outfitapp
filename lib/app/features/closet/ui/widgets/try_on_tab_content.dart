import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginly/app/features/closet/models/closet_item_model.dart';
import 'package:ginly/app/features/closet/models/model_item_model.dart';
import 'package:ginly/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class TryOnTabContent extends StatefulWidget {
  const TryOnTabContent({super.key});

  @override
  State<TryOnTabContent> createState() => _TryOnTabContentState();
}

class _TryOnTabContentState extends State<TryOnTabContent> {
  // Seçilen görseller - index 0: Model, index 1-2: Closet items
  String? selectedModelImageUrl;
  String? selectedClosetItem1ImageUrl;
  String? selectedClosetItem2ImageUrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),
          // 3 kutu
          _buildSelectionBoxes(),
        ],
      ),
    );
  }

  Widget _buildSelectionBoxes() {
    return Column(
      children: [
        // Model kutusu (üstte, tek)
        _buildBox(
          label: 'Model',
          imageUrl: selectedModelImageUrl,
          onTap: () => _showSelectionBottomSheet(0),
        ),
        SizedBox(height: 24.h),
        // Closet item kutuları (altta, 2 adet)
        Row(
          children: [
            Expanded(
              child: _buildBox(
                label: 'Closet 1',
                imageUrl: selectedClosetItem1ImageUrl,
                onTap: () => _showSelectionBottomSheet(1),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildBox(
                label: 'Closet 2',
                imageUrl: selectedClosetItem2ImageUrl,
                onTap: () => _showSelectionBottomSheet(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBox({
    required String label,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: imageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tıklayarak seç',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl.startsWith('http') ||
                              imageUrl.startsWith('https')
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: LoadingAnimationWidget.fourRotatingDots(
                                  color: context.baseColor,
                                  size: 16.h,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[400],
                                  size: 48.sp,
                                ),
                              ),
                            )
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[400],
                                  size: 48.sp,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.baseColor,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showSelectionBottomSheet(int boxIndex) {
    if (boxIndex == 0) {
      // Model seçimi için özel bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _ModelSelectionBottomSheet(
          onImageSelected: (imageUrl) {
            setState(() {
              selectedModelImageUrl = imageUrl;
            });
          },
        ),
      );
    } else {
      // Closet seçimi için mevcut bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _TryOnSelectionBottomSheet(
          boxIndex: boxIndex,
          onImageSelected: (imageUrl) {
            setState(() {
              if (boxIndex == 1) {
                selectedClosetItem1ImageUrl = imageUrl;
              } else if (boxIndex == 2) {
                selectedClosetItem2ImageUrl = imageUrl;
              }
            });
          },
        ),
      );
    }
  }
}

class _TryOnSelectionBottomSheet extends StatefulWidget {
  final int boxIndex;
  final Function(String imageUrl) onImageSelected;

  const _TryOnSelectionBottomSheet({
    required this.boxIndex,
    required this.onImageSelected,
  });

  @override
  State<_TryOnSelectionBottomSheet> createState() =>
      _TryOnSelectionBottomSheetState();
}

class _TryOnSelectionBottomSheetState
    extends State<_TryOnSelectionBottomSheet> {
  String? selectedSource; // 'closet' veya 'models' veya null
  List<AssetEntity> _photos = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    // Closet ve Models verilerini yükle
    getIt<ClosetBloc>().add(const GetUserClosetItemsEvent());
    getIt<ClosetBloc>().add(const GetUserModelItemsEvent());
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
    }
  }

  void _showLimitedAccessDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tam Erişim Gerekli'),
          content: const Text(
            'Tüm fotoğraflarınızı görebilmek için galeri erişimine tam izin vermeniz gerekiyor.',
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

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null || !mounted) return;

    // TODO: Burada imageUrl'i almak için fotoğrafı upload etmek gerekebilir
    // Şimdilik local file path'i kullanıyoruz (geliştirme için)
    // Gerçek uygulamada Firebase Storage'a upload edip URL alınmalı

    // Örnek olarak sadece file path'i gösteriyoruz
    if (mounted) {
      Navigator.of(context).pop();
      widget.onImageSelected(pickedFile.path);
    }
  }

  void _selectFromCloset() {
    setState(() {
      selectedSource = 'closet';
    });
  }

  void _selectFromModels() {
    setState(() {
      selectedSource = 'models';
    });
  }

  Future<void> _onPhotoSelected(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file == null || !mounted) return;

    // TODO: Burada imageUrl'i almak için fotoğrafı upload etmek gerekebilir
    // Şimdilik local file path'i kullanıyoruz
    Navigator.of(context).pop();
    widget.onImageSelected(file.path);
  }

  Widget _buildClosetOrModelsSelection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectFromCloset,
              icon: const Icon(Icons.checkroom),
              label: const Text('Closet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSource == 'closet'
                    ? context.baseColor
                    : Colors.grey[300],
                foregroundColor: selectedSource == 'closet'
                    ? Colors.white
                    : Colors.grey[700],
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectFromModels,
              icon: const Icon(Icons.person),
              label: const Text('Models'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSource == 'models'
                    ? context.baseColor
                    : Colors.grey[300],
                foregroundColor: selectedSource == 'models'
                    ? Colors.white
                    : Colors.grey[700],
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Closet/Models seçim butonları
              _buildClosetOrModelsSelection(),
              Divider(height: 1),
              // İçerik
              Expanded(
                child: selectedSource == null
                    ? Center(
                        child: Text(
                          'Önce Closet veya Models seçin',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : selectedSource == 'closet' || selectedSource == 'models'
                        ? _buildClosetOrModelsContent(scrollController)
                        : _hasPermission
                            ? _buildGalleryContent(scrollController)
                            : Center(
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
                                    SizedBox(height: 24.h),
                                    ElevatedButton(
                                      onPressed: () {
                                        PhotoManager.openSetting();
                                        Future.delayed(
                                            const Duration(seconds: 1), () {
                                          _requestPermissionAndLoadPhotos();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.baseColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Ayarlara Git'),
                                    ),
                                  ],
                                ),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClosetOrModelsContent(ScrollController scrollController) {
    return BlocBuilder<ClosetBloc, ClosetState>(
      builder: (context, state) {
        final isLoading = selectedSource == 'closet'
            ? (state.gettingClosetItemsStatus == EventStatus.processing &&
                state.closetItems == null)
            : (state.gettingModelItemsStatus == EventStatus.processing &&
                state.modelItems == null);

        if (isLoading) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: context.baseColor,
              size: 24.h,
            ),
          );
        }

        if (selectedSource == 'closet') {
          final closetItems = state.closetItems ?? [];
          if (closetItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Closet içeriği bulunamadı',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.85,
            ),
            itemCount: closetItems.length + 1, // +1 for camera button
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCameraButton();
              }
              final item = closetItems[index - 1];
              return _buildClosetItem(item);
            },
          );
        } else {
          final modelItems = state.modelItems ?? [];
          if (modelItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Model içeriği bulunamadı',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.75,
            ),
            itemCount: modelItems.length + 1, // +1 for camera button
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCameraButton();
              }
              final item = modelItems[index - 1];
              return _buildModelItem(item);
            },
          );
        }
      },
    );
  }

  Widget _buildGalleryContent(ScrollController scrollController) {
    if (_isLoading) {
      return Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: context.baseColor,
          size: 24.h,
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
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
          return _buildCameraButton();
        }
        final photo = _photos[index - 1];
        return _buildPhotoThumbnail(photo);
      },
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _pickFromCamera,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildClosetItem(ClosetItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        widget.onImageSelected(item.imageUrl);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: context.baseColor,
                      size: 12.h,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              if (item.category != null)
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      item.category!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelItem(ModelItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        widget.onImageSelected(item.imageUrl);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: context.baseColor,
                      size: 12.h,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              if (item.name != null && item.name!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      item.name!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
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

class _ModelSelectionBottomSheet extends StatefulWidget {
  final Function(String imageUrl) onImageSelected;

  const _ModelSelectionBottomSheet({
    required this.onImageSelected,
  });

  @override
  State<_ModelSelectionBottomSheet> createState() =>
      _ModelSelectionBottomSheetState();
}

class _ModelSelectionBottomSheetState
    extends State<_ModelSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Model item'ları yükle
    getIt<ClosetBloc>().add(const GetUserModelItemsEvent());
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null || !mounted) return;

    // TODO: Firebase Storage'a upload edip URL alınmalı
    if (mounted) {
      Navigator.of(context).pop();
      widget.onImageSelected(pickedFile.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || !mounted) return;

    // TODO: Firebase Storage'a upload edip URL alınmalı
    if (mounted) {
      Navigator.of(context).pop();
      widget.onImageSelected(pickedFile.path);
    }
  }

  void _onModelSelected(ModelItem model) {
    Navigator.of(context).pop();
    widget.onImageSelected(model.imageUrl);
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _pickFromCamera,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: _pickFromGallery,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 32.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 8.h),
            Text(
              'Galeri',
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // İçerik
              Expanded(
                child: BlocBuilder<ClosetBloc, ClosetState>(
                  builder: (context, state) {
                    final modelItems = state.modelItems ?? [];
                    final isLoadingModels = state.gettingModelItemsStatus ==
                            EventStatus.processing &&
                        state.modelItems == null;

                    if (isLoadingModels) {
                      return Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: context.baseColor,
                          size: 24.h,
                        ),
                      );
                    }

                    if (modelItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: 64.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Model bulunamadı',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(8.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: modelItems.length +
                          2, // +2 for camera and gallery buttons
                      itemBuilder: (context, index) {
                        // İlk eleman: Kamera butonu
                        if (index == 0) {
                          return _buildCameraButton();
                        }
                        // İkinci eleman: Galeri butonu
                        if (index == 1) {
                          return _buildGalleryButton();
                        }
                        // Sonraki elemanlar: Model item'ları
                        final modelIndex = index - 2;
                        final model = modelItems[modelIndex];
                        return _buildModelItem(model);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModelItem(ModelItem item) {
    return GestureDetector(
      onTap: () => _onModelSelected(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: context.baseColor,
                      size: 12.h,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              if (item.name != null && item.name!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      item.name!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
