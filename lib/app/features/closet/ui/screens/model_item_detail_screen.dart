import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginfit/app/features/closet/models/model_item_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class ModelItemDetailScreen extends StatelessWidget {
  final ModelItem modelItem;

  const ModelItemDetailScreen({
    super.key,
    required this.modelItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          modelItem.name ?? 'Model Detay',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fotoğraf
          Expanded(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: modelItem.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.white,
                    size: 24.h,
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 64.sp,
                  ),
                ),
              ),
            ),
          ),
          // Bilgi alanı
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (modelItem.name != null && modelItem.name!.isNotEmpty) ...[
                    Text(
                      modelItem.name!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  Text(
                    'Eklenme Tarihi: ${DateFormat('dd MMM yyyy, HH:mm').format(modelItem.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Model Sil'),
        content: const Text('Bu modeli silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              getIt<ClosetBloc>().add(DeleteModelItemEvent(modelItem.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Model silindi'),
                  backgroundColor: Colors.green,
                ),
              );
              context.router.pop();
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
