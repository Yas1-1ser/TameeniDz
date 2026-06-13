import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/router/app_routes.dart';

import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/services/notification_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ٣ - طلب التعويض  (Digital Claim Wizard)
// Flow: رفع وثائق الحادث → تفاصيل الحادث → تأكيد
// المميزات:
//   • رخصة السياقة + البطاقة الرمادية + المعاينة الودية (اختياري)
//   • صور السيارة من 4 زوايا (كاميرا داخل التطبيق)
//   • تتبع المراحل: استلام → تعيين خبير → أمر الإصلاح
//   • اللون: أحمر-برتقالي داكن ليميّزه عن باقي الطلبات
// ─────────────────────────────────────────────────────────────────────────────

class ClaimRequestWizardScreen extends ConsumerStatefulWidget {
  const ClaimRequestWizardScreen({super.key});

  @override
  ConsumerState<ClaimRequestWizardScreen> createState() =>
      _ClaimRequestWizardScreenState();
}

class _ClaimRequestWizardScreenState
    extends ConsumerState<ClaimRequestWizardScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _descCtrl        = TextEditingController();
  final _locationCtrl    = TextEditingController();
  final _imagePicker     = ImagePicker();

  int      _step         = 0;   // 0=وثائق 1=تفاصيل 2=نجاح
  bool     _submitting   = false;
  DateTime _incidentDate = DateTime.now();

  // ── وثائق إلزامية ────────────────────────────────────────────────────────
  File? _drivingLicense;
  File? _greyCard;
  File? _friendlyInspection; // اختياري

  // ── صور السيارة الأربع (أمام / خلف / يمين / يسار) ──────────────────────
  final List<_CarPhoto> _carPhotos = [
    _CarPhoto(key: 'front', icon: Icons.arrow_upward_rounded),
    _CarPhoto(key: 'back',  icon: Icons.arrow_downward_rounded),
    _CarPhoto(key: 'right', icon: Icons.arrow_forward_rounded),
    _CarPhoto(key: 'left',  icon: Icons.arrow_back_rounded),
  ];

  // ── بوليصة مرتبطة ────────────────────────────────────────────────────────
  String _selectedPolicyId = '';
  List<Map<String, dynamic>> _policies = [];

  // ── ألوان ─────────────────────────────────────────────────────────────────
  static const _headerColor  = Color(0xFFB71C1C); // أحمر غامق
  static const _accentOrange = Color(0xFFE64A19); // برتقالي

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPolicies() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('policies')
          .select('id, plan_name, operator_id, status')
          .eq('client_id', user.id)
          .inFilter('status', ['paid', 'accepted']);
      if (mounted) {
        setState(() {
          _policies = List<Map<String, dynamic>>.from(data);
          if (_policies.isNotEmpty) {
            _selectedPolicyId = _policies.first['id'] as String;
          }
        });
      }
    } catch (_) {}
  }

  // ── Image Helpers ────────────────────────────────────────────────────────
  Future<File?> _pick(ImageSource src) async {
    final picked = await _imagePicker.pickImage(
      source: src,
      imageQuality: 75,
      maxWidth: 1920,
    );
    return picked == null ? null : File(picked.path);
  }

  Future<void> _pickAngle(int index) async {
    final src = await _showPickerSheet();
    if (src == null) return;
    final f = await _pick(src);
    if (f != null) {
      setState(() => _carPhotos[index].file = f);
    }
  }

  Future<ImageSource?> _showPickerSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded,
                color: _accentOrange),
            title: Text(AppLocalizations.of(context)!.takePhoto,
                style: GoogleFonts.ibmPlexSansArabic()),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: _accentOrange),
            title: Text(AppLocalizations.of(context)!.fromGallery,
                style: GoogleFonts.ibmPlexSansArabic()),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _pickDocFile(
      void Function(File) onPicked, ImageSource src) async {
    final f = await _pick(src);
    if (f != null) setState(() => onPicked(f));
  }

  // ── Upload & Submit ──────────────────────────────────────────────────────
  Future<String?> _uploadFile(File file, String path) async {
    try {
      final bytes    = await file.readAsBytes();
      final ext      = file.path.split('.').last;
      final fullPath = '$path.$ext';
      await Supabase.instance.client.storage
          .from('documents')
          .uploadBinary(fullPath, bytes,
              fileOptions: const FileOptions(upsert: true));
      return await Supabase.instance.client.storage
          .from('documents')
          .createSignedUrl(fullPath, 60 * 60 * 24 * 365);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final uid     = user.id;
      final claimId = DateTime.now().millisecondsSinceEpoch.toString();
      final base    = 'users/$uid/claims/$claimId';

      final docs = <String, String?>{};
      if (_drivingLicense != null) {
        docs['driving_license_url'] =
            await _uploadFile(_drivingLicense!, '$base/driving_license');
      }
      if (_greyCard != null) {
        docs['grey_card_url'] =
            await _uploadFile(_greyCard!, '$base/grey_card');
      }
      if (_friendlyInspection != null) {
        docs['friendly_inspection_url'] =
            await _uploadFile(_friendlyInspection!, '$base/friendly_inspection');
      }
      for (var i = 0; i < _carPhotos.length; i++) {
        final f = _carPhotos[i].file;
        if (f != null) {
          final url = await _uploadFile(f, '$base/car_${_carPhotos[i].key}');
          if (url != null) docs['car_photo_${i + 1}_url'] = url;
        }
      }

      // Resolve operator_id from the linked policy
      String? operatorId;
      String? clientName;
      String? planName;
      if (_selectedPolicyId.isNotEmpty && _policies.isNotEmpty) {
        final selectedPol = _policies.firstWhere(
          (p) => p['id'] == _selectedPolicyId,
          orElse: () => <String, dynamic>{},
        );
        operatorId = selectedPol['operator_id'] as String?;
        planName = selectedPol['plan_name'] as String? ?? AppLocalizations.of(context)!.unspecified;
      }
      clientName = user.userMetadata?['full_name'] as String? ?? AppLocalizations.of(context)!.client;

      // Build description with location
      final descParts = <String>[];
      descParts.add(_descCtrl.text.trim());
      if (_locationCtrl.text.trim().isNotEmpty) {
        descParts.add('📍 ${_locationCtrl.text.trim()}');
      }
      descParts.add('📅 ${_incidentDate.toIso8601String().split('T').first}');

      // Insert claim record into client_claims (the table operators stream from)
      await Supabase.instance.client.from('client_claims').insert({
        'client_id':    uid,
        'policy_id':
            _selectedPolicyId.isNotEmpty ? _selectedPolicyId : null,
        'claim_type':   'accident',
        'description':  descParts.join('\n'),
        'status':       'pending',
        'operator_id':  operatorId,
        'client_name':  clientName,
        'created_at':   DateTime.now().toIso8601String(),
        'metadata': {
          'location': _locationCtrl.text.trim(),
          'incident_date': _incidentDate.toIso8601String(),
          'stage': 1,
          'document_urls': docs,
          'plan_name': planName,
        },
      });

      // ── Notify operator about new claim request ──
      if (operatorId != null) {
        await NotificationHelper.notifyOperatorNewRequest(
          operatorId: operatorId,
          clientName: clientName,
          planName: planName ?? 'N/A',
          requestType: 'claim',
        );
      }

      if (mounted) {
        setState(() {
          _submitting = false;
          _step       = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.claimErrorOccurred}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _step0Valid =>
      _drivingLicense != null && _greyCard != null;

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: PageEntryAnimation(
        child: Form(
          key: _formKey,
          child: Column(children: [
            _buildHeader(context),
            _buildStepIndicator(),
            Expanded(
              child: AnimatedSwitcher(
                duration: 300.ms,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _step == 0
                    ? _buildStep0Docs(colors, l10n)
                    : _step == 1
                        ? _buildStep1Info(colors, l10n)
                        : _buildStep2Success(colors, l10n),
              ),
            ),
            if (_step < 2) _buildBottomBar(colors, l10n),
          ]),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.paddingOf(context).top + 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_headerColor, _accentOrange.withValues(alpha: 0.9)]),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(children: [
        IconButton(
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
        Expanded(
          child: Column(children: [
            Text(
              l10n.claimRequest,
              style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.claimSubtitle,
              style: GoogleFonts.ibmPlexSansArabic(
                  color: Colors.white70, fontSize: 12),
            ),
          ]),
        ),
        const SizedBox(width: 48),
      ]),
    );
  }

  // ── Step Indicator ───────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final l10n = AppLocalizations.of(context)!;
    final steps = [l10n.claimStep1, l10n.claimStep2, l10n.claimStep3];
    return Container(
      color: _headerColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final idx    = e.key;
          final done   = idx < _step;
          final active = idx == _step;
          return Expanded(
            child: Row(children: [
              if (idx > 0)
                Expanded(
                  child: Container(
                      height: 2,
                      color: done ? Colors.white : Colors.white24),
                ),
              Column(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done || active
                        ? Colors.white
                        : Colors.white24,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check,
                            size: 14, color: _headerColor)
                        : Text('${idx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? _headerColor
                                  : Colors.white54,
                            )),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.value,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 10,
                    color: active || done
                        ? Colors.white
                        : Colors.white54,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Step 0: Documents + Car Photos ───────────────────────────────────────
  Widget _buildStep0Docs(AppColorsExtension colors, AppLocalizations l10n) {
    // ignore: unused_local_variable
    final lang = Localizations.localeOf(context).languageCode;
    return SingleChildScrollView(
      key: const ValueKey('step0'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(l10n.officialRequiredDocs,
              Icons.upload_file_rounded, colors),
          const SizedBox(height: 16),

          // رخصة السياقة
          _docUploadTile(
            label: l10n.drivingLicenseBothSides,
            required: true,
            file: _drivingLicense,
            icon: Icons.assignment_rounded,
            onGallery: () => _pickDocFile(
                (f) => _drivingLicense = f, ImageSource.gallery),
            onCamera: () => _pickDocFile(
                (f) => _drivingLicense = f, ImageSource.camera),
            colors: colors,
            l10n: l10n,
          ),
          const SizedBox(height: 12),

          // البطاقة الرمادية
          _docUploadTile(
            label: l10n.carteGriseLabel,
            required: true,
            file: _greyCard,
            icon: Icons.directions_car_rounded,
            onGallery: () => _pickDocFile(
                (f) => _greyCard = f, ImageSource.gallery),
            onCamera: () => _pickDocFile(
                (f) => _greyCard = f, ImageSource.camera),
            colors: colors,
            l10n: l10n,
          ),
          const SizedBox(height: 12),

          // المعاينة الودية
          _docUploadTile(
            label: l10n.friendlyReportOptional,
            required: false,
            file: _friendlyInspection,
            icon: Icons.handshake_rounded,
            onGallery: () => _pickDocFile(
                (f) => _friendlyInspection = f, ImageSource.gallery),
            onCamera: () => _pickDocFile(
                (f) => _friendlyInspection = f, ImageSource.camera),
            colors: colors,
            l10n: l10n,
          ),

          const SizedBox(height: 24),
          _sectionHeader(
            l10n.carPhotosCount(_carPhotos.where((p) => p.file != null).length),
            Icons.camera_alt_rounded,
            colors,
          ),
          const SizedBox(height: 12),

          // Tip
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentOrange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _accentOrange.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline,
                  color: _accentOrange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.carPhotosHint,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12, color: _accentOrange),
                ),
              ),
            ]),
          ),

          // 2×2 car photo grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: _carPhotos.asMap().entries.map((e) {
              final i     = e.key;
              final photo = e.value;
              final file  = photo.file;

              return GestureDetector(
                onTap: () => _pickAngle(i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: file != null
                          ? _accentOrange
                          : colors.warmDivider,
                      width: file != null ? 2 : 1.2,
                    ),
                    color: file != null
                        ? null
                        : colors.beigeCard,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: file != null
                      ? Stack(fit: StackFit.expand, children: [
                          Image.file(file,
                              fit: BoxFit.cover),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _carPhotos[i].file = null),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4),
                              color: Colors.black45,
                              child: Text(
                                photo.getLocalizedLabel(l10n),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(photo.icon,
                                color: _accentOrange, size: 26),
                            const SizedBox(height: 6),
                            Text(
                              photo.getLocalizedLabel(l10n),
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 12,
                                color: _accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.tapToAdd,
                              style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 10,
                                  color: Colors.grey[500]),
                            ),
                          ],
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  // ── Step 1: Incident Info ────────────────────────────────────────────────
  Widget _buildStep1Info(AppColorsExtension colors, AppLocalizations l10n) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(l10n.accidentInfo, Icons.assignment_rounded, colors),
          const SizedBox(height: 16),

          // ── بوليصة مرتبطة ──
          if (_policies.isNotEmpty) ...[
            _fieldLabel(l10n.associatedPolicy, colors),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.beigeCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.warmDivider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedPolicyId,
                  items: _policies
                      .map((p) => DropdownMenuItem(
                            value: p['id'] as String,
                            child: Text(
                              p['plan_name'] ?? p['id'],
                              style: GoogleFonts.ibmPlexSansArabic(),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedPolicyId = v ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── تاريخ الحادث ──
          _fieldLabel(l10n.accidentDate, colors),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _incidentDate,
                firstDate: DateTime.now()
                    .subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _incidentDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: colors.beigeCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.warmDivider),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded,
                    color: _headerColor, size: 18),
                const SizedBox(width: 10),
                Text(
                  '${_incidentDate.year}/${_incidentDate.month.toString().padLeft(2, '0')}/${_incidentDate.day.toString().padLeft(2, '0')}',
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 14, color: colors.primaryText),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── مكان الحادث ──
          _fieldLabel(l10n.accidentLocation, colors),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationCtrl,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.pleaseEnterLocation
                : null,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: l10n.locationHint,
              filled: true,
              fillColor: colors.beigeCard,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.warmDivider)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.warmDivider)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: _headerColor, width: 2)),
              prefixIcon: const Icon(Icons.location_on_rounded,
                  color: _headerColor, size: 18),
            ),
            style: GoogleFonts.ibmPlexSansArabic(),
          ),
          const SizedBox(height: 16),

          // ── وصف الحادث ──
          _fieldLabel(l10n.accidentDescription, colors),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descCtrl,
            minLines: 4,
            maxLines: 6,
            validator: (v) =>
                (v == null || v.trim().length < 20)
                    ? l10n.pleaseEnterDescription
                    : null,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: l10n.descriptionHint,
              filled: true,
              fillColor: colors.beigeCard,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.warmDivider)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.warmDivider)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: _headerColor, width: 2)),
            ),
            style: GoogleFonts.ibmPlexSansArabic(),
          ),

          const SizedBox(height: 24),
          _buildStagesCard(colors),
        ],
      ),
    ).animate().fadeIn();
  }

  // ── مراحل متابعة الملف ───────────────────────────────────────────────────
  Widget _buildStagesCard(AppColorsExtension colors) {
    final l10n = AppLocalizations.of(context)!;
    final stages = [
      (Icons.inbox_rounded, l10n.stage1, l10n.fileReceived),
      (Icons.person_search_rounded, l10n.stage2, l10n.expertAssignment),
      (Icons.car_repair_rounded, l10n.stage3, l10n.directRepairOrder),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.warmDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trackingStages,
            style: GoogleFonts.ibmPlexSansArabic(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: colors.primaryText),
          ),
          const SizedBox(height: 12),
          ...stages.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _headerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s.$1, size: 16, color: _headerColor),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(s.$2,
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colors.primaryText)),
                  Text(s.$3,
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11, color: colors.slate500)),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Success ──────────────────────────────────────────────────────
  Widget _buildStep2Success(AppColorsExtension colors, AppLocalizations l10n) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: _headerColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: _headerColor, size: 60),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.fileReceived,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.requestId}: ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _headerColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: _headerColor.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Text(
            l10n.claimSuccessDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14, height: 1.7),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.myPolicies),
            style: ElevatedButton.styleFrom(
              backgroundColor: _headerColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.trackMyRequests),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/client'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: _headerColor.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.backToHome,
                style: TextStyle(color: _headerColor)),
          ),
        ),
      ]),
    ).animate().fadeIn();
  }

  // ── Bottom Bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar(AppColorsExtension colors, AppLocalizations l10n) {
    final label = _step == 0
        ? l10n.nextIncidentDetails
        : (_submitting ? l10n.sending : l10n.sendClaimRequest);
    final enabled = _step == 0 ? _step0Valid : !_submitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        border: Border(top: BorderSide(color: colors.warmDivider)),
      ),
      child: Row(children: [
        if (_step > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: _headerColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.previous,
                  style: GoogleFonts.ibmPlexSansArabic(
                      color: _headerColor,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: enabled
                ? () {
                    if (_step == 0) {
                      setState(() => _step = 1);
                    } else {
                      _submit();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? _headerColor : colors.slate200,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(label,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  // ── Shared Helpers ───────────────────────────────────────────────────────
  Widget _sectionHeader(
      String title, IconData icon, AppColorsExtension colors) =>
      Row(children: [
        Icon(icon, color: _accentOrange, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: colors.primaryText)),
        ),
      ]);

  Widget _fieldLabel(String label, AppColorsExtension colors) =>
      Text(label,
          style: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colors.primaryText));

  Widget _docUploadTile({
    required String label,
    required bool required,
    required File? file,
    required IconData icon,
    required VoidCallback onGallery,
    required VoidCallback onCamera,
    required AppColorsExtension colors,
    required AppLocalizations l10n,
  }) {
    final uploaded = file != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: uploaded
              ? _accentOrange.withValues(alpha: 0.7)
              : colors.warmDivider,
          width: uploaded ? 2 : 1,
        ),
      ),
      child: Row(children: [
        Icon(
          uploaded ? Icons.check_circle_rounded : icon,
          color: uploaded ? _accentOrange : colors.slate500,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colors.primaryText)),
              ),
              if (required)
                const Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
            ]),
            if (uploaded)
              Text(l10n.uploadedCheck,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11, color: _accentOrange)),
          ]),
        ),
        IconButton(
            onPressed: onCamera,
            icon: Icon(Icons.camera_alt_rounded,
                color: _accentOrange, size: 20)),
        IconButton(
            onPressed: onGallery,
            icon: Icon(Icons.photo_library_rounded,
                color: _accentOrange, size: 20)),
      ]),
    );
  }
}

// ── Data class for a single car angle photo ──────────────────────────────────
class _CarPhoto {
  _CarPhoto({required this.key, required this.icon, this.file});
  final String  key;
  final IconData icon;
  File?         file;

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (key) {
      case 'front':
        return l10n.front;
      case 'back':
        return l10n.backPhoto;
      case 'right':
        return l10n.rightSide;
      case 'left':
        return l10n.leftSide;
      default:
        return '';
    }
  }
}
