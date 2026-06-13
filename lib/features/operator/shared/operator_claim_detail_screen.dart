import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/core/services/notification_helper.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/providers/supabase_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Operator Claim Detail Screen (shared between AT & AI)
// ─────────────────────────────────────────────────────────────────────────────
// Flow:
//   1. View claim info (description, date, location, documents)
//   2. Assign expert (stage 2)
//   3. Enter damage estimate / approved amount
//   4. Issue repair order (stage 3) or reject
// ─────────────────────────────────────────────────────────────────────────────

class OperatorClaimDetailScreen extends ConsumerStatefulWidget {
  final String claimId;
  final String source; // 'legacy' (client_claims) or 'wizard' (client_policies)
  final String operatorCode; // 'algeria_takaful' or 'al_ittihad'

  const OperatorClaimDetailScreen({
    super.key,
    required this.claimId,
    required this.source,
    required this.operatorCode,
  });

  @override
  ConsumerState<OperatorClaimDetailScreen> createState() =>
      _OperatorClaimDetailScreenState();
}

class _OperatorClaimDetailScreenState
    extends ConsumerState<OperatorClaimDetailScreen> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _expertCtrl = TextEditingController();

  Map<String, dynamic>? _claim;
  bool _loading = true;
  bool _saving = false;
  late AppLocalizations l10n;

  // ── Colors per operator ──
  Color get _accent => widget.operatorCode == 'algeria_takaful'
      ? const Color(0xFF1B5E20) // Takaful green
      : kGoldDeep;             // Ittihad gold

  String get _tableName =>
      widget.source == 'wizard' ? 'client_policies' : 'client_claims';

  @override
  void initState() {
    super.initState();
    _loadClaim();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _expertCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClaim() async {
    try {
      final data = await Supabase.instance.client
          .from(_tableName)
          .select()
          .eq('id', widget.claimId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _claim = data;
          _loading = false;
          // Pre-fill amount if already set
          final existingAmount = data?['amount_approved'] ?? data?['amount'];
          if (existingAmount != null) {
            _amountCtrl.text = existingAmount.toString();
          }
          // Pre-fill expert name from metadata
          final meta = data?['metadata'] as Map<String, dynamic>?;
          if (meta != null && meta['expert_name'] != null) {
            _expertCtrl.text = meta['expert_name'] as String;
          }
          if (data?['admin_notes'] != null) {
            _notesCtrl.text = data!['admin_notes'] as String;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Stage management ──
  int get _currentStage {
    final meta = _claim?['metadata'] as Map<String, dynamic>?;
    return meta?['stage'] as int? ?? 1;
  }

  String get _currentStatus =>
      _claim?['status'] as String? ?? 'pending';

  Future<void> _updateClaim(Map<String, dynamic> updates) async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client
          .from(_tableName)
          .update(updates)
          .eq('id', widget.claimId);

      // Notify client
      final clientId = _claim?['client_id'] as String?;
      if (clientId != null) {
        final newStatus = updates['status'] as String?;
        if (newStatus != null) {
          NotificationHelper.notifyClientStatusChange(
            clientId: clientId,
            status: newStatus,
            policyId: widget.claimId,
            planName: _claim?['plan_name'] as String?,
            privilegedClient: ref.read(privilegedSupabaseProvider),
          );
        }
      }

      await _loadClaim();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateSuccess,
                style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: kStatusAccepted,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError(e.toString())), backgroundColor: kStatusRejected),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _assignExpert() async {
    if (_expertCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterExpertName,
              style: GoogleFonts.ibmPlexSansArabic()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final meta = Map<String, dynamic>.from(
        _claim?['metadata'] as Map<String, dynamic>? ?? {});
    meta['stage'] = 2;
    meta['expert_name'] = _expertCtrl.text.trim();
    meta['expert_assigned_at'] = DateTime.now().toIso8601String();

    await _updateClaim({
      'status': 'under_review',
      'metadata': meta,
    });
  }

  Future<void> _approveWithAmount() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterValidAmount,
              style: GoogleFonts.ibmPlexSansArabic()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final meta = Map<String, dynamic>.from(
        _claim?['metadata'] as Map<String, dynamic>? ?? {});
    meta['stage'] = 3;
    meta['repair_order_at'] = DateTime.now().toIso8601String();

    await _updateClaim({
      'status': 'accepted',
      'amount_approved': amount,
      'admin_notes': _notesCtrl.text.trim(),
      'metadata': meta,
      'resolved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _rejectClaim() async {
    if (_notesCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterRejectionReason,
              style: GoogleFonts.ibmPlexSansArabic()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _updateClaim({
      'status': 'rejected',
      'admin_notes': _notesCtrl.text.trim(),
      'resolved_at': DateTime.now().toIso8601String(),
    });
  }

  // ── BUILD ──
  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kIvory,
        appBar: AppBar(
          backgroundColor: kIvory,
          elevation: 0,
          centerTitle: true,
          title: Column(children: [
            Text(
              l10n.claimDetailTitle,
              style: GoogleFonts.amiri(
                color: _accent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.operatorCode == 'algeria_takaful'
                  ? l10n.takafulPortal
                  : l10n.ittihadPortal,
              style: GoogleFonts.ibmPlexSansArabic(
                  color: kInkMuted, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ]),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded, color: _accent),
            onPressed: () => context.pop(),
          ),
        ),
        body: PageEntryAnimation(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: _accent))
              : _claim == null
                  ? Center(
                      child: Text(l10n.noData,
                          style: GoogleFonts.ibmPlexSansArabic()))
                  : _buildContent(l10n),
        ),
        bottomNavigationBar:
            (!_loading && _claim != null) ? _buildBottomActions() : null,
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final meta = _claim!['metadata'] as Map<String, dynamic>? ?? {};
    final description = _claim!['description'] as String? ?? '';
    final clientName = _claim!['client_name'] as String? ?? l10n.defaultClientName;
    final claimType = _claim!['claim_type'] as String? ?? 'general';
    final location = meta['location'] as String? ?? '';
    final incidentDate = meta['incident_date'] as String? ?? '';
    final docUrls = meta['document_urls'] as Map<String, dynamic>? ?? {};
    final createdAt = _claim!['created_at'] as String? ??
        _claim!['submitted_at'] as String? ??
        '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + ID row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(_currentStatus),
              Text(
                'ID: ${widget.claimId.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.ibmPlexSansArabic(
                    color: kInkMuted, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Client Info ──
          _sectionTitle(l10n.clientInfo),
          const SizedBox(height: 12),
          _infoCard(
            icon: Icons.person_rounded,
            title: clientName,
            subtitle: l10n.requestTypeLabel(_claimTypeLabel(claimType, l10n)),
            details: [
              if (createdAt.isNotEmpty)
                (l10n.submissionDate, _formatDate(createdAt)),
              if (incidentDate.isNotEmpty)
                (l10n.incidentDate, _formatDate(incidentDate)),
              if (location.isNotEmpty) (l10n.incidentLocation, location),
            ],
          ),

          const SizedBox(height: 24),
          _sectionTitle(l10n.incidentDescription),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kParchment),
              boxShadow: [kCardShadow],
            ),
            child: Text(
              description.isNotEmpty ? description : l10n.noDescription,
              style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14, height: 1.8, color: kInk),
            ),
          ),

          // ── Documents ──
          if (docUrls.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.attachedDocumentsCount(docUrls.length.toString())),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: docUrls.entries.map((e) {
                return _docButton(
                    _docLabel(e.key), e.value?.toString() ?? '');
              }).toList(),
            ),
          ],

          // ── Stage Progress ──
          const SizedBox(height: 24),
          _sectionTitle(l10n.claimProcessStages),
          const SizedBox(height: 12),
          _buildStageProgress(),

          // ── Expert Assignment (Stage 1 → 2) ──
          if (_currentStatus == 'pending' ||
              _currentStatus == 'under_review') ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.assignExpert),
            const SizedBox(height: 12),
            TextField(
              controller: _expertCtrl,
              decoration: InputDecoration(
                hintText: l10n.enterExpertNameHint,
                filled: true,
                fillColor: kCream,
                prefixIcon:
                    Icon(Icons.person_search_rounded, color: _accent, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            if (_currentStage < 2) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _assignExpert,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(l10n.assignExpertAndStartInspection,
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],

          // ── Damage Amount (Stage 2 → 3) ──
          if (_currentStatus != 'accepted' &&
              _currentStatus != 'rejected') ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.estimateDamageAmount),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: l10n.enterEstimatedAmountHint,
                filled: true,
                fillColor: kCream,
                prefixIcon: Icon(Icons.attach_money_rounded,
                    color: _accent, size: 20),
                suffixText: l10n.dzd,
                suffixStyle: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.bold, color: _accent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.ibmPlexSansArabic(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _sectionTitle(l10n.reviewNotes),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.writeNotesHint,
                filled: true,
                fillColor: kCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
          ],

          // ── Show approved amount if already decided ──
          if (_currentStatus == 'accepted') ...[
            const SizedBox(height: 24),
            _infoCard(
              icon: Icons.check_circle_rounded,
              iconColor: kStatusAccepted,
              title: l10n.claimAccepted,
              subtitle: l10n.approvedAmount,
              details: [
                (l10n.compensationAmount,
                    l10n.compensationAmountDzd(intl.NumberFormat('#,###').format(_claim!['amount_approved'] ?? 0))),
                if (_claim!['admin_notes'] != null)
                  (l10n.notes, _claim!['admin_notes'] as String),
              ],
            ),
          ],
          if (_currentStatus == 'rejected') ...[
            const SizedBox(height: 24),
            _infoCard(
              icon: Icons.cancel_rounded,
              iconColor: kStatusRejected,
              title: l10n.claimRejected,
              subtitle: l10n.rejectionReason,
              details: [
                if (_claim!['admin_notes'] != null)
                  (l10n.notesLabel, _claim!['admin_notes'] as String),
              ],
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Bottom action bar ──
  Widget? _buildBottomActions() {
    if (_currentStatus == 'accepted' || _currentStatus == 'rejected') {
      return null;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kParchment)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saving ? null : _rejectClaim,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(l10n.rejectFile,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kStatusRejected,
                side: const BorderSide(color: kStatusRejected),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _approveWithAmount,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(
                  _currentStage >= 2 ? l10n.acceptAndIssueRepairOrder : l10n.acceptCompensation,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kStatusAccepted,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stage progress widget ──
  Widget _buildStageProgress() {
    final stages = [
      (Icons.inbox_rounded, l10n.stageFileReceived, l10n.stageDocumentsReceived),
      (Icons.person_search_rounded, l10n.stageAssignExpert, l10n.stageDamageInspection),
      (Icons.car_repair_rounded, l10n.stageRepairOrder, l10n.stageRepairDirect),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kParchment),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        children: stages.asMap().entries.map((e) {
          final idx = e.key;
          final s = e.value;
          final done = idx < _currentStage;
          final active = idx == _currentStage - 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: done
                      ? _accent
                      : active
                          ? _accent.withValues(alpha: 0.15)
                          : kParchment,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Icon(s.$1,
                          size: 18,
                          color: active ? _accent : kInkMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$2,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: done || active ? kInk : kInkMuted,
                          )),
                      Text(s.$3,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            color: kInkMuted,
                          )),
                    ]),
              ),
              if (done)
                const Icon(Icons.check_circle, size: 16, color: kStatusAccepted),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Helpers ──
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.amiri(
          fontSize: 17, fontWeight: FontWeight.bold, color: _accent),
    );
  }

  Widget _buildStatusChip(String status) {
    final (label, color) = switch (status) {
      'pending' => (l10n.statusPendingLabel, Colors.orange),
      'under_review' => (l10n.statusUnderReview, const Color(0xFF0D47A1)),
      'accepted' || 'approved' => (l10n.statusAcceptedLabel, kStatusAccepted),
      'rejected' => (l10n.statusRejectedLabel, kStatusRejected),
      _ => (status, kInkMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<(String, String)> details,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kParchment),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: (iconColor ?? _accent).withValues(alpha: 0.12),
              child: Icon(icon, color: iconColor ?? _accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle,
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11, color: kInkMuted)),
                  ]),
            ),
          ]),
          if (details.isNotEmpty) ...[
            const Divider(height: 24),
            ...details.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.$1,
                          style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13, color: kInkMuted)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(d.$2,
                            style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _docButton(String label, String url) {
    return OutlinedButton.icon(
      onPressed: url.isNotEmpty ? () => _openDoc(url) : null,
      icon: Icon(Icons.file_present_rounded, size: 14, color: _accent),
      label: Text(label,
          style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 11, color: _accent),
          overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        side: BorderSide(color: _accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _openDoc(String url) async {
    try {
      String finalUrl = url;
      if (!url.startsWith('http')) {
        finalUrl = await Supabase.instance.client.storage
            .from('documents')
            .createSignedUrl(url, 60);
      }
      final uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return intl.DateFormat('yyyy/MM/dd').format(dt);
  }

  String _docLabel(String key) {
    return switch (key) {
      'driving_license_url' => l10n.docDrivingLicense,
      'grey_card_url' => l10n.docGreyCard,
      'friendly_inspection_url' => l10n.docFriendlyInspection,
      'rc_card_url' => l10n.docRcCard,
      _ when key.startsWith('car_photo') =>
        l10n.docCarPhoto(key.replaceAll(RegExp(r'[^0-9]'), '')),
      _ when key.startsWith('damage_photo') =>
        l10n.docDamagePhoto(key.replaceAll(RegExp(r'[^0-9]'), '')),
      _ => key.replaceAll('_', ' '),
    };
  }

  String _claimTypeLabel(String type, AppLocalizations l10n) {
    return switch (type) {
      'accident' => l10n.claimTypeAccident,
      'general' => l10n.claimTypeGeneral,
      'theft' => l10n.claimTypeTheft,
      'fire' => l10n.claimTypeFire,
      _ => type,
    };
  }
}
