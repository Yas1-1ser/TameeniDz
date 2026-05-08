import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // 1. Initialize Local Notifications for Foreground
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(initializationSettings);

      // 2. Request permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted permission');
        }

        // Get FCM token - Wrap in internal try-catch as this is a common point of failure
        try {
          String? token = await _fcm.getToken();
          if (token != null) {
            await _saveTokenToSupabase(token);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to get FCM token: $e');
          }
        }

        // Listen for token refreshes
        _fcm.onTokenRefresh.listen((newToken) {
          _saveTokenToSupabase(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('Got a message whilst in the foreground!');
            print('Message data: ${message.data}');
          }
          
          // Show local notification
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            _localNotifications.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'high_importance_channel',
                  'High Importance Notifications',
                  importance: Importance.max,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                ),
                iOS: DarwinNotificationDetails(),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService initialization failed: $e');
      }
      // We don't rethrow here to allow the app to continue starting even if notifications fail
    }
  }

  /// Helper to test notifications locally
  Future<void> showTestNotification({required String title, required String body}) async {
    await _localNotifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // If we are using phone auth with manual sync, we might not have a Supabase Auth user yet.
      // In that case, we can't save the token via RLS unless we use a public upsert or service role.
      // But usually, once they sync, they are "known".
      try {
        await _supabase.from('users').update({'fcm_token': token}).eq('id', user.id);
      } catch (e) {
        if (kDebugMode) print('Error saving FCM token: $e');
      }
    }
  }
}
