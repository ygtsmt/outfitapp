import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ModelsTabContent extends StatefulWidget {
  const ModelsTabContent({super.key});

  @override
  State<ModelsTabContent> createState() => _ModelsTabContentState();
}

class _ModelsTabContentState extends State<ModelsTabContent> {
  int _crossAxisCount = 3;
  double _baseScaleFactor = 1.0;

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
            return Column(
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
                getIt<ClosetBloc>().add(const RefreshModelItemsEvent());
              },
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount,
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
    return ClipRRect(
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
    );
  }
}

class _AddModelItemButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddModelItemButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
          border:
              Border.symmetric(horizontal: BorderSide(color: context.gray3))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r), // Daha yumuşak köşeler
        child: AspectRatio(
          aspectRatio: 0.75,
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçeriğe göre daralır
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkon Alanı - Daha derinlikli bir görünüm
              Container(
                height: 56.w,
                width: 56.w,
                decoration: BoxDecoration(
                  color: Colors.white, // İkonun arkasını temiz beyaz yapıyoruz
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline, // Daha modern bir ikon
                  size: 30.sp,
                  color: primaryColor,
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                'Model Ekle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor.withOpacity(0.9),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
