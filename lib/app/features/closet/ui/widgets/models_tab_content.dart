import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginly/app/features/closet/models/model_item_model.dart';
import 'package:ginly/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ModelsTabContent extends StatefulWidget {
  const ModelsTabContent({super.key});

  @override
  State<ModelsTabContent> createState() => _ModelsTabContentState();
}

class _ModelsTabContentState extends State<ModelsTabContent> {
  @override
  void initState() {
    super.initState();
    // Model item'ları yükle
    getIt<ClosetBloc>().add(const GetUserModelItemsEvent());
  }

  Future<void> _pickImageAndAddItem(BuildContext context) async {
    // Model galeri seçim ekranını aç
    if (context.mounted) {
      context.router.push(const ModelGallerySelectionScreenRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClosetBloc, ClosetState>(
      listener: (context, state) {
        // Hata durumunda
        if (state.gettingModelItemsStatus == EventStatus.failure &&
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
          final modelItems = state.modelItems;

          // Sadece ilk yükleme sırasında loading göster (modelItems null ise)
          if (state.gettingModelItemsStatus == EventStatus.processing &&
              modelItems == null) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).colorScheme.primary,
                size: 24.h,
              ),
            );
          }

          final items = modelItems ?? [];

          if (items.isEmpty &&
              state.gettingModelItemsStatus != EventStatus.processing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AddModelItemButton(
                    onTap: () => _pickImageAndAddItem(context),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Model fotoğrafı bulunamadı\nYeni model eklemek için yukarıdaki butona tıklayın',
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
              getIt<ClosetBloc>().add(const RefreshModelItemsEvent());
            },
            child: GridView.builder(
              padding: EdgeInsets.all(8.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.h,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _AddModelItemButton(
                    onTap: () => _pickImageAndAddItem(context),
                  );
                }
                final item = items[index - 1];
                return GestureDetector(
                  onTap: () {
                    context.router.push(
                      ModelItemDetailScreenRoute(modelItem: item),
                    );
                  },
                  child: _ModelItemCard(item: item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ModelItemCard extends StatelessWidget {
  final ModelItem item;

  const _ModelItemCard({required this.item});

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
            // Name badge
            if (item.name != null && item.name!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    item.name!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddModelItemButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddModelItemButton({required this.onTap});

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
                Icons.person_add,
                size: 48.sp,
                color: context.baseColor,
              ),
              SizedBox(height: 8.h),
              Text(
                'Model Ekle',
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

