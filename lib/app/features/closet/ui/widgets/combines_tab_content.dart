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
  int _crossAxisCount = 2;
  double _baseScaleFactor = 1.0;
  Stream<DocumentSnapshot>? _userStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Giriş yapmanız gerekiyor'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
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
              setState(() {});
            },
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,

                childAspectRatio: 0.75, // Keeps poster ratio
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

    return ClipRRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image (Full Bleed)
          if (status == 'succeeded' && imageUrl != null)
            Hero(
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
                    size: 32.sp,
                  ),
                ),
              ),
            )
          else
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: status == 'processing'
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.fourRotatingDots(
                            color: Theme.of(context).colorScheme.primary,
                            size: 20.h,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Hazırlanıyor...',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Hata',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          // Gradient Overlay (Bottom)
          if (status == 'succeeded')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
