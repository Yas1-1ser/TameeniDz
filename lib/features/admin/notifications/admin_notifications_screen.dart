import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tameenidz/core/providers/supabase_provider.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';

// ── Providers ───────────────────────────────────────────────────────────────

/// Stream all notifications targeted at admin role, ordered by newest first.
final _adminNotificationsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final client = ref.watch(privilegedSupabaseProvider);
  return client
      .from('notifications')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);
});

// ── Screen ──────────────────────────────────────────────────────────────────

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final notifAsync = ref.watch(_adminNotificationsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(
        context,
        l10n.notifications,
        actions: [
          // Mark all as read button
          notifAsync.maybeWhen(
            data: (list) {
              final hasUnread = list.any((n) => n['is_read'] != true);
              if (!hasUnread) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all_rounded, color: Color(0xFFC9A96E), size: 20),
                tooltip: l10n.markAllAsRead,
                onPressed: () async {
                  final client = ref.read(privilegedSupabaseProvider);
                  await client
                      .from('notifications')
                      .update({'is_read': true})
                      .eq('is_read', false);
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: adminBottomNav(context, 0, l10n),
      body: notifAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colors.slate400),
                const SizedBox(height: 12),
                Text(
                  l10n.errorLoadingNotifications,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$e',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: colors.slate500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (notifications) {
          // Filter to admin-relevant notifications
          final adminNotifs = notifications.where((n) {
            final recipientRole = n['recipient_role'] as String?;
            return recipientRole == 'admin' || recipientRole == null;
          }).toList();

          if (adminNotifs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_outlined, size: 56, color: colors.slate300),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noNotificationsAvailable,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: colors.slate500,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminNotifs.length,
            itemBuilder: (context, index) {
              final notification = adminNotifs[index];
              return StaggeredListItem(
                delay: Duration(milliseconds: index * 40),
                child: _NotificationCard(
                  data: notification,
                  onTap: () => _markAsRead(ref, notification),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _markAsRead(WidgetRef ref, Map<String, dynamic> notification) {
    if (notification['is_read'] == true) return;
    final client = ref.read(privilegedSupabaseProvider);
    client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notification['id'])
        .then((_) {})
        .catchError((_) {});
  }
}

// ── Notification Card ───────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _NotificationCard({required this.data, required this.onTap});

  IconData _iconForType(String? type) {
    switch (type) {
      case 'new_registration':
        return Icons.person_add_alt_1_rounded;
      case 'new_request':
        return Icons.description_outlined;
      case 'request_accepted':
        return Icons.check_circle_outline;
      case 'request_rejected':
        return Icons.cancel_outlined;
      case 'request_modificationRequested':
        return Icons.edit_note_rounded;
      case 'request_paid':
        return Icons.payment_rounded;
      case 'policy_expiry':
        return Icons.timer_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'new_registration':
        return const Color(0xFF2563EB); // blue
      case 'new_request':
        return const Color(0xFF059669); // green
      case 'request_accepted':
        return const Color(0xFF059669);
      case 'request_rejected':
        return const Color(0xFFDC2626); // red
      case 'request_modificationRequested':
        return const Color(0xFFF59E0B); // amber
      case 'request_paid':
        return const Color(0xFF7C3AED); // purple
      case 'policy_expiry':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8B7355);
    }
  }

  String _formatTimestamp(String? ts, AppLocalizations l10n) {
    if (ts == null) return '';
    final dt = DateTime.tryParse(ts);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return l10n.aiNow;
    if (diff.inMinutes < 60) return l10n.aiMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.aiHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.aiDaysAgo(diff.inDays);
    return intl.DateFormat('yyyy/M/d – HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final bool isRead = data['is_read'] == true;
    final String? type = data['type'] as String?;
    final accentColor = _colorForType(type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white.withValues(alpha: 0.7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE5DDD0).withValues(alpha: 0.5)
                : accentColor.withValues(alpha: 0.3),
            width: isRead ? 0.5 : 1.0,
          ),
          boxShadow: isRead
              ? null
              : [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(type),
                  color: isRead ? const Color(0xFF8B7355) : accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // ── Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] as String? ?? '',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              color: const Color(0xFF2D1F0E),
                              fontSize: 13,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                            ),
                          ),
                      ],
                    ),
                    if ((data['body'] as String? ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        data['body'] as String,
                        style: const TextStyle(
                          color: Color(0xFF8B7355),
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(data['created_at'] as String?, AppLocalizations.of(context)!),
                      style: const TextStyle(
                        color: Color(0xFFAA9E8F),
                        fontSize: 10,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
