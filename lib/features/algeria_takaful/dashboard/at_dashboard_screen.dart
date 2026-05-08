import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/enums/policy_status.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/providers/operator_providers.dart';
import '../../shared/domain/models/policy_model.dart';

class AtDashboardScreen extends ConsumerStatefulWidget {
  const AtDashboardScreen({super.key});
  @override
  ConsumerState<AtDashboardScreen> createState() => _AtDashboardScreenState();
}

class _AtDashboardScreenState extends ConsumerState<AtDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  List<PolicyModel> _filtered(List<PolicyModel> apps, String tab) {
    if (tab == 'new') {
      return apps.where((a) => a.status == PolicyStatus.pending).toList();
    }
    if (tab == 'processing') {
      return apps
          .where((a) => a.status == PolicyStatus.modificationRequested)
          .toList();
    }
    return apps
        .where(
          (a) =>
              a.status == PolicyStatus.accepted ||
              a.status == PolicyStatus.rejected,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(atPoliciesStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                policiesAsync.when(
                  data: (apps) => _buildStatCards(apps),
                  loading:
                      () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error: (err, stack) => Text('Error: $err'),
                ),
                TabBar(
                  controller: _tabs,
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  indicatorColor: AppColors.primaryGreen,
                  tabs: const [
                    Tab(text: 'جديد'),
                    Tab(text: 'قيد المعالجة'),
                    Tab(text: 'مكتمل'),
                  ],
                ),
                Expanded(
                  child: policiesAsync.when(
                    data:
                        (apps) => TabBarView(
                          controller: _tabs,
                          children: [
                            _buildAppList(_filtered(apps, 'new')),
                            _buildAppList(_filtered(apps, 'processing')),
                            _buildAppList(_filtered(apps, 'done')),
                          ],
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Portal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Text(
                  'الجزائر للتكافل',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _navItem(Icons.dashboard, 'لوحة التحكم', true, () {}),
          _navItem(
            Icons.account_balance_wallet_outlined,
            'توزيع الفائض',
            false,
            () => context.go('/at/surplus'),
          ),
          _navItem(Icons.settings_outlined, 'الإعدادات', false, () {}),
          const Spacer(),
          _navItem(
            Icons.logout,
            'تسجيل الخروج',
            false,
            () => context.go('/at/login'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(8),
          border:
              active
                  ? const Border(
                    right: BorderSide(color: AppColors.primaryGreen, width: 3),
                  )
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  active ? AppColors.primaryGreen : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color:
                    active
                        ? AppColors.primaryGreen
                        : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Algeria Takaful',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.person, color: AppColors.primaryGreen, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(List<PolicyModel> apps) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _statCard(
            'الطلبات الجديدة',
            '${_filtered(apps, "new").length}',
            AppColors.pending,
            Icons.inbox_outlined,
          ),
          const SizedBox(width: 12),
          _statCard(
            'قيد المعالجة',
            '${_filtered(apps, "processing").length}',
            AppColors.modRequested,
            Icons.pending_actions_outlined,
          ),
          const SizedBox(width: 12),
          _statCard(
            'مكتملة اليوم',
            '${_filtered(apps, "done").length}',
            AppColors.accepted,
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppList(List<PolicyModel> apps) {
    if (apps.isEmpty) return const Center(child: Text('لا توجد طلبات'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (ctx, i) {
        final app = apps[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  app.applicantName.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.applicantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${app.type} • ${DateFormat('yyyy-MM-dd').format(app.submittedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: app.status),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
                onPressed: () => context.push('/at/application/${app.id}'),
              ),
            ],
          ),
        );
      },
    );
  }
}
