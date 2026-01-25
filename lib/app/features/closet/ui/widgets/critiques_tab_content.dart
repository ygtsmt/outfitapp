import 'package:comby/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

class CritiquesTabContent extends StatefulWidget {
  const CritiquesTabContent({super.key});

  @override
  State<CritiquesTabContent> createState() => _CritiquesTabContentState();
}

class _CritiquesTabContentState extends State<CritiquesTabContent>
    with AutomaticKeepAliveClientMixin {
  Stream<QuerySnapshot>? _critiquesStream;
  int _crossAxisCount = 2;
  double _baseScaleFactor = 1.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _critiquesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('critiques')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Giriş yapmanız gerekiyor'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _critiquesStream,
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
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_outlined,
                    size: 64.sp, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text(
                  'Henüz stil analizi yok',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
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
          child: GridView.builder(
            padding: EdgeInsets.all(0.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              childAspectRatio: 0.7,
              crossAxisSpacing: 0.w,
              mainAxisSpacing: 0.h,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildCritiqueCard(data, _crossAxisCount);
            },
          ),
        );
      },
    );
  }

  Widget _buildCritiqueCard(Map<String, dynamic> data, int crossAxisCount) {
    final imageUrl = data['imageUrl'] as String?;
    final score = data['score'] as int? ?? 0;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final formattedDate =
        createdAt != null ? DateFormat('d MMM').format(createdAt) : '';

    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(
          AIFashionCritiqueResultScreenRoute(
            critiqueData: data,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[100]),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                ),

              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Score Badge
              Positioned(
                top: 10.w,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.all(0.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: crossAxisCount >= 3 ? 10.sp : 14.sp,
                      fontWeight: FontWeight.w900,
                      color: _getScoreColor(score),
                    ),
                  ),
                ),
              ),

              // Date & Info
              Positioned(
                bottom: 12.w,
                left: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: crossAxisCount >= 3 ? 10.sp : 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'AI Analiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: crossAxisCount >= 3 ? 12.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return const Color(0xFF4CAF50); // Green
    if (score >= 7) return const Color(0xFF2196F3); // Blue
    if (score >= 5) return const Color(0xFFFFC107); // Amber
    return const Color(0xFFFF5252); // Red
  }
}
