// ignore_for_file: unused_import

import "dart:io";

import "package:auto_route/auto_route.dart";
import "package:auto_route/empty_router_widgets.dart";
import "package:comby/app/bloc/app_bloc.dart";
import "package:comby/app/features/auth/features/profile/ui/profile_screen.dart";
import "package:comby/app/features/auth/features/splash/ui/splash_screen.dart";
import "package:comby/app/features/closet/models/wardrobe_item_model.dart";
import "package:comby/app/features/closet/ui/closet_screen.dart";
import "package:comby/app/features/auth/features/create_account/ui/create_account_screen.dart";
import "package:comby/app/features/auth/features/login/ui/login_screen.dart";
import "package:comby/app/features/dashboard/data/models/weather_model.dart";
import "package:comby/app/features/dashboard/ui/screens/all_tools_screen.dart";
import "package:comby/app/features/dashboard/ui/screens/dashboard_screen.dart";
import "package:comby/app/features/dashboard/ui/screens/outfit_suggestion_result_screen.dart";
import "package:comby/app/features/dashboard/ui/screens/user_summary_screen.dart";
import "package:comby/app/features/fit_check/models/fit_check_model.dart";
import "package:comby/app/features/fit_check/ui/screens/fit_check_result_screen.dart";
import "package:comby/app/features/fit_check/ui/screens/fit_check_history_screen.dart";
import "package:comby/app/features/payment/ui/payment_screen.dart";
import "package:comby/app/features/payment/ui/documents_webview_screen.dart";
import "package:comby/app/features/payment/ui/watch_ads_screen.dart";
import "package:comby/app/features/payment/ui/free_credit_screen.dart";
import "package:comby/app/ui/widgets/feedback_screen.dart";
import "package:comby/app/features/closet/ui/screens/gallery_selection_screen.dart";
import "package:comby/app/features/closet/ui/screens/closet_item_form_screen.dart";
import "package:comby/app/features/closet/ui/screens/closet_item_detail_screen.dart";
import "package:comby/app/features/closet/ui/screens/model_gallery_selection_screen.dart";
import "package:comby/app/features/closet/ui/screens/model_item_form_screen.dart";
import "package:comby/app/features/closet/ui/screens/model_item_detail_screen.dart";
import "package:comby/app/features/closet/ui/screens/combine_detail_screen.dart";
import "package:comby/app/features/closet/ui/screens/batch_upload_progress_screen.dart";
import "package:comby/app/features/closet/ui/screens/batch_upload_result_screen.dart";
import "package:comby/app/features/closet/ui/screens/failed_photo_review_screen.dart";
import "package:comby/app/features/closet/ui/screens/batch_model_upload_progress_screen.dart";
import "package:comby/app/features/closet/ui/screens/batch_model_upload_result_screen.dart";
import "package:comby/app/features/closet/ui/screens/failed_model_review_screen.dart";
import "package:comby/app/features/closet/models/model_item_model.dart";
import "package:comby/app/features/fit_check/ui/screens/fit_check_calendar_screen.dart";
import "package:comby/app/features/try_on/ui/try_on_screen.dart";
import "package:comby/app/features/try_on/ui/quick_try_on_screen.dart";
import "package:comby/app/features/dashboard/ui/screens/ai_fashion_critique_preview_screen.dart";
import "package:comby/app/features/dashboard/ui/screens/ai_fashion_critique_result_screen.dart";
import "package:comby/app/features/dashboard/ui/screens/ai_critique_camera_screen.dart";
import "package:comby/app/ui/home_screen.dart";
import "package:comby/core/core.dart";
import "package:comby/core/services/outfit_suggestion_service.dart";
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
    CustomRoute(
      page: CombineDetailScreen, // detail for combine
      path: "/combine-detail-screen",
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
    // Fit Check
    CustomRoute(
      page: FitCheckCalendarScreen,
      path: "/fit-check-calendar-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: QuickTryOnScreen,
      path: "/quick-try-on-screen",
      transitionsBuilder: TransitionsBuilders.slideBottom,
      fullscreenDialog: true,
    ),
    // AI Fashion Critique
    CustomRoute(
      page: AIFashionCritiqueCameraScreen,
      path: "/ai-fashion-critique-camera-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
      fullscreenDialog: true,
    ),
    CustomRoute(
      page: AIFashionCritiquePreviewScreen,
      path: "/ai-fashion-critique-preview-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
      fullscreenDialog: true,
    ),
    CustomRoute(
      page: AIFashionCritiqueResultScreen,
      path: "/ai-fashion-critique-result-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: FitCheckResultScreen,
      path: "/fit-check-result-screen",
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: FitCheckHistoryScreen,
      path: "/fit-check-history-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute(
      page: OutfitSuggestionResultScreen,
      path: "/outfit-suggestion-result-screen",
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
  ],
)
@injectable
class AppRouter extends _$AppRouter {
  AppRouter() : super();
}
