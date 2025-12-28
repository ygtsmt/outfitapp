import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/library/ui/screens/generated_image_card.dart';
import 'package:ginfit/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginfit/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryImagesScreen extends StatefulWidget {
  const LibraryImagesScreen({
    super.key,
  });

  @override
  State<LibraryImagesScreen> createState() => _LibraryImagesScreenState();
}

class _LibraryImagesScreenState extends State<LibraryImagesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Kullanıcının userGeneratedImages array'ini real-time dinle
  Stream<DocumentSnapshot> _getUserImagesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(
              includeMetadataChanges:
                  false); // Sadece gerçek data değişikliklerini dinle
    }
    return Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: _getUserImagesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).colorScheme.primary,
                size: 24.h,
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final allImages =
            userData?['userGeneratedImages'] as List<dynamic>? ?? [];

        // isDeleted true olan resimleri filtrele
        final images = allImages.where((image) {
          final map = Map<String, dynamic>.from(image);
          return map['isDeleted'] != true; // isDeleted true olmayanları göster
        }).toList();

        // Yeni gelen resimleri en üstte göstermek için sırala
        images.sort((a, b) {
          final dateA = DateTime.parse(
              a['completedAt'] ?? a['createdAt'] ?? DateTime.now().toString());
          final dateB = DateTime.parse(
              b['completedAt'] ?? b['createdAt'] ?? DateTime.now().toString());
          return dateB
              .compareTo(dateA); // Büyük tarih önce gelsin (yeniden eskiye)
        });

        // Map verilerini model'e cast et
        final List<TextToImageImageGenerationResponseModelForBlackForestLabel>
            castedImages = images.map((imageData) {
          return TextToImageImageGenerationResponseModelForBlackForestLabel
              .fromJson(imageData as Map<String, dynamic>);
        }).toList();

        if (images.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).noImageGenerated,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.baseColor,
                      ),
                ),
                CustomGradientButton(
                  title: AppLocalizations.of(context).generateYourFirstImage,
                  onTap: () {
                    context.router.push(const TextToImageScreenRoute());
                  },
                  leading: Image.asset(
                    PngPaths.generateFilled,
                    color: context.white,
                    height: 24,
                  ),
                  isFilled: true,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
            childAspectRatio: 1,
          ),
          itemCount: castedImages.length,
          itemBuilder: (context, index) {
            return GeneratedImageCard(
              image: castedImages[index],
              isRealtime: false,
            );
          },
        );
      },
    );
  }
}
