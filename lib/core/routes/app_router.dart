// ignore_for_file: unused_import

import "dart:io";

import "package:auto_route/auto_route.dart";
import "package:auto_route/empty_router_widgets.dart";
import "package:ginly/app/bloc/app_bloc.dart";
import "package:ginly/app/data/models/features_doc_model.dart";
import "package:ginly/app/features/auth/features/profile/ui/profile_screen.dart";
import "package:ginly/app/features/auth/features/splash/ui/splash_screen.dart";
import "package:ginly/app/features/closet/models/closet_item_model.dart";
import "package:ginly/app/features/closet/ui/closet_screen.dart";
import "package:ginly/app/features/auth/features/create_account/ui/create_account_screen.dart";
import "package:ginly/app/features/auth/features/login/ui/login_screen.dart";
import "package:ginly/app/features/create_tab/ui/create_tab_screen.dart";
import "package:ginly/app/features/dashboard/ui/screens/all_tools_screen.dart";
import "package:ginly/app/features/dashboard/ui/screens/dashboard_screen.dart";
import "package:ginly/app/features/dashboard/ui/screens/all_effects_screen.dart";
import "package:ginly/app/features/realtime/ui/generate_realtime_screen.dart";
import "package:ginly/app/features/template_generate/ui/screens/generate_template_video_screen.dart";
import "package:ginly/app/features/dashboard/ui/screens/user_summary_screen.dart";
import "package:ginly/app/features/library/ui/screens/all_images_screen.dart";
import "package:ginly/app/features/library/ui/screens/all_videos_screen.dart";
import "package:ginly/app/features/library/ui/screens/image_detail_screen.dart";
import "package:ginly/app/features/library/ui/screens/video_detail_screen.dart";
import "package:ginly/app/features/library/ui/screens/video_full_screen.dart";
import "package:ginly/app/features/payment/ui/payment_screen.dart";
import "package:ginly/app/features/payment/ui/documents_webview_screen.dart";
import "package:ginly/app/features/payment/ui/watch_ads_screen.dart";
import "package:ginly/app/features/payment/ui/free_credit_screen.dart";
import "package:ginly/app/ui/widgets/feedback_screen.dart";
import "package:ginly/app/features/realtime/ui/realtime_screen.dart";
import "package:ginly/app/features/library/ui/screens/library_screen.dart";
import "package:ginly/app/features/closet/ui/screens/gallery_selection_screen.dart";
import "package:ginly/app/features/closet/ui/screens/closet_item_form_screen.dart";
import "package:ginly/app/features/closet/ui/screens/closet_item_detail_screen.dart";
import "package:ginly/app/features/closet/ui/screens/model_gallery_selection_screen.dart";
import "package:ginly/app/features/closet/ui/screens/model_item_form_screen.dart";
import "package:ginly/app/features/closet/ui/screens/model_item_detail_screen.dart";
import "package:ginly/app/features/closet/ui/screens/batch_upload_progress_screen.dart";
import "package:ginly/app/features/closet/ui/screens/batch_upload_result_screen.dart";
import "package:ginly/app/features/closet/ui/screens/failed_photo_review_screen.dart";
import "package:ginly/app/features/closet/ui/screens/batch_model_upload_progress_screen.dart";
import "package:ginly/app/features/closet/ui/screens/batch_model_upload_result_screen.dart";
import "package:ginly/app/features/closet/ui/screens/failed_model_review_screen.dart";
import "package:ginly/app/features/closet/models/model_item_model.dart";
import "package:ginly/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart";
import "package:ginly/app/features/text_to_image/ui/text_to_image_screen.dart";
import "package:ginly/app/features/try_on/ui/try_on_screen.dart";
import "package:ginly/app/features/video_generate/model/video_generate_response_model.dart";
import "package:ginly/app/features/video_generate/ui/video_generate_screen.dart";
import "package:ginly/app/ui/home_screen.dart";
import "package:ginly/core/core.dart";
import "package:flutter/material.dart";
import "package:injectable/injectable.dart";
import "package:video_player/video_player.dart";

part "app_router.gr.dart";

@MaterialAutoRouter(
  routes: <CustomRoute>[
    CustomRoute(
        page: SplashScreen,
        path: "/",
        initial: true,
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: LoginScreen,
        path: "/login",
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: CreateAccountScreen,
        path: "/register",
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
      page: HomeScreen,
      path: "/homeScreen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
      initial: true,
      children: [
        CustomRoute(
          page: EmptyRouterPage,
          name: "DashbordTabRouter",
          path: "dashboard",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: DashboardScreen,
              path: "dashboard-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            CustomRoute(
                page: UserSummaryScreen,
                path: "user-summary",
                transitionsBuilder: TransitionsBuilders.fadeIn),
          ],
        ),
        CustomRoute(
          page: EmptyRouterPage,
          name: "LibraryTabRouter",
          path: "library",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: LibraryScreen,
              path: "library-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              meta: {'initialTabIndex': 0},
            ),
          ],
        ),
        CustomRoute(
          page: EmptyRouterPage,
          name: "GenerateTabRouter",
          path: "generate",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: RealtimeScreen,
              path: "generate-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
          ],
        ),
        CustomRoute(
          page: EmptyRouterPage,
          name: "CreateTabRouter",
          path: "createTab",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: CreateTabScreen,
              path: "create-tab-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
          ],
        ),
        CustomRoute(
          page: EmptyRouterPage,
          name: "ProfileTabRouter",
          path: "profile",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: ProfileScreen,
              path: "profile-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
          ],
        ),
        CustomRoute(
          page: EmptyRouterPage,
          name: "ClosetTabRouter",
          path: "closet",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: ClosetScreen,
              path: "closet-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
          ],
        ),
        CustomRoute(
          page: EmptyRouterPage,
          name: "TryOnTabRouter",
          path: "try-on",
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: TryOnScreen,
              path: "try-on-screen",
              initial: true,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
          ],
        ),
      ],
    ),
    // AI Generation Route Group - Benzer işlevsellik
    CustomRoute(
      page: AllToolsScreen,
      path: "/all-tools-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: TextToImageScreen,
      path: "/text-to-image-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: VideoGenerateScreen,
      path: "/video-generate-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    // Library & Media Route Group - Content viewing
    CustomRoute(
      page: VideoFullScreen,
      path: "/video-full-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: VideoDetailScreen,
      path: "/video-detail-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: AllImagesScreen,
      path: "/all-images-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: ImageDetailScreen,
      path: "/image-detail-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
      meta: {'imageType': 'text_to_image'}, // Default image type
    ),
    // Effects & Template Route Group - Advanced features
    CustomRoute(
      page: AllEffectsScreen,
      path: "/all-effects-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: GenerateTemplateVideoScreen,
      path: "/generate-template-video-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    // Payment & Utility Route Group - Support features
    CustomRoute(
      page: PaymentsScreen,
      path: "/payment-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: WatchAdsScreen,
      path: "/watch-ad-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: FreeCreditScreen,
      path: "/free-credit-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: DocumentsWebViewScreen,
      path: "/document-webview-screen",
      transitionsBuilder: TransitionsBuilders.slideBottom,
    ),
    CustomRoute(
      page: FeedbackScreen,
      path: "/feedback-screen",
      transitionsBuilder: TransitionsBuilders.slideBottom,
    ),
    CustomRoute(
      page: GenerateRealtimeScreen,
      path: "/generate-realtime-screen",
      transitionsBuilder: TransitionsBuilders.slideBottom,
    ),
    // Closet screens
    CustomRoute(
      page: GallerySelectionScreen,
      path: "/gallery-selection-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: ClosetItemFormScreen,
      path: "/closet-item-form-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: ClosetItemDetailScreen,
      path: "/closet-item-detail-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    // Batch upload screens
    CustomRoute(
      page: BatchUploadProgressScreen,
      path: "/batch-upload-progress-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: BatchUploadResultScreen,
      path: "/batch-upload-result-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: FailedPhotoReviewScreen,
      path: "/failed-photo-review-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    // Model screens
    CustomRoute(
      page: ModelGallerySelectionScreen,
      path: "/model-gallery-selection-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: ModelItemFormScreen,
      path: "/model-item-form-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: ModelItemDetailScreen,
      path: "/model-item-detail-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    // Model batch upload screens
    CustomRoute(
      page: BatchModelUploadProgressScreen,
      path: "/batch-model-upload-progress-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: BatchModelUploadResultScreen,
      path: "/batch-model-upload-result-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: FailedModelReviewScreen,
      path: "/failed-model-review-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
  ],
)
@injectable
class AppRouter extends _$AppRouter {
  AppRouter() : super();
}
