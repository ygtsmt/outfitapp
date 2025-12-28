import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/library/bloc/library_bloc.dart';
import 'package:ginfit/app/features/library/ui/widgets/failed_refund_credit_widget.dart';
import 'package:ginfit/app/features/library/ui/widgets/video_loading_widget.dart';
import 'package:ginfit/app/features/library/ui/widgets/video_preview_card.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/app/ui/widgets/banner_ad_widget.dart';
import 'package:ginfit/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryVideosScreen extends StatefulWidget {
  const LibraryVideosScreen({super.key});

  @override
  State<LibraryVideosScreen> createState() => _LibraryVideosScreenState();
}

class _LibraryVideosScreenState extends State<LibraryVideosScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = ScrollController();

  /// Kullanıcının userGeneratedVideos array'ini real-time dinle
  Stream<DocumentSnapshot> _getUserVideosStream() {
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

    return RefreshIndicator(
      onRefresh: () async {
        getIt<LibraryBloc>().add(const GetUserGeneratedVideosEvent());
        getIt<LibraryBloc>().add(const CheckVideoStatusesEvent());

        // Toast mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).libraryRefreshed),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
      child: StreamBuilder<DocumentSnapshot>(
        stream: _getUserVideosStream(),
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
          final allVideos =
              userData?['userGeneratedVideos'] as List<dynamic>? ?? [];

          // isDeleted true olan videoları filtrele
          final videos = allVideos.where((video) {
            final map = Map<String, dynamic>.from(video);
            return map['isDeleted'] !=
                true; // isDeleted true olmayanları göster
          }).toList();

          // Yeni gelen videoları en üstte göstermek için sırala
          videos.sort((a, b) {
            final dateA = DateTime.parse(a['completedAt'] ??
                a['createdAt'] ??
                DateTime.now().toString());
            final dateB = DateTime.parse(b['completedAt'] ??
                b['createdAt'] ??
                DateTime.now().toString());
            return dateB
                .compareTo(dateA); // Büyük tarih önce gelsin (yeniden eskiye)
          });

          if (videos.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).noVideoGenerated,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.baseColor,
                          ),
                      textAlign: TextAlign.center),
                  CustomGradientButton(
                    title: AppLocalizations.of(context).generateYourFirstVideo,
                    onTap: () {
                      context.router.push(const AllEffectsScreenRoute());
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

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: _controller,
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 4.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final url = video?['output'];

                    // Failed status kontrolü
                    if (video?['status'] == 'failed') {
                      return AspectRatio(
                        aspectRatio: 1.2,
                        child: FailedRefundCreditWidget(
                            video: VideoGenerateResponseModel.fromJson(video!),
                            context: context),
                      );
                    }

                    if (url == null || url.isEmpty)
                      return const VideosLoadingWidget();

                    return AspectRatio(
                      aspectRatio: 1.2,
                      child: VideoPreviewCard(
                          key: PageStorageKey(video['id']),
                          video: VideoGenerateResponseModel.fromJson(video)),
                    );
                  },
                ),
              ),
              const BannerAdWidget(),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
