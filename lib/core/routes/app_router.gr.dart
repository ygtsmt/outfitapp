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
    TextToImageScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const TextToImageScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    VideoGenerateScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const VideoGenerateScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    VideoFullScreenRoute.name: (routeData) {
      final args = routeData.argsAs<VideoFullScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: VideoFullScreen(
          key: args.key,
          videoUrl: args.videoUrl,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    VideoDetailScreenRoute.name: (routeData) {
      final args = routeData.argsAs<VideoDetailScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: VideoDetailScreen(
          key: args.key,
          video: args.video,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AllImagesScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const AllImagesScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ImageDetailScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ImageDetailScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: ImageDetailScreen(
          key: args.key,
          image: args.image,
          isBase64: args.isBase64,
          imageType: args.imageType,
        ),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AllEffectsScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const AllEffectsScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    GenerateTemplateVideoScreenRoute.name: (routeData) {
      final args = routeData.argsAs<GenerateTemplateVideoScreenRouteArgs>();
      return CustomPage<dynamic>(
        routeData: routeData,
        child: GenerateTemplateVideoScreen(
          key: args.key,
          videoTemplate: args.videoTemplate,
        ),
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
    GenerateRealtimeScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const GenerateRealtimeScreen(),
        transitionsBuilder: TransitionsBuilders.slideBottom,
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
    LibraryTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    GenerateTabRouter.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    CreateTabRouter.name: (routeData) {
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
    LibraryScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const LibraryScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RealtimeScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const RealtimeScreen(),
        transitionsBuilder: TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    CreateTabScreenRoute.name: (routeData) {
      return CustomPage<dynamic>(
        routeData: routeData,
        child: const CreateTabScreen(),
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
              LibraryTabRouter.name,
              path: 'library',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: LibraryTabRouter.name,
                  redirectTo: 'library-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  LibraryScreenRoute.name,
                  path: 'library-screen',
                  parent: LibraryTabRouter.name,
                  meta: <String, dynamic>{'initialTabIndex': 0},
                ),
              ],
            ),
            RouteConfig(
              GenerateTabRouter.name,
              path: 'generate',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: GenerateTabRouter.name,
                  redirectTo: 'generate-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  RealtimeScreenRoute.name,
                  path: 'generate-screen',
                  parent: GenerateTabRouter.name,
                ),
              ],
            ),
            RouteConfig(
              CreateTabRouter.name,
              path: 'createTab',
              parent: HomeScreenRoute.name,
              children: [
                RouteConfig(
                  '#redirect',
                  path: '',
                  parent: CreateTabRouter.name,
                  redirectTo: 'create-tab-screen',
                  fullMatch: true,
                ),
                RouteConfig(
                  CreateTabScreenRoute.name,
                  path: 'create-tab-screen',
                  parent: CreateTabRouter.name,
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
          ],
        ),
        RouteConfig(
          AllToolsScreenRoute.name,
          path: '/all-tools-screen',
        ),
        RouteConfig(
          TextToImageScreenRoute.name,
          path: '/text-to-image-screen',
        ),
        RouteConfig(
          VideoGenerateScreenRoute.name,
          path: '/video-generate-screen',
        ),
        RouteConfig(
          VideoFullScreenRoute.name,
          path: '/video-full-screen',
        ),
        RouteConfig(
          VideoDetailScreenRoute.name,
          path: '/video-detail-screen',
        ),
        RouteConfig(
          AllImagesScreenRoute.name,
          path: '/all-images-screen',
        ),
        RouteConfig(
          ImageDetailScreenRoute.name,
          path: '/image-detail-screen',
          meta: <String, dynamic>{'imageType': 'text_to_image'},
        ),
        RouteConfig(
          AllEffectsScreenRoute.name,
          path: '/all-effects-screen',
        ),
        RouteConfig(
          GenerateTemplateVideoScreenRoute.name,
          path: '/generate-template-video-screen',
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
          GenerateRealtimeScreenRoute.name,
          path: '/generate-realtime-screen',
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
/// [TextToImageScreen]
class TextToImageScreenRoute extends PageRouteInfo<void> {
  const TextToImageScreenRoute()
      : super(
          TextToImageScreenRoute.name,
          path: '/text-to-image-screen',
        );

  static const String name = 'TextToImageScreenRoute';
}

/// generated route for
/// [VideoGenerateScreen]
class VideoGenerateScreenRoute extends PageRouteInfo<void> {
  const VideoGenerateScreenRoute()
      : super(
          VideoGenerateScreenRoute.name,
          path: '/video-generate-screen',
        );

  static const String name = 'VideoGenerateScreenRoute';
}

/// generated route for
/// [VideoFullScreen]
class VideoFullScreenRoute extends PageRouteInfo<VideoFullScreenRouteArgs> {
  VideoFullScreenRoute({
    Key? key,
    required String videoUrl,
  }) : super(
          VideoFullScreenRoute.name,
          path: '/video-full-screen',
          args: VideoFullScreenRouteArgs(
            key: key,
            videoUrl: videoUrl,
          ),
        );

  static const String name = 'VideoFullScreenRoute';
}

class VideoFullScreenRouteArgs {
  const VideoFullScreenRouteArgs({
    this.key,
    required this.videoUrl,
  });

  final Key? key;

  final String videoUrl;

  @override
  String toString() {
    return 'VideoFullScreenRouteArgs{key: $key, videoUrl: $videoUrl}';
  }
}

/// generated route for
/// [VideoDetailScreen]
class VideoDetailScreenRoute extends PageRouteInfo<VideoDetailScreenRouteArgs> {
  VideoDetailScreenRoute({
    Key? key,
    required VideoGenerateResponseModel video,
  }) : super(
          VideoDetailScreenRoute.name,
          path: '/video-detail-screen',
          args: VideoDetailScreenRouteArgs(
            key: key,
            video: video,
          ),
        );

  static const String name = 'VideoDetailScreenRoute';
}

class VideoDetailScreenRouteArgs {
  const VideoDetailScreenRouteArgs({
    this.key,
    required this.video,
  });

  final Key? key;

  final VideoGenerateResponseModel video;

  @override
  String toString() {
    return 'VideoDetailScreenRouteArgs{key: $key, video: $video}';
  }
}

/// generated route for
/// [AllImagesScreen]
class AllImagesScreenRoute extends PageRouteInfo<void> {
  const AllImagesScreenRoute()
      : super(
          AllImagesScreenRoute.name,
          path: '/all-images-screen',
        );

  static const String name = 'AllImagesScreenRoute';
}

/// generated route for
/// [ImageDetailScreen]
class ImageDetailScreenRoute extends PageRouteInfo<ImageDetailScreenRouteArgs> {
  ImageDetailScreenRoute({
    Key? key,
    required TextToImageImageGenerationResponseModelForBlackForestLabel image,
    required bool isBase64,
    required String imageType,
  }) : super(
          ImageDetailScreenRoute.name,
          path: '/image-detail-screen',
          args: ImageDetailScreenRouteArgs(
            key: key,
            image: image,
            isBase64: isBase64,
            imageType: imageType,
          ),
        );

  static const String name = 'ImageDetailScreenRoute';
}

class ImageDetailScreenRouteArgs {
  const ImageDetailScreenRouteArgs({
    this.key,
    required this.image,
    required this.isBase64,
    required this.imageType,
  });

  final Key? key;

  final TextToImageImageGenerationResponseModelForBlackForestLabel image;

  final bool isBase64;

  final String imageType;

  @override
  String toString() {
    return 'ImageDetailScreenRouteArgs{key: $key, image: $image, isBase64: $isBase64, imageType: $imageType}';
  }
}

/// generated route for
/// [AllEffectsScreen]
class AllEffectsScreenRoute extends PageRouteInfo<void> {
  const AllEffectsScreenRoute()
      : super(
          AllEffectsScreenRoute.name,
          path: '/all-effects-screen',
        );

  static const String name = 'AllEffectsScreenRoute';
}

/// generated route for
/// [GenerateTemplateVideoScreen]
class GenerateTemplateVideoScreenRoute
    extends PageRouteInfo<GenerateTemplateVideoScreenRouteArgs> {
  GenerateTemplateVideoScreenRoute({
    Key? key,
    required VideoTemplate videoTemplate,
  }) : super(
          GenerateTemplateVideoScreenRoute.name,
          path: '/generate-template-video-screen',
          args: GenerateTemplateVideoScreenRouteArgs(
            key: key,
            videoTemplate: videoTemplate,
          ),
        );

  static const String name = 'GenerateTemplateVideoScreenRoute';
}

class GenerateTemplateVideoScreenRouteArgs {
  const GenerateTemplateVideoScreenRouteArgs({
    this.key,
    required this.videoTemplate,
  });

  final Key? key;

  final VideoTemplate videoTemplate;

  @override
  String toString() {
    return 'GenerateTemplateVideoScreenRouteArgs{key: $key, videoTemplate: $videoTemplate}';
  }
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
/// [GenerateRealtimeScreen]
class GenerateRealtimeScreenRoute extends PageRouteInfo<void> {
  const GenerateRealtimeScreenRoute()
      : super(
          GenerateRealtimeScreenRoute.name,
          path: '/generate-realtime-screen',
        );

  static const String name = 'GenerateRealtimeScreenRoute';
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
class LibraryTabRouter extends PageRouteInfo<void> {
  const LibraryTabRouter({List<PageRouteInfo>? children})
      : super(
          LibraryTabRouter.name,
          path: 'library',
          initialChildren: children,
        );

  static const String name = 'LibraryTabRouter';
}

/// generated route for
/// [EmptyRouterPage]
class GenerateTabRouter extends PageRouteInfo<void> {
  const GenerateTabRouter({List<PageRouteInfo>? children})
      : super(
          GenerateTabRouter.name,
          path: 'generate',
          initialChildren: children,
        );

  static const String name = 'GenerateTabRouter';
}

/// generated route for
/// [EmptyRouterPage]
class CreateTabRouter extends PageRouteInfo<void> {
  const CreateTabRouter({List<PageRouteInfo>? children})
      : super(
          CreateTabRouter.name,
          path: 'createTab',
          initialChildren: children,
        );

  static const String name = 'CreateTabRouter';
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
/// [LibraryScreen]
class LibraryScreenRoute extends PageRouteInfo<void> {
  const LibraryScreenRoute()
      : super(
          LibraryScreenRoute.name,
          path: 'library-screen',
        );

  static const String name = 'LibraryScreenRoute';
}

/// generated route for
/// [RealtimeScreen]
class RealtimeScreenRoute extends PageRouteInfo<void> {
  const RealtimeScreenRoute()
      : super(
          RealtimeScreenRoute.name,
          path: 'generate-screen',
        );

  static const String name = 'RealtimeScreenRoute';
}

/// generated route for
/// [CreateTabScreen]
class CreateTabScreenRoute extends PageRouteInfo<void> {
  const CreateTabScreenRoute()
      : super(
          CreateTabScreenRoute.name,
          path: 'create-tab-screen',
        );

  static const String name = 'CreateTabScreenRoute';
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
