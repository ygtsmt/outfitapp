import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/routes/app_router.dart';

class CombinesTabContent extends StatefulWidget {
  const CombinesTabContent({super.key});

  @override
  State<CombinesTabContent> createState() => _CombinesTabContentState();
}

class _CombinesTabContentState extends State<CombinesTabContent> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Giriş yapmanız gerekiyor'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Theme.of(context).colorScheme.primary,
              size: 24.h,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Hata: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('Veri bulunamadı'),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final images = userData?['userGeneratedImages'] as List<dynamic>? ?? [];

        // Sadece Gemini Image Edit modelini filtrele
        final geminiImages = images.where((img) {
          final model = img['model'] as String?;
          return model == 'gemini-2.5-flash-image-edit';
        }).toList();

        // Tarihe göre sırala (Yeniden eskiye)
        geminiImages.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
          final dateB =
              DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA); // Descending
        });

        if (geminiImages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 80.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 24.h),
                Text(
                  'Henüz combine bulunamadı',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Try-On sekmesinden yeni combine oluşturabilirsiniz',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: GridView.builder(
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.75,
            ),
            itemCount: geminiImages.length,
            itemBuilder: (context, index) {
              final image = geminiImages[index] as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  context.router
                      .push(CombineDetailScreenRoute(imageData: image));
                },
                child: _CombineImageCard(imageData: image),
              );
            },
          ),
        );
      },
    );
  }
}

class _CombineImageCard extends StatelessWidget {
  final Map<String, dynamic> imageData;

  const _CombineImageCard({required this.imageData});

  @override
  Widget build(BuildContext context) {
    final status = imageData['status'] as String? ?? 'processing';
    final output = imageData['output'] as List<dynamic>?;
    final imageUrl =
        output != null && output.isNotEmpty ? output[0] as String? : null;
    final prompt = imageData['prompt'] as String? ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: status == 'succeeded' && imageUrl != null
                  ? Hero(
                      tag: 'combine_${imageData['id'] ?? imageUrl}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
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
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: status == 'processing'
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingAnimationWidget.fourRotatingDots(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 24.h,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'İşleniyor...',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 32.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Hata',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ),
            // Prompt
            Container(
              padding: EdgeInsets.all(8.w),
              color: Colors.black.withOpacity(0.05),
              child: Text(
                prompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
