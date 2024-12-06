import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String navigationActionId = 'timer_page';

  static void Function(String?)? onNotificationTap;

  static Future<void> initialize() async {
    if (_initialized) return;

      // 알림 권한 요청
    await requestNotificationPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_chack');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.payload);
      },
    );
    
    if (Platform.isAndroid) {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
    }
    
    _initialized = true;
  }

  static Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid && (await Permission.notification.isDenied)) {
      final status = await Permission.notification.request();
      if (status == PermissionStatus.granted) {
        // print("알림 권한이 허용되었습니다.");
      } else {
        // print("알림 권한이 거부되었습니다.");
      }
    }
  }

  static Future<void> _onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
    onNotificationTap?.call(payload);
  }

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '$seconds초';
    } else if (remainingSeconds == 0) {
      return '$minutes분';
    } else {
      return '$minutes분 $remainingSeconds초';
    }
  }

  static Future<void> showReadingCompleteNotification(int seconds) async {
    // 알림 설정 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final enabled = doc.data()?['notificationsEnabled'] ?? false;
      if (!enabled) return;
    }

    const androidDetails = AndroidNotificationDetails(
      'reading_timer_channel',
      '독서 타이머',
      channelDescription: '독서 타이머 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_chack',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final formattedTime = _formatDuration(seconds);
    
    await _notifications.show(
      0,
      '독서 시간 완료',
      '책을 읽은지 $formattedTime이 지났어요. 이제 잠깐 쉬고 다시 시작해요.',
      details,
      payload: navigationActionId,
    );
  }


  static Future<void> showBreakCompleteNotification() async {
    // 알림 설정 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final enabled = doc.data()?['notificationsEnabled'] ?? false;
      if (!enabled) return;
    }

    const androidDetails = AndroidNotificationDetails(
      'reading_timer_channel',
      '독서 타이머',
      channelDescription: '독서 타이머 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_chack',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      1,
      '휴식 시간 완료',
      '휴식시간이 끝났어요. 다시 시작해볼까요?',
      details,
      payload: navigationActionId,
    );
  }
}