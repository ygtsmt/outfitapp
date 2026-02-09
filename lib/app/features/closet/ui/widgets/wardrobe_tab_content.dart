import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:comby/generated/l10n.dart';

class WardrobeTabContent extends StatefulWidget {
  const WardrobeTabContent({super.key});

  @override
  State<WardrobeTabContent> createState() => _WardrobeTabContentState();
}

class _WardrobeTabContentState extends State<WardrobeTabContent>
    with AutomaticKeepAliveClientMixin {
  int _crossAxisCount = 3;
  double _baseScaleFactor = 1.0;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    return BlocListener<ClosetBloc, ClosetState>(
      listener: (context, state) {
        // Hata durumunda
        if (state.gettingClosetItemsStatus == EventStatus.failure &&
            state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .errorOccurred(state.errorMessage!)),
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
                    crossAxisCount: _crossAxisCount,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    AppLocalizations.of(context).closetEmptyMessage,
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: items.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _AddWardrobeItemButton(
                      onTap: () => _pickImageAndAddItem(context),
                      crossAxisCount: _crossAxisCount,
                    );
                  }
                  final item = items[index - 1];
                  return GestureDetector(
                    onTap: () {
                      context.router.push(
                        ClosetItemDetailScreenRoute(closetItem: item),
                      );
                    },
                    child: _ClosetItemCard(
                      item: item,
                      crossAxisCount: _crossAxisCount,
                    ),
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
  final int crossAxisCount;

  const _ClosetItemCard({
    required this.item,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
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
                    size: 32.sp,
                  ),
                ),
              ),
            ),
            // Gradient overlay for better text contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                    stops: const [0, 0.4, 0.7, 1],
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.subcategory!,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: crossAxisCount == 4
                          ? 8.sp
                          : crossAxisCount == 3
                              ? 9.sp
                              : 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddWardrobeItemButton extends StatelessWidget {
  final VoidCallback onTap;
  final int crossAxisCount;

  const _AddWardrobeItemButton({
    required this.onTap,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isCompact = crossAxisCount == 4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(18.r),
            color: primary.withOpacity(0.06),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: isCompact ? 28.sp : 34.sp,
                color: primary,
              ),
              SizedBox(height: 8.h),
              Text(
                "Add Item",
                style: TextStyle(
                  fontSize: isCompact ? 11.sp : 13.sp,
                  fontWeight: FontWeight.w700,
                  color: primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
