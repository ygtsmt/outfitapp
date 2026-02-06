// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

part of 'app_router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    SplashScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    LoginScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    CreateAccountScreenRoute.name: (routeData) {
      final args = routeData.argsAs<CreateAccountScreenRouteArgs>(
          orElse: () => const CreateAccountScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: CreateAccountScreen(
          key: args.key,
          isUpgrade: args.isUpgrade,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    HomeScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AllToolsScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const AllToolsScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    PaymentsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<PaymentsScreenRouteArgs>(
          orElse: () => const PaymentsScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: PaymentsScreen(
          key: args.key,
          isPaywall: args.isPaywall,
        ),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    WatchAdsScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const WatchAdsScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FreeCreditScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const FreeCreditScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    DocumentsWebViewScreenRoute.name: (routeData) {
      final args = routeData.argsAs<DocumentsWebViewScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: DocumentsWebViewScreen(
          key: args.key,
          pdfUrl: args.pdfUrl,
          title: args.title,
        ),
        transitionsBuilder: TransitionsBuilders.slideBottom,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FeedbackScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const FeedbackScreen(),
        transitionsBuilder: TransitionsBuilders.slideBottom,
        opaque: true,
        barrierDismissible: false,
      );
    },
    GallerySelectionScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const GallerySelectionScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ClosetItemFormScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ClosetItemFormScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ClosetItemFormScreen(
          key: args.key,
          imageFile: args.imageFile,
        ),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ClosetItemDetailScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ClosetItemDetailScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ClosetItemDetailScreen(
          key: args.key,
          closetItem: args.closetItem,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    CombineDetailScreenRoute.name: (routeData) {
      final args = routeData.argsAs<CombineDetailScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: CombineDetailScreen(
          key: args.key,
          imageData: args.imageData,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    BatchUploadProgressScreenRoute.name: (routeData) {
      final args = routeData.argsAs<BatchUploadProgressScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: BatchUploadProgressScreen(
          key: args.key,
          imageFiles: args.imageFiles,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    BatchUploadResultScreenRoute.name: (routeData) {
      final args = routeData.argsAs<BatchUploadResultScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: BatchUploadResultScreen(
          key: args.key,
          result: args.result,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FailedPhotoReviewScreenRoute.name: (routeData) {
      final args = routeData.argsAs<FailedPhotoReviewScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: FailedPhotoReviewScreen(
          key: args.key,
          failedPhotos: args.failedPhotos,
        ),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ModelGallerySelectionScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const ModelGallerySelectionScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ModelItemFormScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ModelItemFormScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ModelItemFormScreen(
          key: args.key,
          imageFile: args.imageFile,
        ),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ModelItemDetailScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ModelItemDetailScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ModelItemDetailScreen(
          key: args.key,
          modelItem: args.modelItem,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    BatchModelUploadProgressScreenRoute.name: (routeData) {
      final args = routeData.argsAs<BatchModelUploadProgressScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: BatchModelUploadProgressScreen(
          key: args.key,
          imageFiles: args.imageFiles,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    BatchModelUploadResultScreenRoute.name: (routeData) {
      final args = routeData.argsAs<BatchModelUploadResultScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: BatchModelUploadResultScreen(
          key: args.key,
          result: args.result,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FailedModelReviewScreenRoute.name: (routeData) {
      final args = routeData.argsAs<FailedModelReviewScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: FailedModelReviewScreen(
          key: args.key,
          failedPhotos: args.failedPhotos,
        ),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FitCheckCalendarScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const FitCheckCalendarScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    QuickTryOnScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const QuickTryOnScreen(),
        fullscreenDialog: true,
        transitionsBuilder: TransitionsBuilders.slideBottom,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AIFashionCritiqueCameraScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const AIFashionCritiqueCameraScreen(),
        fullscreenDialog: true,
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AIFashionCritiquePreviewScreenRoute.name: (routeData) {
      final args = routeData.argsAs<AIFashionCritiquePreviewScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: AIFashionCritiquePreviewScreen(
          key: args.key,
          imageFile: args.imageFile,
        ),
        fullscreenDialog: true,
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AIFashionCritiqueResultScreenRoute.name: (routeData) {
      final args = routeData.argsAs<AIFashionCritiqueResultScreenRouteArgs>(
          orElse: () => const AIFashionCritiqueResultScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: AIFashionCritiqueResultScreen(
          key: args.key,
          imageFile: args.imageFile,
          critiqueData: args.critiqueData,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FitCheckResultScreenRoute.name: (routeData) {
      final args = routeData.argsAs<FitCheckResultScreenRouteArgs>(
          orElse: () => const FitCheckResultScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: FitCheckResultScreen(
          key: args.key,
          imageFile: args.imageFile,
          log: args.log,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FitCheckHistoryScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const FitCheckHistoryScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SettingsScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    OutfitSuggestionResultScreenRoute.name: (routeData) {
      final args = routeData.argsAs<OutfitSuggestionResultScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: OutfitSuggestionResultScreen(
          key: args.key,
          suggestion: args.suggestion,
          weather: args.weather,
        ),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    FullScreenImageScreenRoute.name: (routeData) {
      final args = routeData.argsAs<FullScreenImageScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: FullScreenImageScreen(imageUrl: args.imageUrl),
        transitionsBuilder: TransitionsBuilders.zoomIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    LiveStylistPageRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const LiveStylistPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatHistoryScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const ChatHistoryScreen(),
        transitionsBuilder: TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    DashbordTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ProfileTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ClosetTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TryOnTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    DashboardScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const DashboardScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    UserSummaryScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const UserSummaryScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ProfileScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileScreenRouteArgs>(
          orElse: () => const ProfileScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ProfileScreen(key: args.key),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ChatScreenRouteArgs>(
          orElse: () => const ChatScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ChatScreen(
          key: args.key,
          fromHistory: args.fromHistory,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ClosetScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const ClosetScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TryOnScreenRoute.name: (routeData) {
      final args = routeData.argsAs<TryOnScreenRouteArgs>(
          orElse: () => const TryOnScreenRouteArgs());
      return CustomPage<dynamic>(
        routeData: routeData,
        child: TryOnScreen(
          key: args.key,
          initialModel: args.initialModel,
          initialClothes: args.initialClothes,
          alternativeModelUrl: args.alternativeModelUrl,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(
          SplashScreenRoute.name,
          path: '/',
        ),
        RouteConfig(
          LoginScreenRoute.name,
          path: '/login',
        ),
        RouteConfig(
          CreateAccountScreenRoute.name,
          path: '/register',
        ),
        RouteConfig(
          HomeScreenRoute.name,
          path: '/homeScreen',
          children: [
            RouteConfig(
              DashbordTabRouter.name,
              path: 'dashboard',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: DashbordTabRouter.name,
                  redirectTo: 'dashboard-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  DashboardScreenRoute.name,
                  path: 'dashboard-screen',
                  parent: DashbordTabRouter.name,
                ),
                RouteConfig(
                  UserSummaryScreenRoute.name,
                  path: 'user-summary',
                  parent: DashbordTabRouter.name,
                ),
              ],
            ),
            RouteConfig(
              ProfileTabRouter.name,
              path: 'profile',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: ProfileTabRouter.name,
                  redirectTo: 'profile-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  ProfileScreenRoute.name,
                  path: 'profile-screen',
                  parent: ProfileTabRouter.name,
                ),
              ],
            ),
            RouteConfig(
              ChatTabRouter.name,
              path: 'chat',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: ChatTabRouter.name,
                  redirectTo: 'chat-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  ChatScreenRoute.name,
                  path: 'chat-screen',
                  parent: ChatTabRouter.name,
                ),
              ],
            ),
            RouteConfig(
              ClosetTabRouter.name,
              path: 'closet',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: ClosetTabRouter.name,
                  redirectTo: 'closet-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  ClosetScreenRoute.name,
                  path: 'closet-screen',
                  parent: ClosetTabRouter.name,
                ),
              ],
            ),
            RouteConfig(
              TryOnTabRouter.name,
              path: 'try-on',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: TryOnTabRouter.name,
                  redirectTo: 'try-on-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  TryOnScreenRoute.name,
                  path: 'try-on-screen',
                  parent: TryOnTabRouter.name,
                ),
              ],
            ),
          ],
        ),
        RouteConfig(
          AllToolsScreenRoute.name,
          path: '/all-tools-screen',
        ),
        RouteConfig(
          PaymentsScreenRoute.name,
          path: '/payment-screen',
        ),
        RouteConfig(
          WatchAdsScreenRoute.name,
          path: '/watch-ad-screen',
        ),
        RouteConfig(
          FreeCreditScreenRoute.name,
          path: '/free-credit-screen',
        ),
        RouteConfig(
          DocumentsWebViewScreenRoute.name,
          path: '/document-webview-screen',
        ),
        RouteConfig(
          FeedbackScreenRoute.name,
          path: '/feedback-screen',
        ),
        RouteConfig(
          GallerySelectionScreenRoute.name,
          path: '/gallery-selection-screen',
        ),
        RouteConfig(
          ClosetItemFormScreenRoute.name,
          path: '/closet-item-form-screen',
        ),
        RouteConfig(
          ClosetItemDetailScreenRoute.name,
          path: '/closet-item-detail-screen',
        ),
        RouteConfig(
          CombineDetailScreenRoute.name,
          path: '/combine-detail-screen',
        ),
        RouteConfig(
          BatchUploadProgressScreenRoute.name,
          path: '/batch-upload-progress-screen',
        ),
        RouteConfig(
          BatchUploadResultScreenRoute.name,
          path: '/batch-upload-result-screen',
        ),
        RouteConfig(
          FailedPhotoReviewScreenRoute.name,
          path: '/failed-photo-review-screen',
        ),
        RouteConfig(
          ModelGallerySelectionScreenRoute.name,
          path: '/model-gallery-selection-screen',
        ),
        RouteConfig(
          ModelItemFormScreenRoute.name,
          path: '/model-item-form-screen',
        ),
        RouteConfig(
          ModelItemDetailScreenRoute.name,
          path: '/model-item-detail-screen',
        ),
        RouteConfig(
          BatchModelUploadProgressScreenRoute.name,
          path: '/batch-model-upload-progress-screen',
        ),
        RouteConfig(
          BatchModelUploadResultScreenRoute.name,
          path: '/batch-model-upload-result-screen',
        ),
        RouteConfig(
          FailedModelReviewScreenRoute.name,
          path: '/failed-model-review-screen',
        ),
        RouteConfig(
          FitCheckCalendarScreenRoute.name,
          path: '/fit-check-calendar-screen',
        ),
        RouteConfig(
          QuickTryOnScreenRoute.name,
          path: '/quick-try-on-screen',
        ),
        RouteConfig(
          AIFashionCritiqueCameraScreenRoute.name,
          path: '/ai-fashion-critique-camera-screen',
        ),
        RouteConfig(
          AIFashionCritiquePreviewScreenRoute.name,
          path: '/ai-fashion-critique-preview-screen',
        ),
        RouteConfig(
          AIFashionCritiqueResultScreenRoute.name,
          path: '/ai-fashion-critique-result-screen',
        ),
        RouteConfig(
          FitCheckResultScreenRoute.name,
          path: '/fit-check-result-screen',
        ),
        RouteConfig(
          FitCheckHistoryScreenRoute.name,
          path: '/fit-check-history-screen',
        ),
        RouteConfig(
          SettingsScreenRoute.name,
          path: '/settings-screen',
        ),
        RouteConfig(
          OutfitSuggestionResultScreenRoute.name,
          path: '/outfit-suggestion-result-screen',
        ),
        RouteConfig(
          FullScreenImageScreenRoute.name,
          path: '/full-screen-image-screen',
        ),
        RouteConfig(
          LiveStylistPageRoute.name,
          path: '/live-stylist-page',
        ),
        RouteConfig(
          ChatHistoryScreenRoute.name,
          path: '/chat-history-screen',
        ),
      ];
}

/// generated route for
/// [SplashScreen]
class SplashScreenRoute extends PageRouteInfo<void> {
  const SplashScreenRoute()
      : super(
          SplashScreenRoute.name,
          path: '/',
        );

  static const String name = 'SplashScreenRoute';
}

/// generated route for
/// [LoginScreen]
class LoginScreenRoute extends PageRouteInfo<void> {
  const LoginScreenRoute()
      : super(
          LoginScreenRoute.name,
          path: '/login',
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [CreateAccountScreen]
class CreateAccountScreenRoute
    extends PageRouteInfo<CreateAccountScreenRouteArgs> {
  CreateAccountScreenRoute({
    Key? key,
    bool? isUpgrade = false,
  }) : super(
          CreateAccountScreenRoute.name,
          path: '/register',
          args: CreateAccountScreenRouteArgs(
            key: key,
            isUpgrade: isUpgrade,
          ),
        );

  static const String name = 'CreateAccountScreenRoute';
}

class CreateAccountScreenRouteArgs {
  const CreateAccountScreenRouteArgs({
    this.key,
    this.isUpgrade = false,
  });

  final Key? key;

  final bool? isUpgrade;

  @override
  String toString() {
    return 'CreateAccountScreenRouteArgs{key: $key, isUpgrade: $isUpgrade}';
  }
}

/// generated route for
/// [HomeScreen]
class HomeScreenRoute extends PageRouteInfo<void> {
  const HomeScreenRoute({List<PageRouteInfo>? children})
      : super(
          HomeScreenRoute.name,
          path: '/homeScreen',
          initialChildren: children,
        );

  static const String name = 'HomeScreenRoute';
}

/// generated route for
/// [AllToolsScreen]
class AllToolsScreenRoute extends PageRouteInfo<void> {
  const AllToolsScreenRoute()
      : super(
          AllToolsScreenRoute.name,
          path: '/all-tools-screen',
        );

  static const String name = 'AllToolsScreenRoute';
}

/// generated route for
/// [PaymentsScreen]
class PaymentsScreenRoute extends PageRouteInfo<PaymentsScreenRouteArgs> {
  PaymentsScreenRoute({
    Key? key,
    bool? isPaywall = false,
  }) : super(
          PaymentsScreenRoute.name,
          path: '/payment-screen',
          args: PaymentsScreenRouteArgs(
            key: key,
            isPaywall: isPaywall,
          ),
        );

  static const String name = 'PaymentsScreenRoute';
}

class PaymentsScreenRouteArgs {
  const PaymentsScreenRouteArgs({
    this.key,
    this.isPaywall = false,
  });

  final Key? key;

  final bool? isPaywall;

  @override
  String toString() {
    return 'PaymentsScreenRouteArgs{key: $key, isPaywall: $isPaywall}';
  }
}

/// generated route for
/// [WatchAdsScreen]
class WatchAdsScreenRoute extends PageRouteInfo<void> {
  const WatchAdsScreenRoute()
      : super(
          WatchAdsScreenRoute.name,
          path: '/watch-ad-screen',
        );

  static const String name = 'WatchAdsScreenRoute';
}

/// generated route for
/// [FreeCreditScreen]
class FreeCreditScreenRoute extends PageRouteInfo<void> {
  const FreeCreditScreenRoute()
      : super(
          FreeCreditScreenRoute.name,
          path: '/free-credit-screen',
        );

  static const String name = 'FreeCreditScreenRoute';
}

/// generated route for
/// [DocumentsWebViewScreen]
class DocumentsWebViewScreenRoute
    extends PageRouteInfo<DocumentsWebViewScreenRouteArgs> {
  DocumentsWebViewScreenRoute({
    Key? key,
    required String pdfUrl,
    required String title,
  }) : super(
          DocumentsWebViewScreenRoute.name,
          path: '/document-webview-screen',
          args: DocumentsWebViewScreenRouteArgs(
            key: key,
            pdfUrl: pdfUrl,
            title: title,
          ),
        );

  static const String name = 'DocumentsWebViewScreenRoute';
}

class DocumentsWebViewScreenRouteArgs {
  const DocumentsWebViewScreenRouteArgs({
    this.key,
    required this.pdfUrl,
    required this.title,
  });

  final Key? key;

  final String pdfUrl;

  final String title;

  @override
  String toString() {
    return 'DocumentsWebViewScreenRouteArgs{key: $key, pdfUrl: $pdfUrl, title: $title}';
  }
}

/// generated route for
/// [FeedbackScreen]
class FeedbackScreenRoute extends PageRouteInfo<void> {
  const FeedbackScreenRoute()
      : super(
          FeedbackScreenRoute.name,
          path: '/feedback-screen',
        );

  static const String name = 'FeedbackScreenRoute';
}

/// generated route for
/// [GallerySelectionScreen]
class GallerySelectionScreenRoute extends PageRouteInfo<void> {
  const GallerySelectionScreenRoute()
      : super(
          GallerySelectionScreenRoute.name,
          path: '/gallery-selection-screen',
        );

  static const String name = 'GallerySelectionScreenRoute';
}

/// generated route for
/// [ClosetItemFormScreen]
class ClosetItemFormScreenRoute
    extends PageRouteInfo<ClosetItemFormScreenRouteArgs> {
  ClosetItemFormScreenRoute({
    Key? key,
    required File imageFile,
  }) : super(
          ClosetItemFormScreenRoute.name,
          path: '/closet-item-form-screen',
          args: ClosetItemFormScreenRouteArgs(
            key: key,
            imageFile: imageFile,
          ),
        );

  static const String name = 'ClosetItemFormScreenRoute';
}

class ClosetItemFormScreenRouteArgs {
  const ClosetItemFormScreenRouteArgs({
    this.key,
    required this.imageFile,
  });

  final Key? key;

  final File imageFile;

  @override
  String toString() {
    return 'ClosetItemFormScreenRouteArgs{key: $key, imageFile: $imageFile}';
  }
}

/// generated route for
/// [ClosetItemDetailScreen]
class ClosetItemDetailScreenRoute
    extends PageRouteInfo<ClosetItemDetailScreenRouteArgs> {
  ClosetItemDetailScreenRoute({
    Key? key,
    required WardrobeItem closetItem,
  }) : super(
          ClosetItemDetailScreenRoute.name,
          path: '/closet-item-detail-screen',
          args: ClosetItemDetailScreenRouteArgs(
            key: key,
            closetItem: closetItem,
          ),
        );

  static const String name = 'ClosetItemDetailScreenRoute';
}

class ClosetItemDetailScreenRouteArgs {
  const ClosetItemDetailScreenRouteArgs({
    this.key,
    required this.closetItem,
  });

  final Key? key;

  final WardrobeItem closetItem;

  @override
  String toString() {
    return 'ClosetItemDetailScreenRouteArgs{key: $key, closetItem: $closetItem}';
  }
}

/// generated route for
/// [CombineDetailScreen]
class CombineDetailScreenRoute
    extends PageRouteInfo<CombineDetailScreenRouteArgs> {
  CombineDetailScreenRoute({
    Key? key,
    required Map<String, dynamic> imageData,
  }) : super(
          CombineDetailScreenRoute.name,
          path: '/combine-detail-screen',
          args: CombineDetailScreenRouteArgs(
            key: key,
            imageData: imageData,
          ),
        );

  static const String name = 'CombineDetailScreenRoute';
}

class CombineDetailScreenRouteArgs {
  const CombineDetailScreenRouteArgs({
    this.key,
    required this.imageData,
  });

  final Key? key;

  final Map<String, dynamic> imageData;

  @override
  String toString() {
    return 'CombineDetailScreenRouteArgs{key: $key, imageData: $imageData}';
  }
}

/// generated route for
/// [BatchUploadProgressScreen]
class BatchUploadProgressScreenRoute
    extends PageRouteInfo<BatchUploadProgressScreenRouteArgs> {
  BatchUploadProgressScreenRoute({
    Key? key,
    required List<File> imageFiles,
  }) : super(
          BatchUploadProgressScreenRoute.name,
          path: '/batch-upload-progress-screen',
          args: BatchUploadProgressScreenRouteArgs(
            key: key,
            imageFiles: imageFiles,
          ),
        );

  static const String name = 'BatchUploadProgressScreenRoute';
}

class BatchUploadProgressScreenRouteArgs {
  const BatchUploadProgressScreenRouteArgs({
    this.key,
    required this.imageFiles,
  });

  final Key? key;

  final List<File> imageFiles;

  @override
  String toString() {
    return 'BatchUploadProgressScreenRouteArgs{key: $key, imageFiles: $imageFiles}';
  }
}

/// generated route for
/// [BatchUploadResultScreen]
class BatchUploadResultScreenRoute
    extends PageRouteInfo<BatchUploadResultScreenRouteArgs> {
  BatchUploadResultScreenRoute({
    Key? key,
    required BatchUploadResult result,
  }) : super(
          BatchUploadResultScreenRoute.name,
          path: '/batch-upload-result-screen',
          args: BatchUploadResultScreenRouteArgs(
            key: key,
            result: result,
          ),
        );

  static const String name = 'BatchUploadResultScreenRoute';
}

class BatchUploadResultScreenRouteArgs {
  const BatchUploadResultScreenRouteArgs({
    this.key,
    required this.result,
  });

  final Key? key;

  final BatchUploadResult result;

  @override
  String toString() {
    return 'BatchUploadResultScreenRouteArgs{key: $key, result: $result}';
  }
}

/// generated route for
/// [FailedPhotoReviewScreen]
class FailedPhotoReviewScreenRoute
    extends PageRouteInfo<FailedPhotoReviewScreenRouteArgs> {
  FailedPhotoReviewScreenRoute({
    Key? key,
    required List<FailedPhotoInfo> failedPhotos,
  }) : super(
          FailedPhotoReviewScreenRoute.name,
          path: '/failed-photo-review-screen',
          args: FailedPhotoReviewScreenRouteArgs(
            key: key,
            failedPhotos: failedPhotos,
          ),
        );

  static const String name = 'FailedPhotoReviewScreenRoute';
}

class FailedPhotoReviewScreenRouteArgs {
  const FailedPhotoReviewScreenRouteArgs({
    this.key,
    required this.failedPhotos,
  });

  final Key? key;

  final List<FailedPhotoInfo> failedPhotos;

  @override
  String toString() {
    return 'FailedPhotoReviewScreenRouteArgs{key: $key, failedPhotos: $failedPhotos}';
  }
}

/// generated route for
/// [ModelGallerySelectionScreen]
class ModelGallerySelectionScreenRoute extends PageRouteInfo<void> {
  const ModelGallerySelectionScreenRoute()
      : super(
          ModelGallerySelectionScreenRoute.name,
          path: '/model-gallery-selection-screen',
        );

  static const String name = 'ModelGallerySelectionScreenRoute';
}

/// generated route for
/// [ModelItemFormScreen]
class ModelItemFormScreenRoute
    extends PageRouteInfo<ModelItemFormScreenRouteArgs> {
  ModelItemFormScreenRoute({
    Key? key,
    required File imageFile,
  }) : super(
          ModelItemFormScreenRoute.name,
          path: '/model-item-form-screen',
          args: ModelItemFormScreenRouteArgs(
            key: key,
            imageFile: imageFile,
          ),
        );

  static const String name = 'ModelItemFormScreenRoute';
}

class ModelItemFormScreenRouteArgs {
  const ModelItemFormScreenRouteArgs({
    this.key,
    required this.imageFile,
  });

  final Key? key;

  final File imageFile;

  @override
  String toString() {
    return 'ModelItemFormScreenRouteArgs{key: $key, imageFile: $imageFile}';
  }
}

/// generated route for
/// [ModelItemDetailScreen]
class ModelItemDetailScreenRoute
    extends PageRouteInfo<ModelItemDetailScreenRouteArgs> {
  ModelItemDetailScreenRoute({
    Key? key,
    required ModelItem modelItem,
  }) : super(
          ModelItemDetailScreenRoute.name,
          path: '/model-item-detail-screen',
          args: ModelItemDetailScreenRouteArgs(
            key: key,
            modelItem: modelItem,
          ),
        );

  static const String name = 'ModelItemDetailScreenRoute';
}

class ModelItemDetailScreenRouteArgs {
  const ModelItemDetailScreenRouteArgs({
    this.key,
    required this.modelItem,
  });

  final Key? key;

  final ModelItem modelItem;

  @override
  String toString() {
    return 'ModelItemDetailScreenRouteArgs{key: $key, modelItem: $modelItem}';
  }
}

/// generated route for
/// [BatchModelUploadProgressScreen]
class BatchModelUploadProgressScreenRoute
    extends PageRouteInfo<BatchModelUploadProgressScreenRouteArgs> {
  BatchModelUploadProgressScreenRoute({
    Key? key,
    required List<File> imageFiles,
  }) : super(
          BatchModelUploadProgressScreenRoute.name,
          path: '/batch-model-upload-progress-screen',
          args: BatchModelUploadProgressScreenRouteArgs(
            key: key,
            imageFiles: imageFiles,
          ),
        );

  static const String name = 'BatchModelUploadProgressScreenRoute';
}

class BatchModelUploadProgressScreenRouteArgs {
  const BatchModelUploadProgressScreenRouteArgs({
    this.key,
    required this.imageFiles,
  });

  final Key? key;

  final List<File> imageFiles;

  @override
  String toString() {
    return 'BatchModelUploadProgressScreenRouteArgs{key: $key, imageFiles: $imageFiles}';
  }
}

/// generated route for
/// [BatchModelUploadResultScreen]
class BatchModelUploadResultScreenRoute
    extends PageRouteInfo<BatchModelUploadResultScreenRouteArgs> {
  BatchModelUploadResultScreenRoute({
    Key? key,
    required BatchModelUploadResult result,
  }) : super(
          BatchModelUploadResultScreenRoute.name,
          path: '/batch-model-upload-result-screen',
          args: BatchModelUploadResultScreenRouteArgs(
            key: key,
            result: result,
          ),
        );

  static const String name = 'BatchModelUploadResultScreenRoute';
}

class BatchModelUploadResultScreenRouteArgs {
  const BatchModelUploadResultScreenRouteArgs({
    this.key,
    required this.result,
  });

  final Key? key;

  final BatchModelUploadResult result;

  @override
  String toString() {
    return 'BatchModelUploadResultScreenRouteArgs{key: $key, result: $result}';
  }
}

/// generated route for
/// [FailedModelReviewScreen]
class FailedModelReviewScreenRoute
    extends PageRouteInfo<FailedModelReviewScreenRouteArgs> {
  FailedModelReviewScreenRoute({
    Key? key,
    required List<FailedModelInfo> failedPhotos,
  }) : super(
          FailedModelReviewScreenRoute.name,
          path: '/failed-model-review-screen',
          args: FailedModelReviewScreenRouteArgs(
            key: key,
            failedPhotos: failedPhotos,
          ),
        );

  static const String name = 'FailedModelReviewScreenRoute';
}

class FailedModelReviewScreenRouteArgs {
  const FailedModelReviewScreenRouteArgs({
    this.key,
    required this.failedPhotos,
  });

  final Key? key;

  final List<FailedModelInfo> failedPhotos;

  @override
  String toString() {
    return 'FailedModelReviewScreenRouteArgs{key: $key, failedPhotos: $failedPhotos}';
  }
}

/// generated route for
/// [FitCheckCalendarScreen]
class FitCheckCalendarScreenRoute extends PageRouteInfo<void> {
  const FitCheckCalendarScreenRoute()
      : super(
          FitCheckCalendarScreenRoute.name,
          path: '/fit-check-calendar-screen',
        );

  static const String name = 'FitCheckCalendarScreenRoute';
}

/// generated route for
/// [QuickTryOnScreen]
class QuickTryOnScreenRoute extends PageRouteInfo<void> {
  const QuickTryOnScreenRoute()
      : super(
          QuickTryOnScreenRoute.name,
          path: '/quick-try-on-screen',
        );

  static const String name = 'QuickTryOnScreenRoute';
}

/// generated route for
/// [AIFashionCritiqueCameraScreen]
class AIFashionCritiqueCameraScreenRoute extends PageRouteInfo<void> {
  const AIFashionCritiqueCameraScreenRoute()
      : super(
          AIFashionCritiqueCameraScreenRoute.name,
          path: '/ai-fashion-critique-camera-screen',
        );

  static const String name = 'AIFashionCritiqueCameraScreenRoute';
}

/// generated route for
/// [AIFashionCritiquePreviewScreen]
class AIFashionCritiquePreviewScreenRoute
    extends PageRouteInfo<AIFashionCritiquePreviewScreenRouteArgs> {
  AIFashionCritiquePreviewScreenRoute({
    Key? key,
    required File imageFile,
  }) : super(
          AIFashionCritiquePreviewScreenRoute.name,
          path: '/ai-fashion-critique-preview-screen',
          args: AIFashionCritiquePreviewScreenRouteArgs(
            key: key,
            imageFile: imageFile,
          ),
        );

  static const String name = 'AIFashionCritiquePreviewScreenRoute';
}

class AIFashionCritiquePreviewScreenRouteArgs {
  const AIFashionCritiquePreviewScreenRouteArgs({
    this.key,
    required this.imageFile,
  });

  final Key? key;

  final File imageFile;

  @override
  String toString() {
    return 'AIFashionCritiquePreviewScreenRouteArgs{key: $key, imageFile: $imageFile}';
  }
}

/// generated route for
/// [AIFashionCritiqueResultScreen]
class AIFashionCritiqueResultScreenRoute
    extends PageRouteInfo<AIFashionCritiqueResultScreenRouteArgs> {
  AIFashionCritiqueResultScreenRoute({
    Key? key,
    File? imageFile,
    Map<String, dynamic>? critiqueData,
  }) : super(
          AIFashionCritiqueResultScreenRoute.name,
          path: '/ai-fashion-critique-result-screen',
          args: AIFashionCritiqueResultScreenRouteArgs(
            key: key,
            imageFile: imageFile,
            critiqueData: critiqueData,
          ),
        );

  static const String name = 'AIFashionCritiqueResultScreenRoute';
}

class AIFashionCritiqueResultScreenRouteArgs {
  const AIFashionCritiqueResultScreenRouteArgs({
    this.key,
    this.imageFile,
    this.critiqueData,
  });

  final Key? key;

  final File? imageFile;

  final Map<String, dynamic>? critiqueData;

  @override
  String toString() {
    return 'AIFashionCritiqueResultScreenRouteArgs{key: $key, imageFile: $imageFile, critiqueData: $critiqueData}';
  }
}

/// generated route for
/// [FitCheckResultScreen]
class FitCheckResultScreenRoute
    extends PageRouteInfo<FitCheckResultScreenRouteArgs> {
  FitCheckResultScreenRoute({
    Key? key,
    File? imageFile,
    FitCheckLog? log,
  }) : super(
          FitCheckResultScreenRoute.name,
          path: '/fit-check-result-screen',
          args: FitCheckResultScreenRouteArgs(
            key: key,
            imageFile: imageFile,
            log: log,
          ),
        );

  static const String name = 'FitCheckResultScreenRoute';
}

class FitCheckResultScreenRouteArgs {
  const FitCheckResultScreenRouteArgs({
    this.key,
    this.imageFile,
    this.log,
  });

  final Key? key;

  final File? imageFile;

  final FitCheckLog? log;

  @override
  String toString() {
    return 'FitCheckResultScreenRouteArgs{key: $key, imageFile: $imageFile, log: $log}';
  }
}

/// generated route for
/// [FitCheckHistoryScreen]
class FitCheckHistoryScreenRoute extends PageRouteInfo<void> {
  const FitCheckHistoryScreenRoute()
      : super(
          FitCheckHistoryScreenRoute.name,
          path: '/fit-check-history-screen',
        );

  static const String name = 'FitCheckHistoryScreenRoute';
}

/// generated route for
/// [SettingsScreen]
class SettingsScreenRoute extends PageRouteInfo<void> {
  const SettingsScreenRoute()
      : super(
          SettingsScreenRoute.name,
          path: '/settings-screen',
        );

  static const String name = 'SettingsScreenRoute';
}

/// generated route for
/// [OutfitSuggestionResultScreen]
class OutfitSuggestionResultScreenRoute
    extends PageRouteInfo<OutfitSuggestionResultScreenRouteArgs> {
  OutfitSuggestionResultScreenRoute({
    Key? key,
    required OutfitSuggestion suggestion,
    required WeatherModel weather,
  }) : super(
          OutfitSuggestionResultScreenRoute.name,
          path: '/outfit-suggestion-result-screen',
          args: OutfitSuggestionResultScreenRouteArgs(
            key: key,
            suggestion: suggestion,
            weather: weather,
          ),
        );

  static const String name = 'OutfitSuggestionResultScreenRoute';
}

class OutfitSuggestionResultScreenRouteArgs {
  const OutfitSuggestionResultScreenRouteArgs({
    this.key,
    required this.suggestion,
    required this.weather,
  });

  final Key? key;

  final OutfitSuggestion suggestion;

  final WeatherModel weather;

  @override
  String toString() {
    return 'OutfitSuggestionResultScreenRouteArgs{key: $key, suggestion: $suggestion, weather: $weather}';
  }
}

/// generated route for
/// [FullScreenImageScreen]
class FullScreenImageScreenRoute
    extends PageRouteInfo<FullScreenImageScreenRouteArgs> {
  FullScreenImageScreenRoute({required String imageUrl})
      : super(
          FullScreenImageScreenRoute.name,
          path: '/full-screen-image-screen',
          args: FullScreenImageScreenRouteArgs(imageUrl: imageUrl),
        );

  static const String name = 'FullScreenImageScreenRoute';
}

class FullScreenImageScreenRouteArgs {
  const FullScreenImageScreenRouteArgs({required this.imageUrl});

  final String imageUrl;

  @override
  String toString() {
    return 'FullScreenImageScreenRouteArgs{imageUrl: $imageUrl}';
  }
}

/// generated route for
/// [LiveStylistPage]
class LiveStylistPageRoute extends PageRouteInfo<void> {
  const LiveStylistPageRoute()
      : super(
          LiveStylistPageRoute.name,
          path: '/live-stylist-page',
        );

  static const String name = 'LiveStylistPageRoute';
}

/// generated route for
/// [ChatHistoryScreen]
class ChatHistoryScreenRoute extends PageRouteInfo<void> {
  const ChatHistoryScreenRoute()
      : super(
          ChatHistoryScreenRoute.name,
          path: '/chat-history-screen',
        );

  static const String name = 'ChatHistoryScreenRoute';
}

/// generated route for
/// [EmptyRouterPage]
class DashbordTabRouter extends PageRouteInfo<void> {
  const DashbordTabRouter({List<PageRouteInfo>? children})
      : super(
          DashbordTabRouter.name,
          path: 'dashboard',
          initialChildren: children,
        );

  static const String name = 'DashbordTabRouter';
}

/// generated route for
/// [EmptyRouterPage]
class ProfileTabRouter extends PageRouteInfo<void> {
  const ProfileTabRouter({List<PageRouteInfo>? children})
      : super(
          ProfileTabRouter.name,
          path: 'profile',
          initialChildren: children,
        );

  static const String name = 'ProfileTabRouter';
}

/// generated route for
/// [EmptyRouterPage]
class ChatTabRouter extends PageRouteInfo<void> {
  const ChatTabRouter({List<PageRouteInfo>? children})
      : super(
          ChatTabRouter.name,
          path: 'chat',
          initialChildren: children,
        );

  static const String name = 'ChatTabRouter';
}

/// generated route for
/// [EmptyRouterPage]
class ClosetTabRouter extends PageRouteInfo<void> {
  const ClosetTabRouter({List<PageRouteInfo>? children})
      : super(
          ClosetTabRouter.name,
          path: 'closet',
          initialChildren: children,
        );

  static const String name = 'ClosetTabRouter';
}

/// generated route for
/// [EmptyRouterPage]
class TryOnTabRouter extends PageRouteInfo<void> {
  const TryOnTabRouter({List<PageRouteInfo>? children})
      : super(
          TryOnTabRouter.name,
          path: 'try-on',
          initialChildren: children,
        );

  static const String name = 'TryOnTabRouter';
}

/// generated route for
/// [DashboardScreen]
class DashboardScreenRoute extends PageRouteInfo<void> {
  const DashboardScreenRoute()
      : super(
          DashboardScreenRoute.name,
          path: 'dashboard-screen',
        );

  static const String name = 'DashboardScreenRoute';
}

/// generated route for
/// [UserSummaryScreen]
class UserSummaryScreenRoute extends PageRouteInfo<void> {
  const UserSummaryScreenRoute()
      : super(
          UserSummaryScreenRoute.name,
          path: 'user-summary',
        );

  static const String name = 'UserSummaryScreenRoute';
}

/// generated route for
/// [ProfileScreen]
class ProfileScreenRoute extends PageRouteInfo<ProfileScreenRouteArgs> {
  ProfileScreenRoute({Key? key})
      : super(
          ProfileScreenRoute.name,
          path: 'profile-screen',
          args: ProfileScreenRouteArgs(key: key),
        );

  static const String name = 'ProfileScreenRoute';
}

class ProfileScreenRouteArgs {
  const ProfileScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ProfileScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [ChatScreen]
class ChatScreenRoute extends PageRouteInfo<ChatScreenRouteArgs> {
  ChatScreenRoute({
    Key? key,
    bool fromHistory = false,
  }) : super(
          ChatScreenRoute.name,
          path: 'chat-screen',
          args: ChatScreenRouteArgs(
            key: key,
            fromHistory: fromHistory,
          ),
        );

  static const String name = 'ChatScreenRoute';
}

class ChatScreenRouteArgs {
  const ChatScreenRouteArgs({
    this.key,
    this.fromHistory = false,
  });

  final Key? key;

  final bool fromHistory;

  @override
  String toString() {
    return 'ChatScreenRouteArgs{key: $key, fromHistory: $fromHistory}';
  }
}

/// generated route for
/// [ClosetScreen]
class ClosetScreenRoute extends PageRouteInfo<void> {
  const ClosetScreenRoute()
      : super(
          ClosetScreenRoute.name,
          path: 'closet-screen',
        );

  static const String name = 'ClosetScreenRoute';
}

/// generated route for
/// [TryOnScreen]
class TryOnScreenRoute extends PageRouteInfo<TryOnScreenRouteArgs> {
  TryOnScreenRoute({
    Key? key,
    ModelItem? initialModel,
    List<WardrobeItem>? initialClothes,
    String? alternativeModelUrl,
  }) : super(
          TryOnScreenRoute.name,
          path: 'try-on-screen',
          args: TryOnScreenRouteArgs(
            key: key,
            initialModel: initialModel,
            initialClothes: initialClothes,
            alternativeModelUrl: alternativeModelUrl,
          ),
        );

  static const String name = 'TryOnScreenRoute';
}

class TryOnScreenRouteArgs {
  const TryOnScreenRouteArgs({
    this.key,
    this.initialModel,
    this.initialClothes,
    this.alternativeModelUrl,
  });

  final Key? key;

  final ModelItem? initialModel;

  final List<WardrobeItem>? initialClothes;

  final String? alternativeModelUrl;

  @override
  String toString() {
    return 'TryOnScreenRouteArgs{key: $key, initialModel: $initialModel, initialClothes: $initialClothes, alternativeModelUrl: $alternativeModelUrl}';
  }
}
