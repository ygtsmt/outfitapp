import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';

import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ModelItemDetailScreen extends StatefulWidget {
  final ModelItem modelItem;

  const ModelItemDetailScreen({
    super.key,
    required this.modelItem,
  });

  @override
  State<ModelItemDetailScreen> createState() => _ModelItemDetailScreenState();
}

class _ModelItemDetailScreenState extends State<ModelItemDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final double _maxScroll = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset.clamp(-200, _maxScroll);
    });
  }

  // Progress: 0 = start, 1 = fully scrolled (image fullscreen)
  double get _progress => (_scrollOffset / _maxScroll).clamp(0.0, 1.0);

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Modeli Sil?',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bu işlem geri alınamaz.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              GetIt.I<ClosetBloc>()
                  .add(DeleteModelItemEvent(widget.modelItem.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Model silindi'),
                  backgroundColor: Colors.green,
                ),
              );
              context.router.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.modelItem;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Image size logic
    final baseImageHeight = 450.h; // Taller for models
    final fullScreenImageHeight = screenHeight;
    final imageHeight = baseImageHeight +
        (_progress * (fullScreenImageHeight - baseImageHeight));

    // BorderRadius logic
    final borderRadius = 24.r * (1 - _progress);

    // Shadow opacity
    final shadowOpacity = 0.1 + (_progress * 0.2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<ClosetBloc, ClosetState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Background with gradient
            _buildBackground(),

            // Main scrollable content
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Detaylar bölümü (üstte)
                  _buildDetailsSection(context, item),

                  // Fotoğraf (altta, scroll ile büyür)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: screenWidth - (32.w * (1 - _progress)),
                    height: imageHeight,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w * (1 - _progress),
                    ),
                    child: Hero(
                      tag: 'model_item_${item.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(shadowOpacity),
                              blurRadius: 30 + (_progress * 20),
                              offset: Offset(0, -10 - (_progress * 10)),
                              spreadRadius: _progress * 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[50],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[50],
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey[400],
                                size: 48.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Extra space at bottom
                  SizedBox(height: 100.h),
                ],
              ),
            ),

            // Fixed app bar
            SafeArea(
              child: _buildAppBar(context),
            ),

            // Scroll indicator
            if (_progress < 0.3)
              Positioned(
                bottom: 50.h,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: 1 - (_progress * 3),
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 28.sp,
                      ),
                      Text(
                        'Kaydırarak görseli büyüt',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
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

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color.lerp(Colors.white, Colors.grey[100], _progress)!,
          ],
        ),
      ),
      child: Opacity(
        opacity: 0.03 * (1 - _progress),
        child: Center(
          child: Image.asset(
            'assets/png/logo.png', // Ensure this asset exists, copied from other screen
            width: 200.w,
            height: 200.w,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final item = widget.modelItem;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri butonu
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.grey[800],
                size: 18.sp,
              ),
            ),
            onPressed: () => context.router.pop(),
          ),

          // Sağ taraftaki butonlar
          Row(
            children: [
              // Fullscreen butonu
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _progress > 0.5 ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: _progress > 0.5 ? 1.0 : 0.8,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Theme.of(context).primaryColor,
                        size: 20.sp,
                      ),
                    ),
                    onPressed: _progress > 0.5
                        ? () => _openFullscreenViewer(context, item)
                        : null,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Sil butonu
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[400],
                    size: 20.sp,
                  ),
                ),
                onPressed: () => _deleteItem(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFullscreenViewer(BuildContext context, ModelItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Hero(
                        tag: 'fullscreen_model_${item.id}',
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16.h,
                    right: 16.w,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, ModelItem item) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: 1.0 - (_progress * 0.8),
      child: Container(
        padding: EdgeInsets.fromLTRB(32.w, 100.h, 32.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model Name
            Text(
              _capitalizeFirst(item.name ?? 'İsimsiz Model'),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w300,
                color: Colors.grey[900],
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),

            if (item.gender != null && item.gender!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                item.gender!.toUpperCase(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 2.5,
                ),
              ),
            ],

            SizedBox(height: 32.h),

            // Divider
            Container(
              width: 50.w,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.5),
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            SizedBox(height: 32.h),

            // Details grid
            _buildDetailsGrid(context, item),

            SizedBox(height: 32.h),

            _buildAIBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, ModelItem item) {
    final details = <MapEntry<String, String>>[];

    if (item.bodyPart != null) {
      details.add(MapEntry('Görünüm', _formatBodyPart(item.bodyPart!)));
    }
    if (item.bodyType != null) {
      details.add(MapEntry('Vücut Tipi', _capitalizeFirst(item.bodyType!)));
    }
    if (item.skinTone != null) {
      details.add(MapEntry('Ten Rengi', _capitalizeFirst(item.skinTone!)));
    }
    if (item.pose != null) {
      details.add(MapEntry('Poz', _capitalizeFirst(item.pose!)));
    }

    // Add create date as a detail
    details.add(
        MapEntry('Tarih', DateFormat('dd MMM yyyy').format(item.createdAt)));

    return Wrap(
      spacing: 40.w,
      runSpacing: 28.h,
      children: details.map((entry) {
        return _buildDetailItem(
          context,
          label: entry.key,
          value: entry.value,
        );
      }).toList(),
    );
  }

  String _formatBodyPart(String part) {
    switch (part.toLowerCase()) {
      case 'full_body':
        return 'Tam Boy';
      case 'upper_body':
        return 'Üst Vücut';
      case 'lower_body':
        return 'Alt Vücut';
      case 'face_only':
        return 'Sadece Yüz';
      default:
        return _capitalizeFirst(part.replaceAll('_', ' '));
    }
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return SizedBox(
      width: 120.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 14.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8.w),
          Text(
            'Gemini 3 ile analiz edildi',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
