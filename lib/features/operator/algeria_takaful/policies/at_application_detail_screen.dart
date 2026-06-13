import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/status_badge.dart';
import 'package:tameenidz/features/shared/enums/policy_status.dart';
import 'package:tameenidz/features/shared/providers/operator_providers.dart';
import 'package:tameenidz/features/shared/data/policy_repository.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AtApplicationDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const AtApplicationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<AtApplicationDetailScreen> createState() =>
      _AtApplicationDetailScreenState();
}

class _AtApplicationDetailScreenState
    extends ConsumerState<AtApplicationDetailScreen> {
  final _reasonCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  PlatformFile? _finalPolicyFile;
  bool _loading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _openDocument(String urlOrPath) async {
    if (urlOrPath.isEmpty) return;
    
    try {
      setState(() => _loading = true);
      String finalUrl = urlOrPath;
      
      String path = urlOrPath;
      if (path.contains('/storage/v1/object/public/documents/')) {
        path = path.split('/storage/v1/object/public/documents/').last;
      } else if (path.contains('/storage/v1/object/sign/documents/')) {
        path = path.split('/storage/v1/object/sign/documents/').last.split('?').first;
      }
      
      if (!path.startsWith('http')) {
        finalUrl = await Supabase.instance.client.storage
            .from('documents')
            .createSignedUrl(path, 60);
      }

      final uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorOpeningFile(e.toString())))
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(policyDetailStreamProvider(widget.id));
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kIvory,
        appBar: AppBar(
          backgroundColor: kIvory,
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                l10n.requestDetails,
                style: GoogleFonts.amiri(
                  color: kGoldDeep,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                l10n.takafulPortal,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: kInkMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(
              isEn ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              size: 24,
              color: kGoldDeep,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: PageEntryAnimation(
          child: policyAsync.when(
            data:
                (policy) =>
                    policy == null
                        ? Center(child: Text(l10n.noData))
                        : _buildContent(policy, l10n),
            loading:
                () => Center(
                  child: CircularProgressIndicator(color: kGoldDeep)
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 1200.ms),
                ),
            error: (err, _) => Center(child: Text(AppLocalizations.of(context)!.errorGeneric(err.toString()))),
          ),
        ),
        bottomNavigationBar: policyAsync.when(
          data:
              (policy) =>
                  policy != null
                      ? _buildBottomActions(policy, l10n)
                      : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildContent(PolicyModel policy, AppLocalizations l10n) {
    const stagger = Duration(milliseconds: 100);
    int i = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card with status + ID ────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kCardGradient,
              borderRadius: BorderRadius.circular(kRadiusLg),
              border: Border.all(color: kDivider),
              boxShadow: [kCardShadow],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        StatusBadge(status: policy.status),
                        const SizedBox(width: 8),
                        _buildRequestTypeBadge(policy, l10n),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kGoldDeep.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${policy.id.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: kGoldDeep,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Mini gold divider accent
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: kGoldGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: stagger * i++, curve: Curves.easeOut)
              .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: stagger * (i - 1)),

          const SizedBox(height: 24),

          // ── Subscriber info ────────────────────────────────────
          _buildSectionTitle(l10n.subscriberInfoFromRegistration)
              .animate()
              .fadeIn(duration: 400.ms, delay: stagger * i++),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.person_rounded,
            iconColor: kGoldDeep,
            iconBgColor: kGoldShimmer,
            title: policy.applicantName,
            subtitle: l10n.systemRegisteredData,
            details: [
              (l10n.phoneLabel, policy.applicantPhone ?? '—'),
              (l10n.ninLabel, policy.nin ?? '—'),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: stagger * i++, curve: Curves.easeOut)
              .slideX(begin: 0.04, end: 0, duration: 500.ms, delay: stagger * (i - 1)),

          const SizedBox(height: 24),

          // ── Plan details ───────────────────────────────────────
          _buildSectionTitle(l10n.takafulPlanDetails)
              .animate()
              .fadeIn(duration: 400.ms, delay: stagger * i++),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.shield_rounded,
            iconColor: kStatusAccepted,
            iconBgColor: const Color(0xFFE8F5E9),
            title: policy.planName ?? l10n.unspecifiedPlan,
            subtitle: l10n.coverageAndAmount,
            details: [
              (l10n.premiumColon, l10n.amountDzd(NumberFormat('#,###').format(policy.amount))),
              (
                l10n.submissionDateColon,
                DateFormat('yyyy/MM/dd').format(policy.submittedAt),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: stagger * i++, curve: Curves.easeOut)
              .slideX(begin: 0.04, end: 0, duration: 500.ms, delay: stagger * (i - 1)),

          const SizedBox(height: 24),

          // ── Documents ──────────────────────────────────────────
          _buildSectionTitle(l10n.attachedDocumentsAndFiles)
              .animate()
              .fadeIn(duration: 400.ms, delay: stagger * i++),
          const SizedBox(height: 12),
          _buildDocumentsGrid(policy, l10n, stagger * i++),

          const SizedBox(height: 32),

          // ── Action section (upload / quote / notes) ────────────
          if (policy.status == PolicyStatus.pending || policy.status == PolicyStatus.insurancePending || policy.status == PolicyStatus.paid) ...[
            if (policy.status == PolicyStatus.paid) ...[
              _buildSectionTitle(l10n.finalPolicyDocument)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: stagger * i++),
              const SizedBox(height: 12),
              _buildUploadCard(l10n, stagger * i++),
              const SizedBox(height: 24),
            ],
            if (policy.status == PolicyStatus.pending || policy.status == PolicyStatus.insurancePending) ...[
              _buildActionForm(l10n, stagger * i++),
            ],
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium upload card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUploadCard(AppLocalizations l10n, Duration delay) {
    final picked = _finalPolicyFile != null;
    return InkWell(
      onTap: _loading ? null : _pickFinalPolicyFile,
      borderRadius: BorderRadius.circular(kRadiusMd),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: picked ? null : kCardGradient,
          color: picked ? kGoldShimmer : null,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(
            color: picked ? kGoldDeep : kDivider,
            width: picked ? 2 : 1,
          ),
          boxShadow: [kCardShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: picked ? kGoldDeep.withValues(alpha: 0.15) : kParchment,
                borderRadius: BorderRadius.circular(kRadiusSm),
              ),
              child: Icon(
                picked ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                color: picked ? kGoldDeep : kInkMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                picked ? _finalPolicyFile!.name : l10n.clickToUploadPolicy,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: picked ? kGoldDeep : kInk,
                ),
              ),
            ),
            if (!picked) const Icon(Icons.arrow_upward_rounded, color: kGoldDeep),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: delay);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium action form (quote + notes)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActionForm(AppLocalizations l10n, Duration delay) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kCardGradient,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: kDivider),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold accent bar
          Container(
            width: 36,
            height: 3,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: kGoldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            l10n.finalQuoteLabel,
            style: GoogleFonts.amiri(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, color: kInk),
            decoration: InputDecoration(
              hintText: l10n.enterFinalQuoteHint,
              hintStyle: GoogleFonts.ibmPlexSansArabic(color: kInkMuted, fontSize: 13),
              filled: true,
              fillColor: kIvory,
              prefixIcon: const Icon(Icons.monetization_on_rounded, color: kGoldDeep),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSm),
                borderSide: const BorderSide(color: kParchment),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSm),
                borderSide: const BorderSide(color: kParchment),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSm),
                borderSide: const BorderSide(color: kGoldDeep, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.reviewAndDecisionNotes,
            style: GoogleFonts.amiri(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kGoldDeep,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            style: GoogleFonts.ibmPlexSansArabic(color: kInk),
            decoration: InputDecoration(
              hintText: l10n.writeAcceptRejectNotes,
              hintStyle: GoogleFonts.ibmPlexSansArabic(color: kInkMuted, fontSize: 13),
              filled: true,
              fillColor: kIvory,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Icon(Icons.edit_note_rounded, color: kGoldDeep),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSm),
                borderSide: const BorderSide(color: kParchment),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSm),
                borderSide: const BorderSide(color: kParchment),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSm),
                borderSide: const BorderSide(color: kGoldDeep, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: delay);
  }

  Widget _buildRequestTypeBadge(PolicyModel policy, AppLocalizations l10n) {
    final requestType = policy.metadata?['request_type'] as String?;
    final isQuote = requestType == 'quote' || policy.status == PolicyStatus.pending;
    final label = isQuote ? l10n.requestTypeQuote : l10n.requestTypeInsurance;
    final color = isQuote ? kGoldDeep : kStatusAccepted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: kGoldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.amiri(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: kGoldDeep,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required List<(String, String)> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: kCardGradient,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kDivider),
        boxShadow: [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: kInk,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11,
                        color: kInkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kDivider.withValues(alpha: 0), kDivider, kDivider.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          ...details.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d.$1,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
                      color: kInkMuted,
                    ),
                  ),
                  Text(
                    d.$2,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid(PolicyModel policy, AppLocalizations l10n, Duration baseDelay) {
    final docs = policy.documentUrls;
    if (docs == null || docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kParchment.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(color: kDivider),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.folder_open_rounded, color: kInkMuted, size: 36),
              const SizedBox(height: 8),
              Text(l10n.noDocsAttached, style: GoogleFonts.ibmPlexSansArabic(color: kInkMuted)),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: baseDelay);
    }
    
    final allDocs = docs.cast<Map<String, dynamic>>().map((d) => {
      'label': (d['label'] ?? l10n.docLabel) as String,
      'url': (d['url'] ?? '') as String,
    }).toList();
    
    if (allDocs.isEmpty) {
      return Text(l10n.noDocsAttached)
          .animate()
          .fadeIn(duration: 400.ms, delay: baseDelay);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: allDocs.length,
      itemBuilder: (context, index) {
        final doc = allDocs[index];
        return InkWell(
          onTap: () => _openDocument(doc['url'] ?? ''),
          borderRadius: BorderRadius.circular(kRadiusMd),
          child: Container(
            decoration: BoxDecoration(
              gradient: kCardGradient,
              borderRadius: BorderRadius.circular(kRadiusMd),
              border: Border.all(color: kDivider),
              boxShadow: [kCardShadow],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kGoldShimmer,
                    borderRadius: BorderRadius.circular(kRadiusSm),
                  ),
                  child: const Icon(Icons.file_copy_rounded, color: kGoldDeep, size: 22),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    doc['label'] ?? l10n.docLabel,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: kInk,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.previewFile,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 9,
                    color: kGoldDeep,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: baseDelay + (80.ms * index), curve: Curves.easeOut)
            .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1), duration: 400.ms, delay: baseDelay + (80.ms * index));
      },
    );
  }

  Widget _buildBottomActions(PolicyModel policy, AppLocalizations l10n) {
    if (policy.status != PolicyStatus.pending && policy.status != PolicyStatus.insurancePending && policy.status != PolicyStatus.paid) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      decoration: BoxDecoration(
        gradient: kCardGradient,
        border: const Border(top: BorderSide(color: kDivider)),
        boxShadow: [
          BoxShadow(
            color: kGoldMid.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (policy.status == PolicyStatus.pending || policy.status == PolicyStatus.insurancePending) ...[
            Expanded(child: _actionBtn(l10n.rejectBtn, kStatusRejected, () => _decide(policy, PolicyStatus.rejected))),
            const SizedBox(width: 10),
            Expanded(child: _actionBtn(l10n.modificationBtn, kStatusMod, () => _decide(policy, PolicyStatus.modificationRequested))),
            const SizedBox(width: 10),
            Expanded(child: _actionBtn(l10n.acceptBtn, kStatusAccepted, () => _decide(policy, PolicyStatus.accepted), isPrimary: true)),
          ] else if (policy.status == PolicyStatus.paid) ...[
            Expanded(child: _actionBtn(l10n.issuePolicyBtn, kStatusAccepted, () => _issueInsurance(policy), isPrimary: true)),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms);
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap, {bool isPrimary = false}) {
    return ElevatedButton(
      onPressed: _loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : kIvory,
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          side: isPrimary ? BorderSide.none : BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSansArabic(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _pickFinalPolicyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _finalPolicyFile = result.files.first);
    }
  }

  Future<void> _issueInsurance(PolicyModel policy) async {
    final l10n = AppLocalizations.of(context)!;
    if (_finalPolicyFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseUploadFinalPolicy)));
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(policyRepositoryProvider);
      final fileData = kIsWeb ? _finalPolicyFile!.bytes! : File(_finalPolicyFile!.path!);
      await repo.uploadFinalPolicyDocument(widget.id, fileData, fileName: _finalPolicyFile!.name);
      await repo.updatePolicyStatus(widget.id, PolicyStatus.issued, notes: _reasonCtrl.text);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decide(PolicyModel policy, PolicyStatus newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    if (newStatus != PolicyStatus.accepted && _reasonCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseWriteNotesFirst),
        ),
      );
      return;
    }

    double? amount;
    if (newStatus == PolicyStatus.accepted) {
      amount = double.tryParse(_amountCtrl.text.trim());
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseEnterValidQuote),
          ),
        );
        return;
      }
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(policyRepositoryProvider)
          .updatePolicyStatus(widget.id, newStatus, notes: _reasonCtrl.text, amount: amount);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
