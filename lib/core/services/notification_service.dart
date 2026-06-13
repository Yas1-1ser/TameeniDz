import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  StreamSubscription<AuthState>? _authStateSub;

  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(initializationSettings);

      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        try {
          String? token = await _fcm.getToken();
          if (token != null) {
            await _saveTokenToSupabase(token);
          }
        } catch (e) {
          if (kDebugMode) print('Failed to get FCM token: $e');
        }

        _onTokenRefreshSub = _fcm.onTokenRefresh.listen((newToken) {
          _saveTokenToSupabase(newToken);
        });

        _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
      if (kDebugMode) print('NotificationService initialization failed: $e');
    }
  }

  void dispose() {
    _onMessageSub?.cancel();
    _onTokenRefreshSub?.cancel();
    _authStateSub?.cancel();
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _authStateSub?.cancel();
      _authStateSub = _supabase.auth.onAuthStateChange.listen((data) {
        if (data.session != null) {
          _saveTokenToSupabase(token);
          _authStateSub?.cancel();
        }
      });
      return;
    }
    try {
      await _supabase
          .from('users')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (e) {
      if (kDebugMode) print('Error saving FCM token: $e');
    }
  }
}
