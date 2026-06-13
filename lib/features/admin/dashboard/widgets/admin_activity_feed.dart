import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../admin_providers.dart';

class AdminActivityFeed extends ConsumerWidget {
  final bool isMobile;

  const AdminActivityFeed({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auditAsync = ref.watch(auditLogsStreamProvider);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMobile ? l10n.latestActivitiesAdmin : l10n.latestAuditLogs,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1F0E),
                  fontFamily: 'Cairo',
                ),
              ),
              TextButton(
                onPressed: () => context.push('/admin/audit'),
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC9A96E),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          auditAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.noLogsYet,
                      style: const TextStyle(
                        color: Color(0xFF8B7355),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: logs.take(5).map((l) {
                  const c = Color(0xFFC9A96E); // Use gold for all icons

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: c,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.action,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D1F0E),
                                  fontFamily: 'Cairo',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${l.userName} • ${DateFormat('HH:mm').format(l.createdAt)}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8B7355),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd').format(l.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B7355),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
          ),
        ],
      ),
    );
  }
}
