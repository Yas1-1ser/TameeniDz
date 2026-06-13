import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

// ─────────────────────────────────────────────────────────────────────────────
// Client Claim Detail Screen
// Shows the full claim info, documents, and real-time stage progress.
// ─────────────────────────────────────────────────────────────────────────────

class ClientClaimDetailScreen extends StatefulWidget {
  final String claimId;
  const ClientClaimDetailScreen({super.key, required this.claimId});

  @override
  State<ClientClaimDetailScreen> createState() =>
      _ClientClaimDetailScreenState();
}

class _ClientClaimDetailScreenState extends State<ClientClaimDetailScreen> {
  Map<String, dynamic>? _claim;
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _sub = Supabase.instance.client
        .from('client_claims')
        .stream(primaryKey: ['id'])
        .eq('id', widget.claimId)
        .listen((data) {
      if (mounted) {
        setState(() {
          _claim = data.isNotEmpty ? data.first : null;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F6F0),
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.claimDetailTitle,
            style: GoogleFonts.amiri(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => context.pop(),
          ),
        ),
        body: PageEntryAnimation(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen))
              : _claim == null
                  ? Center(child: Text(l10n.noData))
                  : _buildContent(l10n),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final meta = _claim!['metadata'] as Map<String, dynamic>? ?? {};
    final description = _claim!['description'] as String? ?? '';
    final claimType = _claim!['claim_type'] as String? ?? 'general';
    final status = _claim!['status'] as String? ?? 'pending';
    final stage = meta['stage'] as int? ?? 1;
    final location = meta['location'] as String? ?? '';
    final incidentDate = meta['incident_date'] as String? ?? '';
    final expertName = meta['expert_name'] as String? ?? '';
    final docUrls = meta['document_urls'] as Map<String, dynamic>? ?? {};
    final amountApproved = _claim!['amount_approved'];
    final adminNotes = _claim!['admin_notes'] as String? ?? '';
    final createdAt = _claim!['created_at'] as String? ??
        _claim!['submitted_at'] as String? ??
        '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + ID ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusChip(status, l10n),
              Text(
                'ID: ${widget.claimId.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.ibmPlexSansArabic(
                    color: Colors.grey, fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stage Progress ──
          _sectionTitle(l10n.claimProcessStages),
          const SizedBox(height: 16),
          _buildStageProgress(stage, l10n),

          const SizedBox(height: 24),
          _sectionTitle(l10n.requestInfo),
          const SizedBox(height: 12),
          _infoCard([
            (l10n.requestTypeLabel(_claimTypeLabel(claimType, l10n)), ''),
            if (createdAt.isNotEmpty) (l10n.submissionDate, _formatDate(createdAt)),
            if (incidentDate.isNotEmpty)
              (l10n.incidentDate, _formatDate(incidentDate)),
            if (location.isNotEmpty) (l10n.incidentLocation, location),
          ].where((d) => d.$2.isNotEmpty).toList()),

          // ── Description ──
          const SizedBox(height: 24),
          _sectionTitle(l10n.incidentDescription),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              description.isNotEmpty ? description : l10n.noDescription,
              style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14, height: 1.8),
            ),
          ),

          // ── Expert Info ──
          if (expertName.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.assignedExpert),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF0D47A1).withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF0D47A1),
                  radius: 18,
                  child: Icon(Icons.person_search_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(expertName,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
            ),
          ],

          // ── Approved Amount ──
          if (amountApproved != null && status == 'accepted') ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.approvedCompensationAmount),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.08),
                    AppColors.primaryGreen.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryGreen, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    l10n.compensationAmountDzd(
                        intl.NumberFormat('#,###').format(amountApproved)),
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Rejection Reason ──
          if (status == 'rejected' && adminNotes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.rejectionReason),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(adminNotes,
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 14, height: 1.6)),
                  ),
                ],
              ),
            ),
          ],

          // ── Documents ──
          if (docUrls.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.attachedDocumentsCount(docUrls.length.toString())),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: docUrls.entries.map((e) {
                return InkWell(
                  onTap: () => _openDoc(e.value?.toString() ?? ''),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Icon(Icons.file_present_rounded,
                          color: AppColors.goldAccent, size: 22),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _docLabel(e.key, l10n),
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Stage Progress ──
  Widget _buildStageProgress(int stage, AppLocalizations l10n) {
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: stages.asMap().entries.map((e) {
          final idx = e.key;
          final s = e.value;
          final done = idx < stage;
          final active = idx == stage - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: idx < 2 ? 16 : 0),
            child: Row(children: [
              Column(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.primaryGreen
                        : active
                            ? AppColors.goldAccent
                            : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : Icon(s.$1,
                            size: 20,
                            color: active
                                ? Colors.white
                                : Colors.grey.shade400),
                  ),
                ),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$2,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: done || active
                                ? Colors.black87
                                : Colors.grey,
                          )),
                      Text(s.$3,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12,
                            color: Colors.grey,
                          )),
                    ]),
              ),
              if (done)
                const Icon(Icons.check_circle,
                    size: 18, color: AppColors.primaryGreen),
              if (active)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.inProgress,
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldAccent)),
                ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Helpers ──
  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.amiri(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen));
  }

  Widget _statusChip(String status, AppLocalizations l10n) {
    final (label, color) = switch (status) {
      'pending' => (l10n.statusPendingLabel, Colors.orange),
      'under_review' => (l10n.statusUnderReview, const Color(0xFF0D47A1)),
      'accepted' || 'approved' => (l10n.statusAcceptedLabel, AppColors.primaryGreen),
      'rejected' => (l10n.statusRejectedLabel, Colors.red),
      _ => (status, Colors.grey),
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

  Widget _infoCard(List<(String, String)> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: details
            .map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Text(d.$1,
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(d.$2,
                          style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                    ),
                  ]),
                ))
            .toList(),
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

  String _docLabel(String key, AppLocalizations l10n) {
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
