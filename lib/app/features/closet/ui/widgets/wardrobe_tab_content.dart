import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WardrobeTabContent extends StatefulWidget {
  const WardrobeTabContent({super.key});

  @override
  State<WardrobeTabContent> createState() => _WardrobeTabContentState();
}

class _WardrobeTabContentState extends State<WardrobeTabContent> {
  int _crossAxisCount = 3;
  double _baseScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    // Closet item'ları yükle
    getIt<ClosetBloc>().add(const GetUserClosetItemsEvent());
  }

  Future<void> _pickImageAndAddItem(BuildContext context) async {
    // Galeri seçim ekranını aç (sağdan sola slide)
    if (context.mounted) {
      context.router.push(const GallerySelectionScreenRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClosetBloc, ClosetState>(
      listener: (context, state) {
        // Hata durumunda
        if (state.gettingClosetItemsStatus == EventStatus.failure &&
            state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${state.errorMessage}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<ClosetBloc, ClosetState>(
        builder: (context, state) {
          final closetItems = state.closetItems;

          // Sadece ilk yükleme sırasında loading göster (closetItems null ise)
          if (state.gettingClosetItemsStatus == EventStatus.processing &&
              closetItems == null) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).colorScheme.primary,
                size: 24.h,
              ),
            );
          }

          final items = closetItems ?? [];

          if (items.isEmpty &&
              state.gettingClosetItemsStatus != EventStatus.processing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AddWardrobeItemButton(
                    onTap: () => _pickImageAndAddItem(context),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Closet içeriği bulunamadı\nYeni item eklemek için yukarıdaki butona tıklayın',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onScaleStart: (details) {
              _baseScaleFactor = _crossAxisCount.toDouble();
            },
            onScaleUpdate: (details) {
              // Squaring the scale makes the resize trigger faster (higher sensitivity)
              final effectiveScale = details.scale * details.scale;
              final newCount = (_baseScaleFactor / effectiveScale).round();
              final clampedCount = newCount.clamp(2, 4);

              if (_crossAxisCount != clampedCount) {
                setState(() {
                  _crossAxisCount = clampedCount;
                });
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                getIt<ClosetBloc>().add(const RefreshClosetItemsEvent());
              },
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount,
                  childAspectRatio: 1,
                  mainAxisSpacing: 4.h,
                  crossAxisSpacing: 4.w,
                ),
                itemCount: items.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _AddWardrobeItemButton(
                      onTap: () => _pickImageAndAddItem(context),
                    );
                  }
                  final item = items[index - 1];
                  return GestureDetector(
                    onTap: () {
                      context.router.push(
                        ClosetItemDetailScreenRoute(closetItem: item),
                      );
                    },
                    child: _ClosetItemCard(item: item),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClosetItemCard extends StatelessWidget {
  final WardrobeItem item;

  const _ClosetItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        children: [
          // Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 12.h,
                ),
              ),
              errorWidget: (_, __, ___) => Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                  size: 48.sp,
                ),
              ),
            ),
          ),
          // Category badge
          if (item.category != null)
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.category!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddWardrobeItemButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddWardrobeItemButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 28.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Yeni Ekle',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
