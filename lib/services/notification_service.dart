import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Handler untuk background message (harus top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message: ${message.messageId}');
  print('📩 Title: ${message.notification?.title}');
  print('📩 Body: ${message.notification?.body}');
  print('📩 Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Callback untuk navigasi ketika notifikasi di-tap
  Function(Map<String, dynamic>)? onNotificationTap;

  // Channel untuk Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'laporan_channel',
    'Notifikasi Laporan',
    description: 'Notifikasi untuk update status laporan',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Inisialisasi notification service
  Future<void> initialize() async {
    print('🔔 Initializing Notification Service...');
    
    // Setup background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup local notifications
    await _setupLocalNotifications();

    // Setup foreground notification handler
    _setupForegroundHandler();

    // Setup notification tap handler
    _setupNotificationTapHandler();

    // Get and save FCM token
    await _getAndSaveFCMToken();

    // Listen to token refresh
    _listenToTokenRefresh();
    
    print('✅ Notification Service initialized');
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔐 Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ User granted provisional permission');
    } else {
      print('❌ User declined permission');
    }
  }

  /// Setup local notifications untuk foreground
  Future<void> _setupLocalNotifications() async {
    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 Notification tapped: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    
    print('✅ Local notifications configured');
  }

  /// Handle foreground messages
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received!');
      print('📨 Title: ${message.notification?.title}');
      print('📨 Body: ${message.notification?.body}');
      print('📨 Data: ${message.data}');

      RemoteNotification? notification = message.notification;

      // Tampilkan local notification jika ada notification payload
      if (notification != null) {
        _showLocalNotification(
          id: message.hashCode,
          title: notification.title ?? 'Notifikasi',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  /// Setup handler untuk ketika notifikasi di-tap
  void _setupNotificationTapHandler() {
    // Ketika app dibuka dari terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📬 App opened from terminated via notification');
        _handleNotificationTap(jsonEncode(message.data));
      }
    });

    // Ketika app dibuka dari background state via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 App opened from background via notification');
      _handleNotificationTap(jsonEncode(message.data));
    });
  }

  /// Handle ketika notification di-tap
  void _handleNotificationTap(String? payload) {
    if (payload != null && onNotificationTap != null) {
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        onNotificationTap!(data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Tampilkan local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    
    print('✅ Local notification shown: $title');
  }

  /// Get FCM token dan simpan ke SharedPreferences
  Future<String?> _getAndSaveFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $token');

      if (token != null) {
        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        print('✅ FCM token saved to SharedPreferences');
      }

      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Listen to token refresh
  void _listenToTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      print('🔄 FCM Token refreshed: $token');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      
      // TODO: Kirim token baru ke server
      print('⚠️ Token refreshed - perlu dikirim ke server');
    });
  }

  /// Get current FCM token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('📢 Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('🔇 Unsubscribed from topic: $topic');
  }
}