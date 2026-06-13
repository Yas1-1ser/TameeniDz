import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tameenidz/features/shared/domain/models/plan_model.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';

class SmartQuoteForm extends StatefulWidget {
  final PlanModel plan;
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  const SmartQuoteForm({
    super.key,
    required this.plan,
    required this.formKey,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<SmartQuoteForm> createState() => _SmartQuoteFormState();
}

class _SmartQuoteFormState extends State<SmartQuoteForm> {
  final ImagePicker _picker = ImagePicker();
  
  // PERFORMANCE: Persistent controllers prevent cursor jumps and lag.
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _getController(String key, String? initialValue) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue ?? ''),
    );
  }

  // PERFORMANCE: Pre-calculate static lists
  static final List<int> _ages = List.generate(75 - 18 + 1, (index) => 18 + index);
  
  // PERFORMANCE: Use ValueNotifier for surgical rebuilds of calculated values and images
  late final ValueNotifier<double?> _calculatedPremium;
  late final ValueNotifier<String?> _carteGrisePath;
  late final ValueNotifier<String?> _passportPhotoPath;
  late final ValueNotifier<String?> _lastAccidentDate;

  @override
  void initState() {
    super.initState();
    _calculatedPremium = ValueNotifier(widget.formData['calculated_premium']);
    _carteGrisePath = ValueNotifier(widget.formData['carte_grise_path']);
    _passportPhotoPath = ValueNotifier(widget.formData['passport_photo_path']);
    _lastAccidentDate = ValueNotifier(widget.formData['last_accident_date']);
  }

  @override
  void didUpdateWidget(SmartQuoteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // PERFORMANCE: Only reset if the PLAN actually changes (e.g. from Auto to Travel)
    if (oldWidget.plan.id != widget.plan.id) {
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      
      _calculatedPremium.value = widget.formData['calculated_premium'];
      _carteGrisePath.value = widget.formData['carte_grise_path'];
      _passportPhotoPath.value = widget.formData['passport_photo_path'];
      _lastAccidentDate.value = widget.formData['last_accident_date'];
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _calculatedPremium.dispose();
    _carteGrisePath.dispose();
    _passportPhotoPath.dispose();
    _lastAccidentDate.dispose();
    super.dispose();
  }

  void _updateData(String key, dynamic value) {
    widget.formData[key] = value;
    widget.onDataChanged(widget.formData);
  }

  Widget _buildVehicleForm(AppLocalizations l10n) {
    final isRafik = widget.plan.planCode == 'AL_RAFIK' || widget.plan.id.contains('rafik');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.carIdentity, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 8),
        ValueListenableBuilder<String?>(
          valueListenable: _carteGrisePath,
          builder: (context, path, _) {
            final hasImage = path != null;
            return InkWell(
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  _updateData('carte_grise_path', image.path);
                  _carteGrisePath.value = image.path;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: hasImage ? Colors.green.withValues(alpha: 0.05) : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(hasImage ? Icons.check_circle : Icons.camera_alt, 
                         color: hasImage ? Colors.green : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      hasImage ? l10n.uploadGrayCardSuccess : l10n.grayCardImage,
                      style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (isRafik) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _getController('car_value', widget.formData['car_value']?.toString()),
            decoration: InputDecoration(
              labelText: l10n.carValueLabel,
              hintText: l10n.exampleCarValue,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: const TextStyle(fontFamily: 'Cairo'),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final val = double.tryParse(value.replaceAll(',', ''));
              if (val != null) {
                _updateData('car_value', val);
                final calculated = val * 0.004;
                _updateData('calculated_premium', calculated);
                _calculatedPremium.value = calculated;
              } else {
                _calculatedPremium.value = null;
              }
            },
            validator: (value) => (value == null || value.isEmpty) ? l10n.enterCarValue : null,
          ),
          ValueListenableBuilder<double?>(
            valueListenable: _calculatedPremium,
            builder: (context, value, _) {
              if (value == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8, right: 4),
                child: Text(
                  l10n.estimatedPremium(NumberFormat('#,###').format(value)),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: widget.formData['driver_age'],
          decoration: InputDecoration(
            labelText: l10n.driverAge,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          items: _ages.map((age) {
            return DropdownMenuItem(value: age, child: Text("$age ${l10n.yearUnit}", style: const TextStyle(fontFamily: 'Cairo')));
          }).toList(),
          onChanged: (value) => _updateData('driver_age', value),
          validator: (value) => value == null ? l10n.selectDriverAge : null,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              final formatted = DateFormat('yyyy-MM-dd').format(date);
              _updateData('last_accident_date', formatted);
              _lastAccidentDate.value = formatted;
            }
          },
          child: ValueListenableBuilder<String?>(
            valueListenable: _lastAccidentDate,
            builder: (context, val, _) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.lastAccidentDateLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                ),
                child: Text(
                  val ?? l10n.none,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommercialForm(AppLocalizations l10n) {
    final isChamil = widget.plan.planCode == 'AL_CHAMIL' || widget.plan.id.contains('chamil');
    
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: widget.formData['activity_nature'],
          decoration: InputDecoration(
            labelText: l10n.activityNature,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          items: [l10n.commerce, l10n.industry, l10n.services, l10n.supermarket, l10n.restaurant].map((activity) {
            return DropdownMenuItem(value: activity, child: Text(activity, style: const TextStyle(fontFamily: 'Cairo')));
          }).toList(),
          onChanged: (value) => _updateData('activity_nature', value),
          validator: (value) => value == null ? l10n.selectActivityNature : null,
        ),
        if (isChamil) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.formData['duration'] ?? '1y',
            decoration: InputDecoration(
              labelText: l10n.insuranceDurationLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: const TextStyle(fontFamily: 'Cairo'),
            ),
            items: [
              DropdownMenuItem(value: '6m', child: Text(l10n.sixMonths, style: const TextStyle(fontFamily: 'Cairo'))),
              DropdownMenuItem(value: '1y', child: Text(l10n.oneYear, style: const TextStyle(fontFamily: 'Cairo'))),
            ],
            onChanged: (value) => _updateData('duration', value),
            validator: (value) => value == null ? l10n.selectInsuranceDuration : null,
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('equipment_value', widget.formData['equipment_value']?.toString()),
          decoration: InputDecoration(
            labelText: l10n.equipmentValueLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final val = double.tryParse(value.replaceAll(',', ''));
            if (val != null) _updateData('equipment_value', val);
          },
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterEquipmentValue : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('goods_value', widget.formData['goods_value']?.toString()),
          decoration: InputDecoration(
            labelText: l10n.goodsValueLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final val = double.tryParse(value.replaceAll(',', ''));
            if (val != null) _updateData('goods_value', val);
          },
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterGoodsValue : null,
        ),
      ],
    );
  }

  Widget _buildProfessionalForm(AppLocalizations l10n) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: widget.formData['profession_type'],
          decoration: InputDecoration(
            labelText: l10n.professionType,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          items: [l10n.doctor, l10n.lawyer, l10n.engineer, l10n.contractor, l10n.artisan].map((prof) {
            return DropdownMenuItem(value: prof, child: Text(prof, style: const TextStyle(fontFamily: 'Cairo')));
          }).toList(),
          onChanged: (value) => _updateData('profession_type', value),
          validator: (value) => value == null ? l10n.selectProfessionType : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('registration_number', widget.formData['registration_number']),
          decoration: InputDecoration(
            labelText: l10n.registrationNumberLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('registration_number', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterRegistrationNumber : null,
        ),
      ],
    );
  }

  Widget _buildTravelForm(AppLocalizations l10n) {
    return Column(
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: _passportPhotoPath,
          builder: (context, path, _) {
            final hasImage = path != null;
            return InkWell(
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  _updateData('passport_photo_path', image.path);
                  _passportPhotoPath.value = image.path;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: hasImage ? Colors.blue.withValues(alpha: 0.05) : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(hasImage ? Icons.check_circle : Icons.camera_alt, 
                         color: hasImage ? Colors.blue : Colors.grey),
                    const SizedBox(width: 12),
                    Text(l10n.passportPhotoLabel, style: const TextStyle(fontFamily: 'Cairo')),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('destination', widget.formData['destination']),
          decoration: InputDecoration(
            labelText: l10n.travelDestinationLabel,
            hintText: l10n.exampleDestination,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('destination', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterDestination : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('duration_days', widget.formData['duration_days']?.toString()),
          decoration: InputDecoration(
            labelText: l10n.travelDurationLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _updateData('duration_days', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterDuration : null,
        ),
      ],
    );
  }

  Widget _buildHomeForm(AppLocalizations l10n) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: widget.formData['residence_type'],
          decoration: InputDecoration(
            labelText: l10n.residenceTypeLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          items: [l10n.apartment, l10n.villa, l10n.individualHouse].map((type) {
            return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontFamily: 'Cairo')));
          }).toList(),
          onChanged: (value) => _updateData('residence_type', value),
          validator: (value) => value == null ? l10n.selectResidenceType : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('address', widget.formData['address']),
          decoration: InputDecoration(
            labelText: l10n.fullAddressLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('address', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterAddress : null,
        ),
      ],
    );
  }

  Widget _buildCargoForm(AppLocalizations l10n) {
    return Column(
      children: [
        TextFormField(
          controller: _getController('goods_nature', widget.formData['goods_nature']),
          decoration: InputDecoration(
            labelText: l10n.goodsNatureLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('goods_nature', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterGoodsNature : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('goods_value', widget.formData['goods_value']?.toString()),
          decoration: InputDecoration(
            labelText: l10n.cargoGoodsValueLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _updateData('goods_value', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterCargoValue : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('route', widget.formData['route']),
          decoration: InputDecoration(
            labelText: l10n.routeLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('route', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterRoute : null,
        ),
      ],
    );
  }

  Widget _buildAgriIndusForm(AppLocalizations l10n) {
    return Column(
      children: [
        TextFormField(
          controller: _getController('facility_type', widget.formData['facility_type']),
          decoration: InputDecoration(
            labelText: l10n.facilityTypeLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('facility_type', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterFacilityType : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _getController('facility_size', widget.formData['facility_size']),
          decoration: InputDecoration(
            labelText: l10n.facilitySizeLabel,
            hintText: l10n.exampleFacilitySize,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(fontFamily: 'Cairo'),
          ),
          onChanged: (value) => _updateData('facility_size', value),
          validator: (value) => (value == null || value.isEmpty) ? l10n.enterFacilitySize : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Cache localization to avoid O(N) lookup in child builders
    final l10n = AppLocalizations.of(context)!;
    final code = widget.plan.planCode;
    
    Widget formFields;
    if (['AUTO_RC', 'AUTO_TR', 'AL_RAFIK'].contains(code)) {
      formFields = _buildVehicleForm(l10n);
    } else if (['COMMERCIAL', 'MULTIRISQUE_PRO', 'AL_CHAMIL'].contains(code)) {
      formFields = _buildCommercialForm(l10n);
    } else if (['RCP', 'AL_TAAZUR'].contains(code)) {
      formFields = _buildProfessionalForm(l10n);
    } else if (['AL_SAFAR', 'TRAVEL'].contains(code)) {
      formFields = _buildTravelForm(l10n);
    } else if (['AL_WAKY', 'HOME'].contains(code)) {
      formFields = _buildHomeForm(l10n);
    } else if (['TRANSPORT_MARCHANDISES'].contains(code)) {
      formFields = _buildCargoForm(l10n);
    } else if (['AGRI_INDUS'].contains(code)) {
      formFields = _buildAgriIndusForm(l10n);
    } else {
      formFields = _buildCommercialForm(l10n);
    }

    return Form(
      key: widget.formKey,
      // PERFORMANCE: RepaintBoundary isolates the static form fields from 
      // parent rebuilds (like keyboard sliding or app bar animations).
      child: RepaintBoundary(child: formFields),
    );
  }
}
