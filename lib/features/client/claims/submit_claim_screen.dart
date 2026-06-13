import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:tameenidz/core/services/notification_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Digital Claims Module  (وحدة طلب التعويض الرقمي)
// Features per the spec doc (Image 5):
//   1. Upload RC card, grey card, damage photos (4 angles), friendly inspection
//   2. In-app camera with image compression
//   3. Progress tracker: received → expert assigned → repair authorised
//   4. Push notifications per stage change
//   5. Partners dashboard linking (repair shop QR / phone)
// ─────────────────────────────────────────────────────────────────────────────

class SubmitClaimScreen extends ConsumerStatefulWidget {
  const SubmitClaimScreen({super.key});

  @override
  ConsumerState<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends ConsumerState<SubmitClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _submitting = false;

  // Step 1 - Doc uploads
  File? _rcCard;
  File? _greyCard;
  File? _friendlyInspection;
  final List<File> _damagePhotos = [];

  // Step 2 - Incident info
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _incidentDate = DateTime.now();
  String _selectedPolicy = '';
  List<Map<String, dynamic>> _userPolicies = [];

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  @override
  void dispose() {
    _descController.dispose();
    _locationController.dispose();
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
          _userPolicies = List<Map<String, dynamic>>.from(data);
          if (_userPolicies.isNotEmpty) _selectedPolicy = _userPolicies.first['id'];
        });
      }
    } catch (_) {}
  }

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1920,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> _addDamagePhoto() async {
    if (_damagePhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.max4DamagePhotos)),
      );
      return;
    }
    final file = await _pickImage(ImageSource.camera);
    if (file != null) setState(() => _damagePhotos.add(file));
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last;
      final fullPath = '$path.$ext';
      await Supabase.instance.client.storage
          .from('documents')
          .uploadBinary(fullPath, bytes,
              fileOptions: const FileOptions(upsert: true));
      return await Supabase.instance.client.storage
          .from('documents')
          .createSignedUrl(fullPath, 60 * 60 * 24 * 365);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final uid = user.id;
      final claimId = DateTime.now().millisecondsSinceEpoch.toString();
      final basePath = 'users/$uid/claims/$claimId';

      // Upload all documents
      final Map<String, String?> docUrls = {};
      if (_rcCard != null) {
        docUrls['rc_card_url'] = await _uploadFile(_rcCard!, '$basePath/rc_card');
      }
      if (_greyCard != null) {
        docUrls['grey_card_url'] = await _uploadFile(_greyCard!, '$basePath/grey_card');
      }
      if (_friendlyInspection != null) {
        docUrls['friendly_inspection_url'] =
            await _uploadFile(_friendlyInspection!, '$basePath/friendly_inspection');
      }
      for (int i = 0; i < _damagePhotos.length; i++) {
        final url = await _uploadFile(_damagePhotos[i], '$basePath/damage_$i');
        if (url != null) docUrls['damage_photo_${i + 1}_url'] = url;
      }

      // Resolve operator_id from the linked policy
      String? operatorId;
      String? clientName;
      String? planName;
      if (_selectedPolicy.isNotEmpty && _userPolicies.isNotEmpty) {
        final selectedPol = _userPolicies.firstWhere(
          (p) => p['id'] == _selectedPolicy,
          orElse: () => <String, dynamic>{},
        );
        operatorId = selectedPol['operator_id'] as String?;
        planName = selectedPol['plan_name'] as String? ?? AppLocalizations.of(context)!.unspecified;
      }
      clientName = user.userMetadata?['full_name'] as String? ?? AppLocalizations.of(context)!.client;

      // Build description with location
      final descParts = <String>[];
      descParts.add(_descController.text.trim());
      if (_locationController.text.trim().isNotEmpty) {
        descParts.add('📍 ${_locationController.text.trim()}');
      }
      descParts.add('📅 ${_incidentDate.toIso8601String().split('T').first}');

      // Insert claim record into client_claims (the table operators stream from)
      await Supabase.instance.client.from('client_claims').insert({
        'client_id': uid,
        'policy_id': _selectedPolicy.isNotEmpty ? _selectedPolicy : null,
        'claim_type': 'accident',
        'description': descParts.join('\n'),
        'status': 'pending',
        'operator_id': operatorId,
        'client_name': clientName,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {
          'location': _locationController.text.trim(),
          'incident_date': _incidentDate.toIso8601String(),
          'stage': 1,
          'document_urls': docUrls,
          'plan_name': planName,
        },
      });

      // ── Notify operator about new claim ──
      if (operatorId != null) {
        await NotificationHelper.notifyOperatorNewRequest(
          operatorId: operatorId,
          clientName: clientName,
          planName: planName ?? 'N/A',
          requestType: 'claim',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.claimReceivedSuccessfully),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithParam(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.beigeBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.digitalClaimRequest,
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Tracker
            _buildProgressTracker(colors),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  child: _currentStep == 0
                      ? _buildStep1Documents(colors)
                      : _buildStep2Info(colors),
                ),
              ),
            ),

            // Bottom navigation
            _buildBottomBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker(AppColorsExtension colors) {
    final stages = [AppLocalizations.of(context)!.requiredDocuments, AppLocalizations.of(context)!.accidentInformation, 'Review'];
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: stages.asMap().entries.map((e) {
          final idx = e.key;
          final done = idx < _currentStep;
          final active = idx == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (idx > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done ? Colors.white : Colors.white24,
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done || active ? Colors.white : Colors.white24,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, size: 14, color: AppColors.primaryGreen)
                            : Text('${idx + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: active ? AppColors.primaryGreen : Colors.white54,
                                )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.value,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 10,
                        color: active || done ? Colors.white : Colors.white54,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Step 1: Document Uploads ─────────────────────────────────────────────
  Widget _buildStep1Documents(AppColorsExtension colors) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(AppLocalizations.of(context)!.requiredDocuments, Icons.upload_file_rounded, colors),
        const SizedBox(height: 16),

        _uploadTile(
          label: AppLocalizations.of(context)!.drivingLicenseBothSides,
          file: _rcCard,
          required: true,
          onPick: () async {
            final f = await _pickImage(ImageSource.gallery);
            if (f != null) setState(() => _rcCard = f);
          },
          onCamera: () async {
            final f = await _pickImage(ImageSource.camera);
            if (f != null) setState(() => _rcCard = f);
          },
          colors: colors,
        ),
        const SizedBox(height: 12),

        _uploadTile(
          label: AppLocalizations.of(context)!.vehicleRegistrationDocument,
          file: _greyCard,
          required: true,
          onPick: () async {
            final f = await _pickImage(ImageSource.gallery);
            if (f != null) setState(() => _greyCard = f);
          },
          onCamera: () async {
            final f = await _pickImage(ImageSource.camera);
            if (f != null) setState(() => _greyCard = f);
          },
          colors: colors,
        ),
        const SizedBox(height: 12),

        _uploadTile(
          label: AppLocalizations.of(context)!.friendlyConstatOptional,
          file: _friendlyInspection,
          required: false,
          onPick: () async {
            final f = await _pickImage(ImageSource.gallery);
            if (f != null) setState(() => _friendlyInspection = f);
          },
          onCamera: () async {
            final f = await _pickImage(ImageSource.camera);
            if (f != null) setState(() => _friendlyInspection = f);
          },
          colors: colors,
        ),

        const SizedBox(height: 20),
        _sectionHeader(AppLocalizations.of(context)!.damagePhotosCount(_damagePhotos.length), Icons.camera_alt_rounded, colors),
        const SizedBox(height: 12),

        // 4 angle photo grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            ..._damagePhotos.map((f) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(f, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  top: 4, left: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _damagePhotos.remove(f)),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),
            if (_damagePhotos.length < 4)
              GestureDetector(
                onTap: _addDamagePhoto,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.beigeCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_rounded, color: AppColors.primaryGreen, size: 28),
                      const SizedBox(height: 6),
                      Text(AppLocalizations.of(context)!.addPhoto, style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: AppColors.primaryGreen)),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.carPhotoInstructions,
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Incident Info ────────────────────────────────────────────────
  Widget _buildStep2Info(AppColorsExtension colors) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(AppLocalizations.of(context)!.accidentInformation, Icons.assignment_rounded, colors),
        const SizedBox(height: 16),

        if (_userPolicies.isNotEmpty) ...[
          Text(AppLocalizations.of(context)!.relatedPolicy, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primaryText)),
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
                value: _selectedPolicy,
                items: _userPolicies.map((p) => DropdownMenuItem(
                  value: p['id'] as String,
                  child: Text(p['plan_name'] ?? p['id'], style: GoogleFonts.ibmPlexSansArabic()),
                )).toList(),
                onChanged: (v) => setState(() => _selectedPolicy = v ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text(AppLocalizations.of(context)!.accidentDate, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primaryText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _incidentDate,
              firstDate: DateTime.now().subtract(const Duration(days: 90)),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _incidentDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colors.beigeCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.warmDivider),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: 10),
                Text(
                  '${_incidentDate.year}/${_incidentDate.month}/${_incidentDate.day}',
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: colors.primaryText),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(AppLocalizations.of(context)!.accidentLocation, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primaryText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.pleaseEnterAccidentLocation : null,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.cityNeighborhoodStreet,
            filled: true,
            fillColor: colors.beigeCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.warmDivider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.warmDivider)),
            prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primaryGreen, size: 18),
          ),
          style: GoogleFonts.ibmPlexSansArabic(),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),

        Text(AppLocalizations.of(context)!.accidentDescription, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primaryText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descController,
          minLines: 4,
          maxLines: 6,
          validator: (v) => (v == null || v.trim().length < 20) ? AppLocalizations.of(context)!.pleaseEnterDetailedDescription : null,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.explainWhatHappened,
            filled: true,
            fillColor: colors.beigeCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.warmDivider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.warmDivider)),
          ),
          style: GoogleFonts.ibmPlexSansArabic(),
          textDirection: TextDirection.rtl,
        ),

        const SizedBox(height: 20),
        // Stage explanation
        _buildStagesInfo(colors),
      ],
    );
  }

  Widget _buildStagesInfo(AppColorsExtension colors) {
    final stages = [
      (Icons.inbox_rounded, AppLocalizations.of(context)!.stage1, AppLocalizations.of(context)!.fileReceivedAfterUpload),
      (Icons.person_search_rounded, AppLocalizations.of(context)!.stage2, AppLocalizations.of(context)!.expertAssignedDetails),
      (Icons.car_repair_rounded, AppLocalizations.of(context)!.stage3, AppLocalizations.of(context)!.directRepairOrder),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.warmDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.claimTrackingStages, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primaryText)),
          const SizedBox(height: 12),
          ...stages.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(s.$1, size: 16, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$2, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 12, color: colors.primaryText)),
                    Text(s.$3, style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: colors.slate500)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        border: Border(top: BorderSide(color: colors.warmDivider)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.previous, style: GoogleFonts.ibmPlexSansArabic(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitting ? null : () {
                if (_currentStep == 0) {
                  if (_rcCard == null || _greyCard == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.pleaseUploadRequiredDocs)),
                    );
                    return;
                  }
                  setState(() => _currentStep = 1);
                } else {
                  _submitClaim();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _currentStep == 0 ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.submitRequest,
                      style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadTile({
    required String label,
    required File? file,
    required bool required,
    required VoidCallback onPick,
    required VoidCallback onCamera,
    required AppColorsExtension colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.beigeCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file != null ? AppColors.primaryGreen.withValues(alpha: 0.5) : colors.warmDivider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            file != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
            color: file != null ? AppColors.primaryGreen : colors.slate500,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(label, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600, fontSize: 13, color: colors.primaryText)),
                  if (required) Text(' *', style: const TextStyle(color: Colors.red, fontSize: 13)),
                ]),
                if (file != null)
                  Text(AppLocalizations.of(context)!.uploadedSuccessfully, style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: AppColors.primaryGreen)),
              ],
            ),
          ),
          IconButton(onPressed: onCamera, icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen, size: 20)),
          IconButton(onPressed: onPick, icon: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGreen, size: 20)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, AppColorsExtension colors) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 17, color: colors.primaryText)),
      ],
    );
  }
}
