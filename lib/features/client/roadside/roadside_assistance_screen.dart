import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';
import 'package:tameenidz/core/utils/responsive.dart';
import 'package:tameenidz/features/shared/widgets/page_entry_animation.dart';
import 'package:tameenidz/features/shared/widgets/animations/staggered_list_item.dart';
import 'package:tameenidz/core/services/sos_service.dart';
import 'package:tameenidz/features/shared/domain/models/garage_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class RoadsideAssistanceScreen extends StatefulWidget {
  const RoadsideAssistanceScreen({super.key});

  @override
  State<RoadsideAssistanceScreen> createState() =>
      _RoadsideAssistanceScreenState();
}

class _RoadsideAssistanceScreenState extends State<RoadsideAssistanceScreen>
    with SingleTickerProviderStateMixin {
  final SosService _sosService = SosService();

  // Dynamic UI settings from DB
  Map<String, String> _dbSettings = {};
  bool _isLoadingSettings = true;

  // SOS States
  bool _isScanning = false;
  bool _sosResolved = false;
  final ValueNotifier<double> _scanProgressNotifier = ValueNotifier(0.0);
  Timer? _scanTimer;
  GarageModel? _nearestTruck;
  late final AnimationController _pulseController;

  // Filter States
  String _selectedWilaya = 'الكل';
  String _selectedSpecialty = 'الكل';
  String _searchQuery = '';

  // PERFORMANCE: Cache the future to prevent re-fetching on every keystroke/rebuild
  Future<List<GarageModel>>? _garagesFuture;

  final List<String> _wilayas = [
    'الكل',
    'الجزائر',
    'وهران',
    'قسنطينة',
    'البليدة',
    'بومرداس',
  ];
  final List<String> _specialties = ['الكل', 'ميكانيك', 'كهرباء', 'عجلات'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadDbSettings();
    _updateGaragesFuture();
  }

  Future<void> _loadDbSettings() async {
    try {
      final settings = await _sosService.fetchRoadsideSettings();
      if (mounted) {
        setState(() {
          _dbSettings = settings;
          _isLoadingSettings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
      }
    }
  }

  void _updateGaragesFuture() {
    _garagesFuture = _sosService.fetchGarages(
      wilaya: _selectedWilaya == 'الكل' ? null : _selectedWilaya,
      specialty: _mapSpecialty(_selectedSpecialty),
    );
  }

  String _getSetting(String key, String fallback) {
    return _dbSettings[key] ?? fallback;
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _pulseController.dispose();
    _scanProgressNotifier.dispose();
    super.dispose();
  }

  Future<void> _triggerSosSearch() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _sosResolved = false;
      _nearestTruck = null;
    });
    _scanProgressNotifier.value = 0.0;

    _scanTimer = Timer.periodic(const Duration(milliseconds: 150), (
      timer,
    ) async {
      if (_scanProgressNotifier.value < 1.0) {
        _scanProgressNotifier.value += 0.1;
      } else {
        _scanTimer?.cancel();
        try {
          final trucks = await _sosService.fetchTowingTrucks(
            wilaya: _selectedWilaya == 'الكل' ? null : _selectedWilaya,
          );
          if (mounted) {
            setState(() {
              _isScanning = false;
              _sosResolved = true;
              if (trucks.isNotEmpty) {
                _nearestTruck = trucks.first;
              } else {
                _nearestTruck = GarageModel(
                  id: 'fallback_tow',
                  name: 'عمي أحمد للتصليح والقطر السريع',
                  phone: '+213 555 12 34 56',
                  wilaya:
                      _selectedWilaya == 'الكل' ? 'الجزائر' : _selectedWilaya,
                  specialty: 'general',
                  rating: 4.9,
                  isTowing: true,
                  createdAt: DateTime.now(),
                  distanceKm: 1.5,
                );
              }
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isScanning = false;
              _sosResolved = true;
              _nearestTruck = GarageModel(
                id: 'fallback_tow_err',
                name: 'عمي أحمد للتصليح والقطر السريع',
                phone: '+213 555 12 34 56',
                wilaya: 'الجزائر',
                specialty: 'general',
                rating: 4.9,
                isTowing: true,
                createdAt: DateTime.now(),
                distanceKm: 1.5,
              );
            });
          }
        }
      }
    });
  }

  void _resetSos() {
    setState(() {
      _sosResolved = false;
      _nearestTruck = null;
    });
    _scanProgressNotifier.value = 0.0;
  }

  void _simulateCall(String name, String phone) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.colors.beigeBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.phone_in_talk_rounded,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.callingDirect,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            content: Text(
              l10n.callConfirmationPrompt(name, phone),
              style: TextStyle(
                color: context.colors.darkText,
                height: 1.4,
                fontFamily: 'Cairo',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.callingPerson(name),
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  l10n.callItemButton,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
    );
  }

  String? _mapSpecialty(String selected) {
    switch (selected) {
      case 'ميكانيك':
        return 'general';
      case 'كهرباء':
        return 'electrician';
      case 'عجلات':
        return 'tires';
      default:
        return null;
    }
  }

  String _getWilayaLabel(String w, AppLocalizations l10n) {
    switch (w) {
      case 'الكل':
        return l10n.filterAll;
      case 'الجزائر':
        return l10n.provinceAlgiers;
      case 'وهران':
        return l10n.provinceOran;
      case 'قسنطينة':
        return l10n.provinceConstantine;
      case 'البليدة':
        return l10n.provinceBlida;
      case 'بومرداس':
        return l10n.provinceBoumerdes;
      default:
        return w;
    }
  }

  String _getSpecialtyLabelForFilter(String s, AppLocalizations l10n) {
    switch (s) {
      case 'الكل':
        return l10n.filterAll;
      case 'ميكانيك':
        return l10n.specialtyMechanicFilter;
      case 'كهرباء':
        return l10n.specialtyElectricianFilter;
      case 'عجلات':
        return l10n.specialtyTiresFilter;
      default:
        return s;
    }
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'general':
      case 'mechanic':
        return Icons.build_rounded;
      case 'electrician':
      case 'electric':
        return Icons.offline_bolt_rounded;
      case 'tires':
        return Icons.tire_repair_rounded;
      default:
        return Icons.home_repair_service_rounded;
    }
  }

  String _getSpecialtyLabel(String specialty, AppLocalizations l10n) {
    switch (specialty) {
      case 'general':
      case 'mechanic':
        return l10n.specialtyMechanic;
      case 'electrician':
      case 'electric':
        return l10n.specialtyElectrician;
      case 'tires':
        return l10n.specialtyTires;
      default:
        return l10n.specialtyDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingSettings) {
      return Scaffold(
        backgroundColor: context.colors.beigeBg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.beigeBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          l10n.roadsideAppTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageEntryAnimation(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildIntroSection(l10n),
                  const SizedBox(height: 24),
                  _buildSosSection(l10n),
                  const SizedBox(height: 36),
                  _buildDirectoryHeader(l10n),
                ]),
              ),
            ),
            _buildDirectoryGaragesSliver(l10n),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 36),
                  _buildDefinitionsSection(l10n),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.goldDeep,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getSetting('intro_title', l10n.roadsideServices),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _getSetting('intro_desc', l10n.roadsideSubtitle),
            style: TextStyle(
              fontSize: 13,
              color: context.colors.slate700,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getSetting('sos_title', l10n.sosTitle),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 6),
          Text(
            _getSetting('sos_subtitle', l10n.sosSubtitle),
            style: TextStyle(
              fontSize: 12,
              color: context.colors.slate500,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 28),
          if (!_isScanning && !_sosResolved) ...[
            GestureDetector(
              onTap: _triggerSosSearch,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppColors.rejected,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rejected.withValues(
                            alpha: 0.3 * (1 - _pulseController.value),
                          ),
                          blurRadius: 25,
                          spreadRadius: _pulseController.value * 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: context.colors.surface,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else if (_isScanning) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scanProgressNotifier,
                    builder: (context, progress, child) {
                      return CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        color: AppColors.primaryGreen,
                        backgroundColor: AppColors.borderLight,
                      );
                    },
                  ),
                ),
                const Icon(
                      Icons.gps_fixed_rounded,
                      color: AppColors.primaryGreen,
                      size: 40,
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .rotate(duration: 2.seconds),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.gpsScanningMessage,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ] else if (_sosResolved && _nearestTruck != null) ...[
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.statusGreenFg,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.locationDeterminedSuccess,
                        style: TextStyle(
                          color: AppColors.statusGreenFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.colors.beigeBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.goldDeep,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nearestTruck!.id == 'fallback_tow'
                                  ? l10n.fallbackTruckName
                                  : _nearestTruck!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: AppColors.darkBrown,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.goldAccent,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${_nearestTruck!.rating} / 5',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.slate700,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.distanceAway(
                                    _nearestTruck!.distanceKm?.toString() ??
                                        '1.5',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed:
                            () => _simulateCall(
                              _nearestTruck!.id == 'fallback_tow'
                                  ? l10n.fallbackTruckName
                                  : _nearestTruck!.name,
                              _nearestTruck!.phone,
                            ),
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                        label: Text(
                          l10n.callDirectlyNow,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.borderLight.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: _resetSos,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDirectoryHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.goldAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.certifiedGaragesDirectory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWilaya,
                    isExpanded: true,
                    style: TextStyle(
                      color: context.colors.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                    items:
                        _wilayas.map((w) {
                          return DropdownMenuItem<String>(
                            value: w,
                            child: Text(
                              w == 'الكل'
                                  ? '${l10n.wilayaFilterPrefix}${l10n.filterAll}'
                                  : _getWilayaLabel(w, l10n),
                            ),
                          );
                        }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedWilaya = v;
                          _updateGaragesFuture();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSpecialty,
                    isExpanded: true,
                    style: TextStyle(
                      color: context.colors.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                    items:
                        _specialties.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(
                              s == 'الكل'
                                  ? '${l10n.specialtyFilterPrefix}${l10n.filterAll}'
                                  : _getSpecialtyLabelForFilter(s, l10n),
                            ),
                          );
                        }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedSpecialty = v;
                          _updateGaragesFuture();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: l10n.searchGarageHint,
              hintStyle: TextStyle(
                color: context.colors.slate400,
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colors.slate400,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectoryGaragesSliver(AppLocalizations l10n) {
    return FutureBuilder<List<GarageModel>>(
      future: _garagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.goldAccent),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
              ),
              child: Text(
                l10n.errorLoadingGarages,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          );
        }

        final garages = snapshot.data ?? [];
        final filtered =
            garages.where((g) {
              return _searchQuery.isEmpty ||
                  g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  g.wilaya.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

        if (filtered.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: context.colors.slate400,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.noGaragesFound,
                    style: TextStyle(
                      color: context.colors.slate500,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final garage = filtered[index];
              return StaggeredListItem(
                delay: Duration(milliseconds: index * 40),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getSpecialtyIcon(garage.specialty),
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  garage.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppColors.darkBrown,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getSpecialtyLabel(garage.specialty, l10n),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.goldDeep,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.goldAccent,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${garage.rating} / 5',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.slate700,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: context.colors.slate400,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${_getWilayaLabel(garage.wilaya, l10n)} (${l10n.distanceAway(garage.distanceKm?.toString() ?? '1.5')})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.slate500,
                                        fontFamily: 'Cairo',
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
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              l10n.appSubscriberDiscount(
                                garage.discountPercent.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.goldDeep,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(
                                color: AppColors.primaryGreen,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            onPressed:
                                () => _simulateCall(garage.name, garage.phone),
                            icon: const Icon(Icons.phone, size: 14),
                            label: Text(
                              l10n.callItemButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: filtered.length),
          ),
        );
      },
    );
  }

  Widget _buildDefinitionsSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.goldAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.takafulDefinitionHeader,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getSetting('takaful_title', l10n.takafulConcept),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 6),
              Text(
                _getSetting('takaful_desc', l10n.takafulDescription),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.slate700,
                  height: 1.5,
                  fontFamily: 'Cairo',
                ),
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              Text(
                _getSetting('motto_title', l10n.takafulPhilosophy),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 6),
              Text(
                _getSetting('motto_desc', l10n.roadsideSubtitle),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.slate700,
                  height: 1.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
