import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/features/client/policies/policy_providers.dart';
import 'package:tameenidz/core/providers/notification_providers.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _pushEnabled = false;

  DateTime _expiryDate(PolicyModel policy) {
    final base = policy.paidAt ?? policy.submittedAt;
    return DateTime(base.year + 1, base.month, base.day);
  }

  int _daysLeft(PolicyModel policy) {
    final exp = _expiryDate(policy);
    return exp.difference(DateTime.now()).inDays;
  }

  String _operatorName(String opId, AppLocalizations l10n) {
    switch (opId) {
      case 'algeria_takaful': return l10n.algerTakaful;
      case 'al_ittihad':      return l10n.alIttihad;
      default:                return opId;
    }
  }

  String _planLabel(PolicyModel p) => p.planName ?? p.planId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final policiesAsync = ref.watch(clientPoliciesStreamProvider);
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          l10n.alerts,
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.trackContractExpiry,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
      body: policiesAsync.when(
        data: (allPolicies) {
          final contracts = allPolicies
              .where((p) => p.status == PolicyStatus.paid || p.status == PolicyStatus.accepted)
              .toList();
          final urgentContracts = contracts.where((p) {
            final days = _daysLeft(p);
            return days >= 0 && days <= 15;
          }).toList();

          return notificationsAsync.when(
            data: (generalNotifs) {
              final unreadCount = generalNotifs.where((n) => n['is_read'] != true).length;

              return PageEntryAnimation(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(clientPoliciesStreamProvider);
                    ref.invalidate(myNotificationsProvider);
                  },
                  color: AppColors.primaryGreen,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      if (!_pushEnabled) _buildEnablePushBanner(colors, l10n),
                      if (!_pushEnabled) const SizedBox(height: 20),

                      if (urgentContracts.isNotEmpty) ...[
                        _sectionLabel(l10n.activeAlertCount(urgentContracts.length), colors, isAlert: true),
                        const SizedBox(height: 10),
                        ...urgentContracts.map((p) => _buildUrgentAlert(p, colors, l10n)),
                        const SizedBox(height: 20),
                      ],

                      if (contracts.isNotEmpty) ...[
                        _sectionLabel(l10n.allMyContracts, colors),
                        const SizedBox(height: 10),
                        ...contracts.map((p) => _buildContractRow(p, colors, l10n)),
                        const SizedBox(height: 20),
                      ],

                      if (generalNotifs.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionLabel(l10n.generalNotifications, colors),
                            if (unreadCount > 0)
                              TextButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref.read(notificationRepositoryProvider).markAllAsRead();
                                  } catch (e) {
                                    debugPrint('Error marking all as read: $e');
                                  }
                                },
                                icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primaryGreen),
                                label: Text(
                                  l10n.markAllAsRead,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 12,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...generalNotifs.map((n) => _buildNotifCard(n, colors)),
                      ],

                      if (contracts.isEmpty && generalNotifs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_none_outlined, size: 64, color: colors.slate300),
                                const SizedBox(height: 12),
                                Text(l10n.noAlertsCurrently,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      color: colors.slate500,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (e, _) => Center(
              child: Text(
                l10n.errorGeneric(e.toString()),
                style: GoogleFonts.ibmPlexSansArabic(color: colors.slate500),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (e, _) => Center(
          child: Text(
            l10n.errorGeneric(e.toString()),
            style: GoogleFonts.ibmPlexSansArabic(color: colors.slate500),
          ),
        ),
      ),
    );
  }

  Widget _buildEnablePushBanner(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.warmDivider),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: colors.slate500, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.enablePushNotifications,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colors.primaryText)),
                Text(l10n.autoAlertBefore15Days,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11, color: colors.slate500)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => setState(() => _pushEnabled = true),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.enable,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlert(PolicyModel policy, AppColorsExtension colors, AppLocalizations l10n) {
    final days = _daysLeft(policy);
    final expiry = _expiryDate(policy);
    final expiryStr = intl.DateFormat('yyyy/M/d').format(expiry);
    final plan = _planLabel(policy);
    final op = _operatorName(policy.operatorId, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(l10n.urgentAlert,
                          style: GoogleFonts.ibmPlexSansArabic(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.daysRemaining(days),
                        style: GoogleFonts.ibmPlexSansArabic(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l10n.contractExpiresIn15Days,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1F2937))),
                const SizedBox(height: 2),
                Text('$plan — $op',
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12, color: const Color(0xFF6B7280))),
                Text(l10n.expiryDateLabel(expiryStr),
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
        ],
      ),
    );
  }

  Widget _buildContractRow(PolicyModel policy, AppColorsExtension colors, AppLocalizations l10n) {
    final days = _daysLeft(policy);
    final expiry = _expiryDate(policy);
    final expiryStr = intl.DateFormat('yyyy/M/d').format(expiry);
    final plan = _planLabel(policy);
    final op = _operatorName(policy.operatorId, l10n);
    final isUrgent = days >= 0 && days <= 15;
    final isExpired = days < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.warmDivider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(plan,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colors.primaryText)),
              Text(op,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12, color: colors.slate500)),
              Text(expiryStr,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11, color: colors.slate500)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpired ? l10n.expired : l10n.daysUnit(days),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isExpired
                      ? Colors.red
                      : isUrgent
                          ? const Color(0xFFF59E0B)
                          : AppColors.primaryGreen,
                ),
              ),
              if (!isExpired)
                Text(expiryStr,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 10, color: colors.slate500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(Map<String, dynamic> n, AppColorsExtension colors) {
    final bool isRead = n['is_read'] ?? false;
    final String notifId = n['id'] ?? '';
    return GestureDetector(
      onTap: isRead || notifId.isEmpty
          ? null
          : () async {
              try {
                await ref.read(notificationRepositoryProvider).markAsRead(notifId);
              } catch (e) {
                debugPrint('Error marking notification as read: $e');
              }
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.beigeCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? colors.warmDivider : AppColors.primaryGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead ? Colors.grey.shade400 : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n['title'] ?? '',
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 13,
                          color: colors.primaryText)),
                  if ((n['body'] ?? '').isNotEmpty)
                    Text(n['body'] ?? '',
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12, color: colors.slate500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, AppColorsExtension colors, {bool isAlert = false}) {
    return Text(
      label,
      style: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: isAlert ? const Color(0xFF059669) : colors.primaryText,
      ),
    );
  }
}
