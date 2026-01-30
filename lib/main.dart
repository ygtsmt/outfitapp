import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:firebase_core/firebase_core.dart";
import "package:comby/app/ui/app_screen.dart";
import "package:comby/core/core.dart";
import "package:comby/core/injection/injection.dart";
import "package:comby/core/services/notification_service.dart";

import "package:comby/firebase_options.dart";
import "package:url_strategy/url_strategy.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init (zorunlu)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ekran yönünü sadece dikey kilitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar rengi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Dependency injection
  configureDependencies();

  // Notification init
  await getIt<NotificationService>().initialize();

  // Web için temiz URL
  setPathUrlStrategy();

  // Uygulama başlat
  runApp(
    const ScreenUtilInit(
      child: AppScreen(),
    ),
  );
}
