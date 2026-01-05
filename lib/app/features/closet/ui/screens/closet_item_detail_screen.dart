import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/models/closet_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/routes/app_router.dart';

class ClosetItemDetailScreen extends StatefulWidget {
  final ClosetItem closetItem;

  const ClosetItemDetailScreen({
    super.key,
    required this.closetItem,
  });

  @override
  State<ClosetItemDetailScreen> createState() => _ClosetItemDetailScreenState();
}

class _ClosetItemDetailScreenState extends State<ClosetItemDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  double _maxScroll = 400;

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

  // Progress: 0 = başlangıç, 1 = tam scroll edildi (fotoğraf tam ekran)
  double get _progress => (_scrollOffset / _maxScroll).clamp(0.0, 1.0);

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Silmek istiyor musunuz?',
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
    final item = widget.closetItem;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Fotoğraf boyutu - scroll ilerledikçe büyür
    final baseImageHeight = 280.h;
    final fullScreenImageHeight = screenHeight;
    final imageHeight = baseImageHeight +
        (_progress * (fullScreenImageHeight - baseImageHeight));

    // Border radius - tam ekran olunca 0
    final borderRadius = 24.r * (1 - _progress);

    // Gölge opacity
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
                      tag: 'closet_item_${item.id}',
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
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[50],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: context.baseColor,
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
                            _buildSimilarItemsSection(context, item),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Benzer Ürünler bölümü

                  // Alt boşluk
                ],
              ),
            ),

            // Fixed app bar
            SafeArea(
              child: _buildAppBar(context),
            ),

            // Scroll indicator (aşağı kaydır göstergesi)
            if (_progress < 0.3)
              Positioned(
                bottom: 100.h,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: 1 - (_progress * 3),
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[400],
                        size: 28.sp,
                      ),
                      Text(
                        'Kaydırarak görseli büyüt',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[400],
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

  Widget _buildAppBar(BuildContext context) {
    final item = widget.closetItem;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
              // Fullscreen butonu - scroll ilerleyince görünür
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
                        color: context.baseColor,
                        size: 20.sp,
                      ),
                    ),
                    onPressed: _progress > 0.5
                        ? () => _openFullscreenViewer(context, item)
                        : null,
                  ),
                ),
              ),

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
                    color: Colors.grey[600],
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

  void _openFullscreenViewer(BuildContext context, ClosetItem item) {
    // Renk bazlı arka plan belirleme
    final itemColor = item.color?.toLowerCase() ?? '';
    final isDarkColor = itemColor.contains('black') ||
        itemColor.contains('navy') ||
        itemColor.contains('dark');
    final backgroundColor = isDarkColor ? Colors.white : Colors.black;
    final iconColor = isDarkColor ? Colors.black : Colors.white;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: backgroundColor,
              body: Stack(
                children: [
                  // Zoomable image
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Hero(
                        tag: 'fullscreen_${item.id}',
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: iconColor,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: iconColor.withOpacity(0.5),
                            size: 64.sp,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16.h,
                    right: 16.w,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: iconColor,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),

                  // Zoom hint
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 32.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pinch,
                              color: iconColor.withOpacity(0.7),
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Yakınlaştırmak için çimdikle',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: iconColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, ClosetItem item) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: 1.0 - (_progress * 0.8),
      child: Container(
        padding: EdgeInsets.fromLTRB(32.w, 100.h, 32.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category title
            Text(
              _capitalizeFirst(item.subcategory ?? 'Ürün'),
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w300,
                color: Colors.grey[900],
                letterSpacing: 1.5,
              ),
            ),

            if (item.brand != null && item.brand!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                item.brand!.toUpperCase(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.baseColor,
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
                    context.baseColor.withOpacity(0.5),
                    context.baseColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            SizedBox(height: 32.h),

            // Details grid
            _buildDetailsGrid(context, item),

            SizedBox(height: 40.h),

            // AI badge
            _buildAIBadge(context),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, ClosetItem item) {
    final details = <MapEntry<String, String>>[];

    if (item.color != null) {
      details.add(MapEntry('Renk', _capitalizeFirst(item.color!)));
    }
    if (item.pattern != null) {
      details.add(MapEntry('Desen', _capitalizeFirst(item.pattern!)));
    }
    if (item.material != null) {
      details.add(MapEntry('Kumaş', _capitalizeFirst(item.material!)));
    }
    if (item.season != null) {
      details.add(MapEntry('Mevsim', _getSeasonName(item.season!)));
    }
    if (item.category != null) {
      details.add(MapEntry('Kategori', _capitalizeFirst(item.category!)));
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 40.w,
      runSpacing: 28.h,
      children: details.map((entry) {
        return _buildDetailItem(
          context,
          label: entry.key,
          value: entry.value,
          color: entry.key == 'Renk' ? _getColorFromName(item.color!) : null,
        );
      }).toList(),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
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
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (color != null) ...[
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
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
            color: context.baseColor,
          ),
          SizedBox(width: 8.w),
          Text(
            'AI ile analiz edildi',
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

  Widget _buildSimilarItemsSection(
      BuildContext context, ClosetItem currentItem) {
    return BlocBuilder<ClosetBloc, ClosetState>(
      builder: (context, state) {
        // Aynı kategorideki diğer ürünleri filtrele
        final allItems = state.closetItems ?? [];
        final similarItems = allItems
            .where((item) =>
                item.id != currentItem.id &&
                item.category == currentItem.category)
            .take(5)
            .toList();

        if (similarItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: context.baseColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Benzer Ürünler',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${similarItems.length} ürün',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Ürün kartları
              SizedBox(
                height: 90.w,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: similarItems.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final item = similarItems[index];
                    return _buildSimilarItemCard(context, item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimilarItemCard(BuildContext context, ClosetItem item) {
    return GestureDetector(
      onTap: () {
        context.router.push(ClosetItemDetailScreenRoute(closetItem: item));
      },
      child: Container(
        width: 90.w,
        height: 90.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Görsel
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: context.baseColor,
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[100],
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size: 24.sp,
                  ),
                ),
              ),

              // Alt gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),

              // Subcategory etiketi
              Positioned(
                bottom: 6.h,
                left: 6.w,
                right: 6.w,
                child: Text(
                  _capitalizeFirst(item.subcategory ?? ''),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getSeasonName(String season) {
    final names = {
      'summer': 'Yaz',
      'winter': 'Kış',
      'spring': 'İlkbahar',
      'autumn': 'Sonbahar',
      'all': 'Tüm Sezonlar',
    };
    return names[season.toLowerCase()] ?? _capitalizeFirst(season);
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'black': Colors.black,
      'white': Colors.white,
      'beige': const Color(0xFFF5F5DC),
      'gray': Colors.grey,
      'grey': Colors.grey,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'pink': Colors.pink,
      'purple': Colors.purple,
      'brown': Colors.brown,
      'navy': const Color(0xFF000080),
      'khaki': const Color(0xFFC3B091),
      'gold': const Color(0xFFFFD700),
      'silver': const Color(0xFFC0C0C0),
    };
    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }
}
