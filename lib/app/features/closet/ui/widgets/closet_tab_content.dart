import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginfit/app/features/closet/models/closet_item_model.dart';
import 'package:ginfit/app/features/closet/ui/screens/closet_item_detail_screen.dart';
import 'package:ginfit/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ClosetTabContent extends StatefulWidget {
  const ClosetTabContent({super.key});

  @override
  State<ClosetTabContent> createState() => _ClosetTabContentState();
}

class _ClosetTabContentState extends State<ClosetTabContent> {
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
                  _AddClosetItemButton(
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

          return RefreshIndicator(
            onRefresh: () async {
              getIt<ClosetBloc>().add(const RefreshClosetItemsEvent());
            },
            child: GridView.builder(
              padding: EdgeInsets.all(8.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.h,
                childAspectRatio: 0.9,
              ),
              itemCount: items.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _AddClosetItemButton(
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
          );
        },
      ),
    );
  }
}

class _ClosetItemCard extends StatelessWidget {
  final ClosetItem item;

  const _ClosetItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
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
      ),
    );
  }
}

class _AddClosetItemButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddClosetItemButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 48.sp,
                color: context.baseColor,
              ),
              SizedBox(height: 8.h),
              Text(
                'Ekle',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
