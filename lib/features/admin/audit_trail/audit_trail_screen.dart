import 'package:flutter/material.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/features/admin/widgets/admin_shared_widgets.dart';
import 'package:tameenidz/features/shared/domain/models/audit_model.dart';
import '../dashboard/admin_providers.dart';

class AuditTrailScreen extends ConsumerStatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  ConsumerState<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends ConsumerState<AuditTrailScreen> {
  String _typeFilter = 'all';
  String _portalFilter = 'all';
  DateTimeRange? _range;

  List<AuditModel> _filterLogs(List<AuditModel> logs) {
    return logs.where((log) {
      if (_typeFilter != 'all') {
        final a = log.action.toLowerCase();
        if (_typeFilter == 'payment' && !a.contains('pay') && !a.contains('gateway')) {
          return false;
        }
        if (_typeFilter == 'policy' && !a.contains('policy')) return false;
        if (_typeFilter == 'login' && !a.contains('login')) return false;
      }
      if (_portalFilter != 'all') {
        final portal = _portalFromAction(log.action);
        if (_portalFilter == 'client' && portal != 'Client Portal') return false;
        if (_portalFilter == 'operator' && portal != 'Operations Portal') return false;
        if (_portalFilter == 'admin' && portal != 'Admin Portal') return false;
      }
      if (_range != null) {
        if (log.createdAt.isBefore(_range!.start)) return false;
        if (log.createdAt.isAfter(_range!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auditAsync = ref.watch(auditLogsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: buildAdminAppBar(context, l10n.legalRecord),
      bottomNavigationBar: adminBottomNav(context, 2, l10n),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D1F0E), Color(0xFF4A3520)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.transactionsLog,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.surface,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.auditSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE5DDD0),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip(
                  l10n.actionType,
                  Icons.filter_list_rounded,
                  () => _pickTypeFilter(context),
                  _typeFilter == 'all' ? null : _typeFilter,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  l10n.timeRange,
                  Icons.date_range_rounded,
                  () => _pickDateRange(context),
                  _range == null
                      ? null
                      : DateFormat('dd/MM').format(_range!.start),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  l10n.portal,
                  Icons.hub_outlined,
                  () => _pickPortalFilter(context),
                  _portalFilter == 'all' ? null : _portalFilter,
                ),
                if (_typeFilter != 'all' || _portalFilter != 'all' || _range != null) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text(l10n.clear, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                    onPressed: () => setState(() {
                      _typeFilter = 'all';
                      _portalFilter = 'all';
                      _range = null;
                    }),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: auditAsync.when(
              data: (logs) {
                final filtered = _filterLogs(logs);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noLogsFound,
                      style: const TextStyle(
                        color: Color(0xFF8B7355),
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildAuditItem(context, filtered[index]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
              ),
              error: (err, stack) => Center(
                child: Text(
                  '${l10n.unexpectedError}: $err',
                  style: const TextStyle(color: Color(0xFFA03030), fontFamily: 'Cairo'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTypeFilter(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.allTypes), onTap: () => Navigator.pop(c, 'all')),
            ListTile(title: Text(l10n.policies), onTap: () => Navigator.pop(c, 'policy')),
            ListTile(title: Text(l10n.payments), onTap: () => Navigator.pop(c, 'payment')),
            ListTile(title: Text(l10n.loginAction), onTap: () => Navigator.pop(c, 'login')),
          ],
        ),
      ),
    );
    if (v != null) setState(() => _typeFilter = v);
  }

  Future<void> _pickPortalFilter(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.allPortals), onTap: () => Navigator.pop(c, 'all')),
            ListTile(title: Text(l10n.client), onTap: () => Navigator.pop(c, 'client')),
            ListTile(title: Text(l10n.operatorLabel), onTap: () => Navigator.pop(c, 'operator')),
            ListTile(title: Text(l10n.adminRoleLabel), onTap: () => Navigator.pop(c, 'admin')),
          ],
        ),
      ),
    );
    if (v != null) setState(() => _portalFilter = v);
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Widget _filterChip(String label, IconData icon, VoidCallback onTap, String? value) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value != null ? const Color(0xFFC9A96E) : const Color(0xFFE5DDD0),
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              value ?? label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D1F0E),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: const Color(0xFF8B7355)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditItem(BuildContext context, AuditModel log) {
    Color statusColor = const Color(0xFFC9A96E);
    if (log.statusColor == 'accepted') statusColor = const Color(0xFF3A7D4E);
    if (log.statusColor == 'rejected') statusColor = const Color(0xFFA03030);

    final ts = DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DDD0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForAction(log.action), color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D1F0E),
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.userName} • $ts',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B7355),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _portalFromAction(log.action),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B7355),
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _portalFromAction(String action) {
    final lower = action.toLowerCase();
    if (lower.contains('operator') || lower.contains('payment_gateway')) {
      return 'Operations Portal';
    }
    if (lower.contains('admin')) return 'Admin Portal';
    return 'Client Portal';
  }

  IconData _iconForAction(String action) {
    final lower = action.toLowerCase();
    if (lower.contains('pay') || lower.contains('gateway')) return Icons.payment;
    if (lower.contains('policy')) return Icons.description_outlined;
    if (lower.contains('login')) return Icons.login;
    return Icons.history;
  }
}
