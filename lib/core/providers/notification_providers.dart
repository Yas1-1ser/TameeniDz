import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getMyNotifications() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final myNotificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getMyNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(myNotificationsProvider);
  
  return notificationsAsync.maybeWhen(
    data: (notifications) {
      return notifications.where((n) => n['is_read'] != true).length;
    },
    orElse: () => 0,
  );
});
