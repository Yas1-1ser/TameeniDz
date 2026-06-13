import 'package:flutter/material.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/utils/commission_utils.dart';
import 'package:tameenidz/core/utils/number_utils.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
class _PolicyRow {
  final String id;
  final String clientName;
  final String? nin;
  final String operatorId;
  final double premium;
  final double adminCommission;
  final bool isReturning;
  final DateTime createdAt;

  _PolicyRow({
    required this.id,
    required this.clientName,
    this.nin,
    required this.operatorId,
    required this.premium,
    required this.adminCommission,
    required this.isReturning,
    required this.createdAt,
  });
}

class SalesTableWidget extends StatefulWidget {
  const SalesTableWidget({super.key});

  @override
  State<SalesTableWidget> createState() => _SalesTableWidgetState();
}

class _SalesTableWidgetState extends State<SalesTableWidget> {
  List<_PolicyRow> _rows = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _getOperatorDisplay(String operatorId) {
    return operatorId == 'al_ittihad'
        ? AppLocalizations.of(context)!.algeriaUnited
        : AppLocalizations.of(context)!.operatorTakaful;
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await Supabase.instance.client
          .from('policies')
          .select(
            'id, amount, operator_id, submitted_at, applicant_id_number, applicant_full_name, client_id, status, metadata',
          )
          .order('submitted_at', ascending: false);

      final allPolicies = (response as List)
          .map((j) => PolicyModel.fromJson(Map<String, dynamic>.from(j)))
          .toList();

      final rows = <_PolicyRow>[];
      for (var i = 0; i < allPolicies.length; i++) {
        final p = allPolicies[i];
        final raw = (response as List)[i] as Map<String, dynamic>;
        final users = raw['users'] as Map<String, dynamic>?;
        final split = commissionSplitForPolicy(p, allPolicies);
        final name = p.applicantFullName ?? users?['full_name'] as String? ?? p.applicantName;
        final nin = p.nin ?? users?['nin'] as String?;
        rows.add(
          _PolicyRow(
            id: p.id,
            clientName: name,
            nin: nin,
            operatorId: p.operatorId,
            premium: p.amount,
            adminCommission: split['admin'] ?? 0,
            isReturning: isExistingClientForOperator(p, allPolicies),
            createdAt: p.submittedAt,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _rows = rows;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.errorLoadingData;
          _isLoading = false;
        });
      }
    }
  }

  void _showPolicyDetail(BuildContext context, _PolicyRow row) {
    final l10n = AppLocalizations.of(context)!;
    final nf = safeNumberFormat(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: context.colors.offWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.policyDetails, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _DetailRow(label: l10n.customer, value: row.clientName),
            _DetailRow(label: l10n.ninLabel, value: row.nin ?? '—'),
            _DetailRow(label: l10n.company, value: _getOperatorDisplay(row.operatorId)),
            _DetailRow(
              label: l10n.amount,
              value: '${nf.format(row.premium.toInt())} ${l10n.dzd}',
            ),
            _DetailRow(
              label: l10n.commission,
              value: '${nf.format(row.adminCommission.toInt())} ${l10n.dzd}',
              isProfit: true,
            ),
            _DetailRow(
              label: 'Client type',
              value: row.isReturning ? 'Returning (50/50)' : 'New (100% admin)',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nf = safeNumberFormat(context);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.takafulGreen),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(_error!, style: const TextStyle(color: AppColors.rejected)),
        ),
      );
    }

    final totalPremium = _rows.fold(0.0, (s, r) => s + r.premium);
    final totalAdmin = _rows.fold(0.0, (s, r) => s + r.adminCommission);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.takafulGreen,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.takafulGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _HeaderCell(l10n.customer, flex: 3),
                _HeaderCell(l10n.ninLabel, flex: 2),
                _HeaderCell(l10n.company, flex: 2),
                _HeaderCell(l10n.amount, flex: 2),
                _HeaderCell(l10n.commission, flex: 2, isProfit: true),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rows.length,
            itemBuilder: (context, i) {
              final row = _rows[i];
              return InkWell(
                onTap: () => _showPolicyDetail(context, row),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: i.isEven ? context.colors.offWhite : const Color(0xFFF0F7F4),
                  child: Row(
                    children: [
                      _DataCell(row.clientName, flex: 3),
                      _DataCell(row.nin ?? '—', flex: 2),
                      _DataCell(_getOperatorDisplay(row.operatorId), flex: 2),
                      _DataCell(nf.format(row.premium.toInt()), flex: 2),
                      _ProfitCell(nf.format(row.adminCommission.toInt()), flex: 2),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1A2634),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _TotalCell(l10n.total, flex: 3, bold: true, color: context.colors.offWhite),
                const Spacer(flex: 4),
                _TotalCell(nf.format(totalPremium.toInt()), flex: 2, color: context.colors.offWhite.withValues(alpha: 0.7)),
                _TotalCell(nf.format(totalAdmin.toInt()), flex: 2, color: AppColors.gold, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isProfit;
  const _HeaderCell(this.text, {required this.flex, this.isProfit = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isProfit ? AppColors.gold : context.colors.offWhite,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  const _DataCell(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: TextStyle(fontSize: 12, color: context.colors.darkText), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
    );
  }
}

class _ProfitCell extends StatelessWidget {
  final String text;
  final int flex;
  const _ProfitCell(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.takafulGreen), textAlign: TextAlign.center),
    );
  }
}

class _TotalCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color color;
  final bool bold;
  const _TotalCell(this.text, {required this.flex, required this.color, this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w900 : FontWeight.w500, color: color), textAlign: TextAlign.center),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isProfit;
  const _DetailRow({required this.label, required this.value, this.isProfit = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.colors.slate500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: isProfit ? AppColors.takafulGreen : context.colors.darkText)),
        ],
      ),
    );
  }
}
