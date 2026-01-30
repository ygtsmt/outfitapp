import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@singleton
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. İzin iste
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ Bildirim izni verildi');
    }

    // 2. Token al (Backend'e göndermek için lazım olur)
    if (Platform.isIOS) {
      String? apnsToken = await _fcm.getAPNSToken();

      // Token gelmezse 3 saniye boyunca (1'er saniye arayla) tekrar dene
      int retries = 0;
      while (apnsToken == null && retries < 3) {
        await Future<void>.delayed(const Duration(seconds: 1));
        apnsToken = await _fcm.getAPNSToken();
        retries++;
      }

      // Hala token yoksa işlemi durdur (Crash olmasını engeller)
      if (apnsToken == null) {
        log('❌ APNS Token alınamadı. iOS Simülatör kullanıyorsanız bu normaldir. Gerçek cihazda sertifika ayarlarını kontrol edin.');
        return;
      }
    }

    String? token = await _fcm.getToken();
    log('🔑 FCM Token: $token');

    // 3. Yerel bildirim ayarları
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        log('🔔 Bildirime tıklandı: ${details.payload}');
      },
    );

    // 4. Foreground mesajlarını dinle (Uygulama açıkken bildirim gelirse)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📥 Foreground mesajı geldi: ${message.notification?.title}');
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });
  }

  /// Yerel bildirim göster (Agent tetikleyebilir)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'marathon_agent_channel',
      'Marathon Agent Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
