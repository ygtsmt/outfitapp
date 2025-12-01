import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/library/ui/screens/generated_image_card.dart';
import 'package:ginly/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginly/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';

class LibraryRealtimeImagesScreen extends StatefulWidget {
  const LibraryRealtimeImagesScreen({
    super.key,
  });

  @override
  State<LibraryRealtimeImagesScreen> createState() =>
      _LibraryRealtimeImagesScreenState();
}

class _LibraryRealtimeImagesScreenState
    extends State<LibraryRealtimeImagesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Kullanıcının userGeneratedRealtimeImages array'ini real-time dinle
  Stream<DocumentSnapshot> _getUserRealtimeImagesStream() {
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
      stream: _getUserRealtimeImagesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${AppLocalizations.of(context).errorWithSnapshot(snapshot.error.toString())}'),
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
        if (userData == null) {
          return Center(
            child: Text(AppLocalizations.of(context).noUserDataFound),
          );
        }

        // Farklı field isimlerini dene
        final allRealtimeImages =
            userData['userGeneratedRealtimeImages'] as List<dynamic>? ??
                userData['realtimeImages'] as List<dynamic>? ??
                userData['realtimePhotoBase64LIST'] as List<dynamic>? ??
                userData['userGeneratedImages'] as List<dynamic>? ??
                [];

        // isDeleted true olan resimleri filtrele
        final realtimeImages = allRealtimeImages.where((image) {
          final map = Map<String, dynamic>.from(image);
          return map['isDeleted'] != true; // isDeleted true olmayanları göster
        }).toList();

        // En son üretilen en başta olsun - tarih sıralaması
        if (realtimeImages.isNotEmpty) {
          realtimeImages.sort((a, b) {
            try {
              final dateA =
                  DateTime.parse(a['created_at'] ?? DateTime.now().toString());
              final dateB =
                  DateTime.parse(b['created_at'] ?? DateTime.now().toString());
              return dateB
                  .compareTo(dateA); // Büyük tarih önce gelsin (yeniden eskiye)
            } catch (e) {
              return 0; // Hata durumunda sıralama yapma
            }
          });
        }

        // Debug: Realtime images listesini kontrol et
        print('RealtimeImages length: ${realtimeImages.length}');
        if (realtimeImages.isNotEmpty) {
          print('First image data: ${realtimeImages.first}');
          print('First image data keys: ${realtimeImages.first.keys.toList()}');
          print('First image prompt: ${realtimeImages.first['prompt']}');
          print('First image input: ${realtimeImages.first['input']}');
          print('First image id: ${realtimeImages.first['id']}');
        }

        if (realtimeImages.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).noRealtimeImageGenerated,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: context.baseColor),
                  textAlign: TextAlign.center,
                ),
                CustomGradientButton(
                  title: AppLocalizations.of(context).generateRealtimeImages,
                  onTap: () {
                    context.router.push(const GenerateRealtimeScreenRoute());
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
          ),
          shrinkWrap: true,
          itemCount: realtimeImages.length,
          itemBuilder: (context, index) {
            final imageData = realtimeImages[index];

            // Output field'ından URL'yi al
            final output = imageData['output'] as List<dynamic>?;
            final imageUrl =
                output?.isNotEmpty == true ? output![0] as String : '';

            if (imageUrl.isEmpty) {
              return const SizedBox();
            }

            return GeneratedImageCard(
                isRealtime: true,
                image:
                    TextToImageImageGenerationResponseModelForBlackForestLabel
                        .fromJson(imageData));
          },
        );
      },
    );
  }
}
