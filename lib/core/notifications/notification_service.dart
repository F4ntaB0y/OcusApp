import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required bool isRunning,
    String? payload,
    bool playSound = true, // Parameter Suara
  }) async {
    // PERBAIKAN KRITIS: Gunakan Channel ID berbeda untuk Mode Suara & Senyap
    // Android mengunci pengaturan channel setelah dibuat. Kita harus memisahkannya.
    final String channelId = playSound
        ? 'ocus_channel_sound'
        : 'ocus_channel_silent';
    final String channelName = playSound
        ? 'Ocus Timer (Sound)'
        : 'Ocus Timer (Silent)';

    final List<AndroidNotificationAction> actions = [
      const AndroidNotificationAction(
        'RESET_TIMER',
        'Reset',
        showsUserInterface: false,
      ),
      AndroidNotificationAction(
        isRunning ? 'PAUSE_TIMER' : 'START_TIMER',
        isRunning ? 'Jeda' : 'Lanjut',
      ),
      const AndroidNotificationAction(
        'SKIP_PHASE',
        'Lewati',
        showsUserInterface: false,
      ),
    ];

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId, // ID Dinamis
          channelName,
          channelDescription: 'Notifikasi timer aplikasi Ocus',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          playSound:
              playSound, // Boolean ini sekarang efektif karena ID channel baru
          actions: actions,
          styleInformation: const MediaStyleInformation(),
        );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentSound: playSound,
          presentAlert: true,
          presentBadge: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
  NotificationResponse notificationResponse,
) {}
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) {}
