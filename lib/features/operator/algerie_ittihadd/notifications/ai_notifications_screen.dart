import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';

import 'package:tameenidz/core/providers/notification_providers.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';

class AiNotificationsScreen extends ConsumerWidget {
  const AiNotificationsScreen({super.key});

  String _formatTimestamp(String? ts) {
    if (ts == null) return '';
    final dt = DateTime.tryParse(ts);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return intl.DateFormat('yyyy/M/d – HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const scaffoldBg = kIvory;
    const textDark = kInk;
    const textMuted = kInkMuted;
    const accentColor = kGoldDeep;
    const cardBg = kCream;
    const borderCol = kDivider;
    
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
              color: accentColor,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'إشعارات الاتحاد للتأمين',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          centerTitle: true,
          actions: [
            notificationsAsync.maybeWhen(
              data: (list) {
                final hasUnread = list.any((n) => n['is_read'] != true);
                if (!hasUnread) return const SizedBox.shrink();
                return TextButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(notificationRepositoryProvider).markAllAsRead();
                    } catch (e) {
                      debugPrint('Error marking all as read: $e');
                    }
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: accentColor),
                  label: Text(
                    'تحديد الكل',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: accentColor),
          ),
          error: (e, _) => Center(
            child: Text(
              'خطأ في تحميل الإشعارات: $e',
              style: GoogleFonts.ibmPlexSansArabic(color: textMuted),
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myNotificationsProvider);
              },
              color: accentColor,
              backgroundColor: scaffoldBg,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  final bool isRead = n['is_read'] ?? false;
                  final String notifId = n['id'] ?? '';
                  final String? referenceId = n['reference_id'] as String?;

                  return GestureDetector(
                    onTap: () async {
                      if (!isRead && notifId.isNotEmpty) {
                        try {
                          await ref.read(notificationRepositoryProvider).markAsRead(notifId);
                        } catch (e) {
                          debugPrint('Error marking notification as read: $e');
                        }
                      }
                      if (!context.mounted) return;
                      if (referenceId != null && referenceId.isNotEmpty) {
                        context.push('/ai/application/$referenceId');
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRead 
                              ? borderCol 
                              : accentColor.withValues(alpha: 0.3),
                          width: isRead ? 1.0 : 1.5,
                        ),
                        boxShadow: isRead 
                            ? null 
                            : [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRead ? Colors.grey.shade400 : accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'] ?? '',
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                          fontSize: 13.5,
                                          color: textDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTimestamp(n['created_at'] as String?),
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontSize: 10,
                                        color: textMuted.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                if ((n['body'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    n['body'] ?? '',
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 12,
                                      color: textMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (referenceId != null && referenceId.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: accentColor.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
