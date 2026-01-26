import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
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

class _CombinesTabContentState extends State<CombinesTabContent>
    with AutomaticKeepAliveClientMixin {
  int _crossAxisCount = 2;
  double _baseScaleFactor = 1.0;
  Stream<QuerySnapshot>? _imagesStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _imagesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('combines')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(AppLocalizations.of(context).loginRequired),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _imagesStream,
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
            child: Text(AppLocalizations.of(context)
                .errorOccurred(snapshot.error.toString())),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Filter and map to list of maps
        final geminiImages = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data;
        }).where((img) {
          final model = img['model'] as String?;
          // Filter if needed, though we only put images here anyway
          return model == 'gemini-2.5-flash-image-edit';
        }).toList();

        if (geminiImages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AddCombineItemButton(
                  onTap: () {
                    context.router.navigate(const TryOnTabRouter());
                  },
                  crossAxisCount: _crossAxisCount, // Pass crossAxisCount
                ),
                SizedBox(height: 24.h),
                Text(
                  AppLocalizations.of(context).noCombinesFound,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).clickButtonAboveToCreateCombine,
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                childAspectRatio: 0.75, // Keeps poster ratio
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: geminiImages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AddCombineItemButton(
                    onTap: () {
                      context.router.navigate(const TryOnTabRouter());
                    },
                    crossAxisCount: _crossAxisCount,
                  );
                }
                final image = geminiImages[index - 1] as Map<String, dynamic>;
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
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
                      size: 16.h,
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
                              AppLocalizations.of(context).preparing,
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
                              AppLocalizations.of(context).failed,
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
                        Colors.black.withOpacity(0.5),
                      ],
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

class AddCombineItemButton extends StatelessWidget {
  final VoidCallback onTap;
  final int crossAxisCount;

  const AddCombineItemButton({
    required this.onTap,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Area
            Container(
              height: crossAxisCount == 4 ? 40.w : 52.w,
              width: crossAxisCount == 4 ? 40.w : 52.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: crossAxisCount == 4 ? 24.sp : 32.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).createCombine,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: crossAxisCount == 4 ? 10.sp : 12.sp,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
