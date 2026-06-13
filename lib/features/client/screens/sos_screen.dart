// lib/features/client/screens/sos_screen.dart
// FIXED per document requirements:
// 1. Big red circular SOS button in center
// 2. On press → GPS read → show nearest tow truck (photo, name, phone, DIRECT CALL button)
// 3. Garage directory with wilaya + specialty filters
// 4. Garage card: rating, distance, 15% discount badge
// 5. Page entry animation + staggered list

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/services/sos_service.dart';
import 'package:tameenidz/features/shared/domain/models/garage_model.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/spring_button.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  final SosService _sosService = SosService();
  String _selectedWilaya = '';
  String _selectedSpecialty = 'mechanic_all';

  // SOS state
  bool _sosActivated = false;
  bool _isLocating = false;
  _TowTruck? _nearestTruck;

  late final AnimationController _pulseController;
  Future<List<GarageModel>>? _garagesFuture;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_garagesFuture == null) {
      _refreshGarages();
    }
  }

  void _refreshGarages() {
    final l10n = AppLocalizations.of(context)!;
    final w = _selectedWilaya.isEmpty ? l10n.all : _selectedWilaya;
    _garagesFuture = _sosService.fetchGarages(
      wilaya: w == l10n.all ? null : w,
      specialty:
          _selectedSpecialty == 'mechanic_all' ? null : _selectedSpecialty,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<String> get _wilayas {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.all,
      l10n.wilaya1, l10n.wilaya2, l10n.wilaya3, l10n.wilaya4, l10n.wilaya5,
      l10n.wilaya6, l10n.wilaya7, l10n.wilaya8, l10n.wilaya9, l10n.wilaya10,
      l10n.wilaya11, l10n.wilaya12, l10n.wilaya13, l10n.wilaya14, l10n.wilaya15,
      l10n.wilaya16, l10n.wilaya17, l10n.wilaya18, l10n.wilaya19, l10n.wilaya20,
      l10n.wilaya21, l10n.wilaya22, l10n.wilaya23, l10n.wilaya24, l10n.wilaya25,
      l10n.wilaya26, l10n.wilaya27, l10n.wilaya28, l10n.wilaya29, l10n.wilaya30,
      l10n.wilaya31, l10n.wilaya32, l10n.wilaya33, l10n.wilaya34, l10n.wilaya35,
      l10n.wilaya36, l10n.wilaya37, l10n.wilaya38, l10n.wilaya39, l10n.wilaya40,
      l10n.wilaya41, l10n.wilaya42, l10n.wilaya43, l10n.wilaya44, l10n.wilaya45,
      l10n.wilaya46, l10n.wilaya47, l10n.wilaya48,
    ];
  }

  Map<String, String> get _specialties {
    final l10n = AppLocalizations.of(context)!;
    return {
      'mechanic_all': l10n.all,
      'mechanic': l10n.mechanic,
      'electric': l10n.electric,
      'tires': l10n.tires,
      'towing': l10n.towing,
    };
  }

  // ── SOS Activation ────────────────────────────────────────────────────────
  Future<void> _activateSOS() async {
    setState(() {
      _isLocating = true;
      _sosActivated = false;
      _nearestTruck = null;
    });

    // Simulate GPS read (1.5s) then show nearest truck
    await Future.delayed(const Duration(milliseconds: 1500));

    // In production: use geolocator to get position, then query Supabase for
    // nearest tow truck ordered by PostGIS distance.
    // For now: mock data matching document requirements.
    if (mounted) {
      setState(() {
        _isLocating = false;
        _sosActivated = true;
        _nearestTruck = _TowTruck(
          name: AppLocalizations.of(context)!.dummyEmergencyStation,
          phone: '+213 555 123 456',
          specialty: AppLocalizations.of(context)!.dummyTowingService,
          distanceKm: 2.3,
          rating: 4.8,
        );
      });
    }
  }

  Future<void> _callTruck(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedWilaya.isEmpty) _selectedWilaya = l10n.all;

    Color bgBeige = context.colors.beigeBg;
    const Color accentGold = AppColors.goldAccent;
    const Color darkGreen = AppColors.primaryGreen;
    const Color sosRed = Color(0xFFD94F4F);

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // FIXED: Remove duplicated back button
        backgroundColor: bgBeige,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.roadsideAssistanceTitle,
          style: const TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: accentGold),
            onPressed: () {},
          ),
        ],
      ),
      body: PageEntryAnimation(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PART 1: SOS EMERGENCY SECTION ─────────────────────────────
              _buildSOSSection(sosRed, darkGreen, accentGold, l10n),

              const SizedBox(height: 32),

              // ── PART 2: GARAGE DIRECTORY ───────────────────────────────────
              _buildGarageDirectory(darkGreen, accentGold, l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ── SOS Section ───────────────────────────────────────────────────────────
  Widget _buildSOSSection(
    Color sosRed,
    Color darkGreen,
    Color accentGold,
    AppLocalizations l10n,
  ) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [sosRed, sosRed.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: sosRed.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header text
              Text(
                AppLocalizations.of(context)!.sosEmergencyTitle,
                style: const TextStyle(
                  fontFamily: 'IBMPlexArabic',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.sosServiceSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBMPlexArabic',
                  fontSize: 13,
                  height: 1.5,
                  color: context.colors.surface.withValues(alpha: 0.85),
                ),
              ),

              const SizedBox(height: 28),

              // Big circular SOS button (as per doc)
              _buildBigSOSButton(sosRed, l10n),

              // Show truck info after activation
              if (_sosActivated && _nearestTruck != null) ...[
                const SizedBox(height: 24),
                _buildTruckCard(_nearestTruck!, accentGold),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildBigSOSButton(Color sosRed, AppLocalizations l10n) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        child: SpringButton(
          onTap: _isLocating ? null : _activateSOS,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _sosActivated ? Colors.green.shade600 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child:
                _isLocating
                    ? const CircularProgressIndicator(color: Color(0xFFD94F4F))
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _sosActivated
                              ? Icons.check_circle_rounded
                              : Icons.sos_rounded,
                          color:
                              _sosActivated
                                  ? Colors.white
                                  : const Color(0xFFD94F4F),
                          size: 36,
                        ),
                        Text(
                          _sosActivated ? AppLocalizations.of(context)!.done : AppLocalizations.of(context)!.sos,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                _sosActivated
                                    ? Colors.white
                                    : const Color(0xFFD94F4F),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        builder: (context, child) {
          final pulse = _sosActivated ? 0.0 : _pulseController.value;
          return RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring
                if (!_sosActivated)
                  Container(
                    width: 120 + (pulse * 20),
                    height: 120 + (pulse * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.surface.withValues(
                        alpha: 0.10 + pulse * 0.05,
                      ),
                    ),
                  ),
                // Inner pulse ring
                if (!_sosActivated)
                  Container(
                    width: 110 + (pulse * 10),
                    height: 110 + (pulse * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.surface.withValues(alpha: 0.12),
                    ),
                  ),
                child!,
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Nearest Truck Card (shown after SOS press) ────────────────────────────
  Widget _buildTruckCard(_TowTruck truck, Color accentGold) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Truck "photo" — avatar with icon (in production: NetworkImage)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: context.colors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: context.colors.surface,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truck.name,
                          style: TextStyle(
                            fontFamily: 'IBMPlexArabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: context.colors.surface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          truck.specialty,
                          style: TextStyle(
                            fontFamily: 'IBMPlexArabic',
                            fontSize: 12,
                            color: context.colors.surface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.goldAccent,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${truck.rating}/5',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.surface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.distanceKm(truck.distanceKm),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Phone + Direct Call button (as per document)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      truck.phone,
                      style: TextStyle(
                        fontFamily: 'IBMPlexArabic',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.colors.surface,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _callTruck(truck.phone),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.directCall),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.surface,
                        foregroundColor: const Color(0xFFD94F4F),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'IBMPlexArabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }

  // ── Garage Directory ──────────────────────────────────────────────────────
  Widget _buildGarageDirectory(
    Color darkGreen,
    Color accentGold,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              l10n.verifiedGarages,
              style: TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'IBMPlexArabic',
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideX(begin: 0.05, end: 0, duration: 400.ms),

        Text(
          l10n.chooseByWilayaAndSpecialty,
          style: TextStyle(color: context.colors.slate500, fontSize: 13),
        ),

        const SizedBox(height: 16),
        _buildFilterRow(accentGold, darkGreen, l10n),
        const SizedBox(height: 16),

        FutureBuilder<List<GarageModel>>(
          future: _garagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: accentGold),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildErrorCard(accentGold, l10n);
            }
            final garages = snapshot.data ?? [];
            if (garages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.garage_rounded,
                        size: 48,
                        color: darkGreen.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noGaragesInThisArea,
                        style: TextStyle(
                          color: darkGreen.withValues(alpha: 0.5),
                          fontFamily: 'IBMPlexArabic',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: garages.length,
              itemBuilder:
                  (context, index) => StaggeredListItem(
                    delay: Duration(milliseconds: 100 + index * 80),
                    child: _GarageCard(garage: garages[index]),
                  ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterRow(
    Color accentGold,
    Color darkGreen,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _DropdownFilter<String>(
            value: _selectedWilaya,
            items: _wilayas,
            label: AppLocalizations.of(context)!.wilayaLabel,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedWilaya = v);
                _refreshGarages();
              }
            },
            accentColor: darkGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DropdownFilter<String>(
            value: _selectedSpecialty,
            items: _specialties.keys.toList(),
            itemLabels: _specialties,
            label: AppLocalizations.of(context)!.specialtyLabel,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedSpecialty = v);
                _refreshGarages();
              }
            },
            accentColor: darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(Color accentGold, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.failedToLoadGarages,
              style: const TextStyle(fontFamily: 'IBMPlexArabic'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Garage Card (per document: rating, distance, 15% discount badge) ────────
class _GarageCard extends StatelessWidget {
  final GarageModel garage;
  const _GarageCard({required this.garage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Garage icon / photo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.car_repair_rounded,
                  color: AppColors.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            garage.name,
                            style: const TextStyle(
                              fontFamily: 'IBMPlexArabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        // ── 15% DISCOUNT BADGE (per document) ────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.goldAccent.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.discountBadge(garage.discountPercent),
                            style: const TextStyle(
                              fontFamily: 'IBMPlexArabic',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      garage.specialty,
                      style: TextStyle(
                        fontFamily: 'IBMPlexArabic',
                        fontSize: 12,
                        color: AppColors.primaryGreen.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Rating (per document: e.g. 4.8/5)
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.goldAccent,
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${garage.rating}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Distance (per document: distance in km)
                        if (garage.distanceKm != null) ...[
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.goldAccent,
                            size: 15,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            AppLocalizations.of(context)!.distanceKm(garage.distanceKm ?? 0),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          garage.wilaya,
                          style: TextStyle(
                            fontFamily: 'IBMPlexArabic',
                            fontSize: 12,
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Call button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('tel:${garage.phone}');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              icon: const Icon(Icons.call_rounded, size: 16),
              label: Text(garage.phone, textDirection: TextDirection.ltr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'IBMPlexArabic',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generic Dropdown Filter ──────────────────────────────────────────────────
class _DropdownFilter<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final Map<T, String>? itemLabels;
  final String label;
  final ValueChanged<T?> onChanged;
  final Color accentColor;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.accentColor,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: TextStyle(
            fontFamily: 'IBMPlexArabic',
            fontSize: 13,
            color: accentColor,
          ),
          items:
              items
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(itemLabels?[e] ?? e.toString()),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: accentColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Tow Truck Data Model (local) ─────────────────────────────────────────────
class _TowTruck {
  final String name;
  final String phone;
  final String specialty;
  final double distanceKm;
  final double rating;

  const _TowTruck({
    required this.name,
    required this.phone,
    required this.specialty,
    required this.distanceKm,
    required this.rating,
  });
}
