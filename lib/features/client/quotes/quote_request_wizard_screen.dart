import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/router/app_routes.dart';
import 'package:tameenidz/core/router/route_arguments.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/utils/auth_exception_handler.dart';
import 'package:tameenidz/core/utils/service_documents.dart';
import 'package:tameenidz/features/shared/domain/models/plan_model.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import '../../shared/data/policy_repository.dart';
import '../../shared/data/plan_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ١ - طلب التسعيرة  (Quote Request Wizard)
// Flow: اختر الخدمة → معلومات شخصية + NIN → رفع الوثائق → تأكيد
// ─────────────────────────────────────────────────────────────────────────────

class QuoteRequestWizardScreen extends ConsumerStatefulWidget {
  const QuoteRequestWizardScreen({super.key, this.extra});
  final Object? extra;

  @override
  ConsumerState<QuoteRequestWizardScreen> createState() =>
      _QuoteRequestWizardScreenState();
}

class _QuoteRequestWizardScreenState
    extends ConsumerState<QuoteRequestWizardScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ninCtrl = TextEditingController();

  PlanModel? _plan;
  String? _operatorId;
  int _step = 0;
  bool _submitting = false;

  final Map<String, PlatformFile?> _docFiles = {};
  List<QuoteDocumentSpec> _requiredDocs = [];
  double _uploadProgress = 0;

  // ── Colours ─────────────────────────────────────────────────────────────
  static const _headerGradientStart = Color(0xFF1B5E20);
  static const _headerGradientEnd   = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    final extra = widget.extra;
    if (extra is PlanModel) {
      _plan = extra;
      _operatorId = extra.operatorId;
      _requiredDocs = ServiceDocuments.forPlan(extra);
    } else if (extra is QuoteFormArgs) {
      _plan = extra.plan;
      _operatorId = extra.plan.operatorId;
      _requiredDocs = ServiceDocuments.forPlan(extra.plan);
    } else if (extra is String) {
      _operatorId = extra;
    } else {
      _operatorId = 'algeria_takaful';
    }
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final row = await Supabase.instance.client
          .from('users')
          .select('full_name, phone:phone_number, nin')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null && mounted) {
        _nameCtrl.text = (row['full_name'] as String?) ?? '';
        _phoneCtrl.text = (row['phone'] as String?) ?? '';
        _ninCtrl.text   = (row['nin'] as String?) ?? '';
        setState(() {});
      }
    } catch (_) {}
  }

  void _selectPlan(PlanModel plan) {
    setState(() {
      _plan = plan;
      _requiredDocs = ServiceDocuments.forPlan(plan);
      _docFiles.clear();
      _step = 0;
    });
    _pageCtrl.jumpToPage(0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ninCtrl.dispose();
    super.dispose();
  }

  int get _uploadedCount =>
      _requiredDocs.where((d) => _docFiles[d.key] != null).length;

  bool get _allDocsUploaded =>
      _requiredDocs.isNotEmpty &&
      _requiredDocs.every((d) => _docFiles[d.key] != null);

  Future<void> _pickDoc(QuoteDocumentSpec spec) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.size > 5 * 1024 * 1024) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fileTooLarge),
            backgroundColor: context.colors.error,
          ),
        );
      }
      return;
    }
    setState(() => _docFiles[spec.key] = file);
  }

  Future<Map<String, String>> _uploadDocuments(String userId) async {
    final client = Supabase.instance.client;
    final urls   = <String, String>{};
    for (var i = 0; i < _requiredDocs.length; i++) {
      final spec = _requiredDocs[i];
      final file = _docFiles[spec.key];
      if (file == null) continue;
      final ext  = file.extension ?? 'pdf';
      final path =
          'quotes/$userId/${spec.key}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) throw Exception('Empty file');
        await client.storage.from('documents').uploadBinary(
              path, bytes,
              fileOptions: FileOptions(contentType: _mime(ext)),
            );
      } else if (file.path != null) {
        await client.storage.from('documents').upload(
              path, File(file.path!),
              fileOptions: FileOptions(contentType: _mime(ext)),
            );
      }
      urls[spec.key] = path;
      setState(() => _uploadProgress = (i + 1) / _requiredDocs.length);
    }
    return urls;
  }

  String _mime(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':  return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'webp': return 'image/webp';
      default:     return 'application/pdf';
    }
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_plan == null || !_allDocsUploaded) return;
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not signed in');

      final lang    = Localizations.localeOf(context).languageCode;
      final docUrls = await _uploadDocuments(user.id);
      final docList = _requiredDocs
          .map((s) => {
                'label': s.label(lang),
                'url':   docUrls[s.key] ?? '',
                'key':   s.key,
              })
          .toList();

      final premium =
          double.tryParse(_plan!.premium.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;

      await ref.read(policyRepositoryProvider).createPolicy({
        'client_id':            user.id,
        'plan_id':              _plan!.id,
        'operator_id':          _plan!.operatorId,
        'status':               'pending',
        'amount':               premium,
        'submitted_at':         DateTime.now().toIso8601String(),
        'plan_name':            _plan!.companyName,
        'applicant_id_number':  _ninCtrl.text.trim(),
        'applicant_full_name':  _nameCtrl.text.trim(),
        'document_urls':        docList,
        'metadata': {
          'nin':              _ninCtrl.text.trim(),
          'full_name':        _nameCtrl.text.trim(),
          'phone':            _phoneCtrl.text.trim(),
          'plan_code':        _plan!.planCode,
          'service_category': _plan!.categoryAr,
          'request_type':     'quote', // ← نوع الطلب
          ...docUrls.map((k, v) => MapEntry('${k}_url', v)),
          'document_urls':    docList,
        },
      });

      if (!mounted) return;
      setState(() => _step = 2);
      _pageCtrl.animateToPage(2,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
    } catch (e) {
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthExceptionHandler.handle(e, locale)),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _nextStep(AppLocalizations l10n) {
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty ||
          _phoneCtrl.text.trim().length < 8 ||
          _ninCtrl.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${l10n.fullNameHint} / ${l10n.ninLabel}')),
        );
        return;
      }
      setState(() => _step = 1);
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
      return;
    }
    if (_step == 1 && _allDocsUploaded) _submit(l10n);
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n      = AppLocalizations.of(context)!;
    final colors    = context.colors;
    final lang      = Localizations.localeOf(context).languageCode;
    final plansAsync = ref.watch(plansByOperatorProvider(_operatorId!));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: PageEntryAnimation(
        child: plansAsync.when(
          data: (plans) {
            if (_plan == null) {
              return _buildServicePicker(context, l10n, colors, plans, lang);
            }
            return Column(
              children: [
                _buildHeader(context, colors, l10n, lang),
                _buildProgress(),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStepForm(context, colors, l10n, lang),
                      _buildStepUpload(context, colors, l10n, lang),
                      _buildStepSuccess(context, colors, l10n),
                    ],
                  ),
                ),
                if (_step < 2) _buildBottomCta(context, colors, l10n),
              ],
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.goldAccent)),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
    );
  }

  // ── Service Picker ───────────────────────────────────────────────────────
  Widget _buildServicePicker(
    BuildContext context,
    AppLocalizations l10n,
    AppColorsExtension colors,
    List<PlanModel> plans,
    String lang,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.paddingOf(context).top + 12, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_headerGradientStart, _headerGradientEnd]),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                  Expanded(
                    child: Text(
                      l10n.quoteRequest,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48),
                ]),
                Text(
                  l10n.selectCompanyFirst,
                  style: GoogleFonts.ibmPlexSansArabic(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final plan = plans[i];
              final docs = ServiceDocuments.forPlan(plan);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _selectPlan(plan),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.goldAccent
                                .withValues(alpha: 0.35)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _headerGradientStart
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(plan.resolvedIcon,
                              color: _headerGradientStart, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.getLocalizedName(context),
                                style: GoogleFonts.amiri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              if (plan.companyName.isNotEmpty)
                                Text(plan.companyName,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colors.slate500)),
                              const SizedBox(height: 6),
                              Text(
                                l10n.requiredDocsCount(docs.length),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.goldAccent,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left_rounded,
                            color: _headerGradientStart),
                      ]),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (60 * i).ms).slideX(
                  begin: 0.06, end: 0);
            }, childCount: plans.length),
          ),
        ),
      ],
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
    String lang,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.paddingOf(context).top + 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_headerGradientStart, _headerGradientEnd]),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_step > 0) {
                _pageCtrl.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
                setState(() => _step--);
              } else {
                setState(() {
                  _plan = null;
                  _step = 0;
                  _docFiles.clear();
                });
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
          Expanded(
            child: Column(children: [
              Text(
                l10n.quoteRequest,
                style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                _plan?.getLocalizedName(context) ?? '',
                style: GoogleFonts.ibmPlexSansArabic(
                    color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ── Progress Bar ─────────────────────────────────────────────────────────
  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.goldAccent
                    : AppColors.goldAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Personal Info + doc preview ─────────────────────────────────
  Widget _buildStepForm(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
    String lang,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.person_outline_rounded, l10n.subscriberInfo),
          const SizedBox(height: 16),
          _goldField(l10n.fullName, l10n.fullNameHint, _nameCtrl),
          const SizedBox(height: 14),
          _goldField(l10n.phoneLabel, l10n.phoneHint, _phoneCtrl,
              keyboard: TextInputType.phone),
          const SizedBox(height: 14),
          _goldField(l10n.ninLabel, l10n.ninHint, _ninCtrl),
          const SizedBox(height: 28),
          _sectionTitle(Icons.folder_open_rounded,
              l10n.requiredDocsForService),
          const SizedBox(height: 12),
          ..._requiredDocs.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _docPreviewCard(s, _docFiles[s.key] != null, lang),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Upload Docs ──────────────────────────────────────────────────
  Widget _buildStepUpload(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
    String lang,
  ) {
    final total = _requiredDocs.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(Icons.upload_file_rounded, l10n.uploadDocuments),
              Text('$_uploadedCount / $total',
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldAccent)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.maxFileSizeHint,
            style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 11, color: Colors.grey[600]),
          ),
          if (_submitting) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                minHeight: 6,
                color: AppColors.goldAccent,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ..._requiredDocs.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _uploadCard(s, _docFiles[s.key], lang),
            ),
          ),
          if (!_allDocsUploaded)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        AppColors.goldAccent.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.goldAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.mustUploadAllDocs,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  // ── Step 3: Success ──────────────────────────────────────────────────────
  Widget _buildStepSuccess(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _headerGradientStart.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: _headerGradientStart, size: 56),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.quoteRequestSuccess,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _headerGradientStart.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                  color: _headerGradientStart.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Text(
            l10n.quoteSuccessDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF2D1F0E)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.myPolicies),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D1F0E),
              foregroundColor: AppColors.goldAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.policies),
          ),
        ),
      ]),
    );
  }

  // ── Bottom CTA ───────────────────────────────────────────────────────────
  Widget _buildBottomCta(
    BuildContext context,
    AppColorsExtension colors,
    AppLocalizations l10n,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    final label = _step == 0
        ? l10n.nextUploadDocs
        : (_submitting ? l10n.uploading : l10n.sendQuoteRequest);
    final enabled = _step == 0
        ? _nameCtrl.text.trim().isNotEmpty &&
            _ninCtrl.text.trim().length >= 10
        : (_allDocsUploaded && !_submitting);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? () => _nextStep(l10n) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                enabled ? AppColors.goldAccent : colors.slate200,
            foregroundColor: enabled
                ? const Color(0xFF2D1F0E)
                : colors.slate500,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────────────
  Widget _sectionTitle(IconData icon, String title) => Row(children: [
        Icon(icon, color: AppColors.goldAccent, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1F0E))),
      ]);

  Widget _goldField(String label, String hint, TextEditingController ctrl,
      {TextInputType? keyboard}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ]);

  Widget _docPreviewCard(QuoteDocumentSpec spec, bool done, String lang) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done
                ? AppColors.primaryGreen
                : AppColors.goldAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(children: [
          Icon(spec.icon, color: AppColors.goldAccent),
          const SizedBox(width: 12),
          Expanded(
              child: Text(spec.label(lang),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            color: done
                ? AppColors.primaryGreen
                : AppColors.goldAccent,
          ),
        ]),
      );

  Widget _uploadCard(
      QuoteDocumentSpec spec, PlatformFile? file, String lang) {
    final l10n = AppLocalizations.of(context)!;
    final hasFile = file != null;
    return InkWell(
      onTap: _submitting ? null : () => _pickDoc(spec),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasFile
                ? AppColors.primaryGreen
                : AppColors.goldAccent.withValues(alpha: 0.45),
            width: hasFile ? 2 : 1.5,
          ),
        ),
        child: Row(children: [
          Icon(
            hasFile ? Icons.check_rounded : Icons.add_rounded,
            color: hasFile
                ? AppColors.primaryGreen
                : AppColors.goldAccent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spec.label(lang),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  Text(
                    hasFile
                        ? file.name
                        : l10n.pdfImageLimit,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey[600]),
                  ),
                ]),
          ),
          Icon(spec.icon, color: AppColors.goldAccent),
        ]),
      ),
    );
  }
}
