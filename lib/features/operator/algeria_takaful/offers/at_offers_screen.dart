import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tameenidz/core/theme/premium_tokens.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/portal_layout.dart';
import 'package:tameenidz/features/shared/domain/models/plan_model.dart';
import 'package:tameenidz/features/shared/providers/offer_providers.dart';
import 'package:tameenidz/features/operator/offers/widgets/operator_offer_card.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class AtOffersScreen extends ConsumerStatefulWidget {
  const AtOffersScreen({super.key});

  @override
  ConsumerState<AtOffersScreen> createState() => _AtOffersScreenState();
}

class _AtOffersScreenState extends ConsumerState<AtOffersScreen> {
  void _showOfferForm({PlanModel? offer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AtOfferFormBottomSheet(
          companyEn: 'Algerie Takaful',
          existingOffer: offer,
        ),
      ),
    );
  }

  Future<void> _toggleBestValue(PlanModel offer, bool value) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(offerRepositoryProvider).updateOffer(offer.id, {
        'is_best_value': value,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? l10n.bestValueSet : l10n.bestValueUnset,
            style: GoogleFonts.ibmPlexSansArabic(),
          ),
          backgroundColor: kStatusAccepted,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDuringUpdate(e.toString()), style: GoogleFonts.ibmPlexSansArabic()),
          backgroundColor: kStatusRejected,
        ),
      );
    }
  }

  Future<void> _confirmDelete(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: kIvory,
          title: Text(
            l10n.confirmDeletion,
            style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: kGoldDeep),
          ),
          content: Text(
            l10n.deleteOfferConfirm,
            style: GoogleFonts.ibmPlexSansArabic(color: kInk),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
            side: const BorderSide(color: kParchment),
          ),
          actions: [
            SpringButton(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.ibmPlexSansArabic(color: kInkMuted, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SpringButton(
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: kStatusRejected),
                child: Text(
                  l10n.deleteOffer,
                  style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(offerRepositoryProvider).deleteOffer(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.offerDeleted, style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: kStatusAccepted,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDuringDeletion(e.toString()), style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: kStatusRejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(offersStreamProvider('Algerie Takaful'));
    final l10n = AppLocalizations.of(context)!;

    final menuItems = [
      (Icons.dashboard_rounded, l10n.dashboard, '/at/dashboard'),
      (Icons.account_balance_wallet_rounded, l10n.surplus, '/at/surplus'),
      (Icons.archive_outlined, l10n.policies, '/at/policies'),
      (Icons.receipt_long_outlined, l10n.claims, '/at/claims'),
      (Icons.local_offer_outlined, l10n.manageOffers, '/at/offers'),
      (Icons.settings_outlined, l10n.settings, '/at/settings'),
    ];

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: PortalLayout(
        selectedIndex: 4,
        portalTitle: l10n.atPortalTitle,
        portalSubtitle: l10n.aiOffersSubtitle,
        accentColor: kGoldDeep,
        appBarColor: kIvory,
        appBarTextColor: kGoldDeep,
        selectedItemColor: kGoldDeep,
        selectedItemBgColor: kCream,
        unselectedItemColor: kInkMuted,
        sidebarBgColor: kIvory,
        menuItems: menuItems,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showOfferForm(),
          backgroundColor: kGoldDeep,
          child: const Icon(Icons.add, color: kIvory),
        ),
        body: PageEntryAnimation(
          child: offersAsync.when(
            data: (offers) {
              if (offers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 64, color: kParchment),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noOffersYet,
                        style: GoogleFonts.ibmPlexSansArabic(color: kInkMuted, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return StaggeredListItem(
                    delay: Duration(milliseconds: index * 80),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: kCream,
                        borderRadius: BorderRadius.circular(kRadiusMd),
                        border: Border.all(color: kParchment),
                        boxShadow: [kCardShadow],
                      ),
                      child: OperatorOfferCard(
                        plan: offer,
                        onEdit: () => _showOfferForm(offer: offer),
                        onDelete: () => _confirmDelete(offer.id),
                        onToggleBestValue: (val) => _toggleBestValue(offer, val),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: kGoldDeep)),
            error: (err, _) => Center(
              child: Text(
                l10n.errorGeneric(err.toString()),
                style: GoogleFonts.ibmPlexSansArabic(color: kStatusRejected),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (idx) {
            if (idx == 0) context.go('/at/dashboard');
            if (idx == 1) context.go('/at/surplus');
            if (idx == 2) context.go('/at/policies');
            if (idx == 3) context.go('/at/settings');
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kGoldDeep,
          unselectedItemColor: kInkMuted,
          backgroundColor: kIvory,
          selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.dashboard),
            BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_rounded), label: l10n.surplus),
            BottomNavigationBarItem(icon: const Icon(Icons.archive_outlined), label: l10n.policies),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
          ],
        ),
      ),
    );
  }
}

class AtOfferFormBottomSheet extends ConsumerStatefulWidget {
  final String companyEn;
  final PlanModel? existingOffer;

  const AtOfferFormBottomSheet({
    super.key,
    required this.companyEn,
    this.existingOffer,
  });

  @override
  ConsumerState<AtOfferFormBottomSheet> createState() => _AtOfferFormBottomSheetState();
}

class _AtOfferFormBottomSheetState extends ConsumerState<AtOfferFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _premiumController;
  late TextEditingController _coverageController;
  late TextEditingController _tabarruController;
  late TextEditingController _surplusController;
  late TextEditingController _durationController;
  late bool _isBestValue;
  late String _iconType;

  @override
  void initState() {
    super.initState();
    final offer = widget.existingOffer;
    _nameController = TextEditingController(text: offer?.companyName ?? '');
    _premiumController = TextEditingController(
      text: offer?.premium.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
    );
    _coverageController = TextEditingController(text: offer?.coverage ?? '');
    _tabarruController = TextEditingController(
      text: offer?.tabarruRate.replaceAll('%', '') ?? '',
    );
    _surplusController = TextEditingController(
      text: offer?.surplusRate.replaceAll('%', '') ?? '',
    );
    _durationController = TextEditingController(
      text: offer?.claimsDuration.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
    );
    _isBestValue = offer?.isBestValue ?? false;
    _iconType = offer?.iconType ?? 'shield';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _premiumController.dispose();
    _coverageController.dispose();
    _tabarruController.dispose();
    _surplusController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: kIvory,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: kParchment, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.existingOffer == null ? l10n.addNewOffer : l10n.editOfferData,
                style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: kGoldDeep),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildField(_nameController, l10n.offerName, Icons.edit, l10n),
              const SizedBox(height: 16),
              if (_iconType != 'rafik')
                _buildField(_premiumController, l10n.premiumAmount, Icons.payments_outlined, l10n, isNumeric: true),
              if (_iconType == 'rafik')
                _buildField(_tabarruController, l10n.suggestedTabarruRate, Icons.percent, l10n, isNumeric: true),
              const SizedBox(height: 16),
              _buildField(_coverageController, l10n.coverageLimit, Icons.shield_outlined, l10n),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField(_tabarruController, l10n.donationFundRate, Icons.volunteer_activism_outlined, l10n, isNumeric: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_surplusController, l10n.surplusDistributionRate, Icons.account_balance_wallet_outlined, l10n, isNumeric: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_durationController, l10n.claimsDurationDays, Icons.timer_outlined, l10n, isNumeric: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _iconType == 'rafik' || _iconType == 'shield' || _iconType == 'verified' ? _iconType : 'shield',
                dropdownColor: kIvory,
                style: GoogleFonts.ibmPlexSansArabic(color: kInk),
                decoration: _inputDecoration(l10n.offerIcon, Icons.category_outlined),
                items: [
                  DropdownMenuItem(value: 'shield', child: Text(l10n.shieldProtection)),
                  DropdownMenuItem(value: 'verified', child: Text(l10n.certifiedVerified)),
                  DropdownMenuItem(value: 'rafik', child: Text(l10n.rafiqAssistant)),
                ],
                onChanged: (v) => setState(() => _iconType = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  l10n.recommendedBestValue,
                  style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, color: kInk),
                ),
                value: _isBestValue,
                onChanged: (v) => setState(() => _isBestValue = v),
                activeColor: kGoldDeep,
                activeTrackColor: kCream,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SpringButton(
                child: ElevatedButton(
                  onPressed: _saveOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGoldDeep, foregroundColor: kIvory,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.saveOfferData,
                    style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, AppLocalizations l10n, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.ibmPlexSansArabic(color: kInk),
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: (v) => v == null || v.isEmpty ? l10n.fieldRequired : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.ibmPlexSansArabic(color: kInkMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: kGoldDeep, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusMd), borderSide: const BorderSide(color: kParchment)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusMd), borderSide: const BorderSide(color: kParchment)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusMd), borderSide: const BorderSide(color: kGoldDeep, width: 1.5)),
      filled: true,
      fillColor: kCream,
    );
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final opId = widget.companyEn.toLowerCase().contains('takaful') ? 'algeria_takaful' : 'al_ittihad';
    final premiumValue = _iconType == 'rafik' ? 0.0 : double.parse(_premiumController.text);

    final data = {
      'operator_id': opId,
      'name_ar': _nameController.text,
      'name_en': widget.companyEn,
      'premium_amount': premiumValue,
      'coverage_details': _coverageController.text,
      'tabarru_rate': double.parse(_tabarruController.text) / 100,
      'surplus_rate': double.parse(_surplusController.text) / 100,
      'claims_duration': '${_durationController.text} أيام',
      'is_best_value': _isBestValue,
      'icon_type': _iconType,
    };

    try {
      if (widget.existingOffer == null) {
        await ref.read(offerRepositoryProvider).addOffer(data);
      } else {
        await ref.read(offerRepositoryProvider).updateOffer(widget.existingOffer!.id, data);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.offerSaved, style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: kStatusAccepted,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDuringSave(e.toString()), style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: kStatusRejected,
          ),
        );
      }
    }
  }
}
