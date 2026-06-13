import 'package:flutter/material.dart';
import 'package:tameenidz/features/shared/domain/models/plan_model.dart';
import 'package:tameenidz/features/shared/domain/models/policy_model.dart';

/// One required upload for a quote (تسعيرة) by service type.
class QuoteDocumentSpec {
  const QuoteDocumentSpec({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.labelFr,
    required this.labelKab,
    required this.icon,
  });

  final String key;
  final String labelAr;
  final String labelEn;
  final String labelFr;
  final String labelKab;
  final IconData icon;

  String label(String languageCode) {
    switch (languageCode) {
      case 'en':
        return labelEn;
      case 'fr':
        return labelFr;
      case 'kab':
        return labelKab;
      default:
        return labelAr;
    }
  }
}

/// Required documents per insurance service (AT / AI client quote flow).
class ServiceDocuments {
  ServiceDocuments._();

  static const _carteGrise = QuoteDocumentSpec(
    key: 'carte_grise',
    labelAr: 'البطاقة الرمادية',
    labelEn: 'Grey Card (Carte Grise)',
    labelFr: 'Carte Grise',
    labelKab: 'Carte Grise (Takarḍa tazeggaɣt)',
    icon: Icons.directions_car_rounded,
  );

  static const _nationalId = QuoteDocumentSpec(
    key: 'national_id',
    labelAr: 'بطاقة التعريف الوطنية',
    labelEn: 'National ID Card',
    labelFr: 'Carte Nationale d\'Identité',
    labelKab: 'Tasekkart n tmagit taɣelnawt',
    icon: Icons.badge_rounded,
  );

  static const _drivingLicense = QuoteDocumentSpec(
    key: 'driving_license',
    labelAr: 'رخصة السياقة',
    labelEn: 'Driving License',
    labelFr: 'Permis de Conduire',
    labelKab: 'Turagt n tsureft',
    icon: Icons.assignment_rounded,
  );

  static const _passport = QuoteDocumentSpec(
    key: 'passport',
    labelAr: 'جواز السفر',
    labelEn: 'Passport',
    labelFr: 'Passeport',
    labelKab: 'Apaspur',
    icon: Icons.menu_book_rounded,
  );

  static const _travelBooking = QuoteDocumentSpec(
    key: 'travel_booking',
    labelAr: 'حجز السفر / التذكرة',
    labelEn: 'Travel Booking / Ticket',
    labelFr: 'Réservation de voyage',
    labelKab: 'Ajereb n usafar',
    icon: Icons.flight_rounded,
  );

  static const _propertyDeed = QuoteDocumentSpec(
    key: 'property_deed',
    labelAr: 'سند الملكية / عقد الكراء',
    labelEn: 'Property Deed / Lease',
    labelFr: 'Titre de propriété',
    labelKab: 'Agdil n tmelkit',
    icon: Icons.home_work_rounded,
  );

  static const _propertyPhotos = QuoteDocumentSpec(
    key: 'property_photos',
    labelAr: 'صور العقار',
    labelEn: 'Property Photos',
    labelFr: 'Photos du bien',
    labelKab: 'Tiwlafin n wexxam',
    icon: Icons.photo_library_rounded,
  );

  static const _commercialRegister = QuoteDocumentSpec(
    key: 'commercial_register',
    labelAr: 'السجل التجاري',
    labelEn: 'Commercial Register',
    labelFr: 'Registre de commerce',
    labelKab: 'Ajerred n tsenselkt',
    icon: Icons.store_rounded,
  );

  static const _nif = QuoteDocumentSpec(
    key: 'nif',
    labelAr: 'الرقم التعريفي الجبائي (NIF)',
    labelEn: 'Tax ID (NIF)',
    labelFr: 'NIF',
    labelKab: 'NIF (Uṭṭun n unekcum n tabzert)',
    icon: Icons.numbers_rounded,
  );

  static const _professionalCard = QuoteDocumentSpec(
    key: 'professional_card',
    labelAr: 'بطاقة الهيئة المهنية',
    labelEn: 'Professional Registration Card',
    labelFr: 'Carte professionnelle',
    labelKab: 'Takarḍa n twuri',
    icon: Icons.work_rounded,
  );

  static const _cargoInvoice = QuoteDocumentSpec(
    key: 'cargo_invoice',
    labelAr: 'فاتورة / قائمة البضاعة',
    labelEn: 'Cargo Invoice / Packing List',
    labelFr: 'Facture marchandises',
    labelKab: 'Alfatura n sselɛa',
    icon: Icons.local_shipping_rounded,
  );

  static const _routeDoc = QuoteDocumentSpec(
    key: 'route_document',
    labelAr: 'وثيقة خط السير',
    labelEn: 'Route / Transport Document',
    labelFr: 'Document d\'itinéraire',
    labelKab: 'Asemli n webrid',
    icon: Icons.map_rounded,
  );

  static const _facilityPhotos = QuoteDocumentSpec(
    key: 'facility_photos',
    labelAr: 'صور المنشأة / المستثمرة',
    labelEn: 'Facility Photos',
    labelFr: 'Photos de l\'installation',
    labelKab: 'Tiwlafin n tnekkimt',
    icon: Icons.agriculture_rounded,
  );

  static const _carImg1 = QuoteDocumentSpec(
    key: 'car_img_1',
    labelAr: 'صورة السيارة 1 (أمامية)',
    labelEn: 'Car Image 1 (Front)',
    labelFr: 'Image Voiture 1 (Avant)',
    labelKab: 'Tawlaft n tkarrust 1 (Zdat)',
    icon: Icons.add_a_photo_rounded,
  );

  static const _carImg2 = QuoteDocumentSpec(
    key: 'car_img_2',
    labelAr: 'صورة السيارة 2 (خلفية)',
    labelEn: 'Car Image 2 (Back)',
    labelFr: 'Image Voiture 2 (Arrière)',
    labelKab: 'Tawlaft n tkarrust 2 (Deffir)',
    icon: Icons.add_a_photo_rounded,
  );

  static const _carImg3 = QuoteDocumentSpec(
    key: 'car_img_3',
    labelAr: 'صورة السيارة 3 (الجانب الأيمن)',
    labelEn: 'Car Image 3 (Right Side)',
    labelFr: 'Image Voiture 3 (Côté Droit)',
    labelKab: 'Tawlaft n tkarrust 3 (Afus ayeffus)',
    icon: Icons.add_a_photo_rounded,
  );

  static const _carImg4 = QuoteDocumentSpec(
    key: 'car_img_4',
    labelAr: 'صورة السيارة 4 (الجانب الأيسر)',
    labelEn: 'Car Image 4 (Left Side)',
    labelFr: 'Image Voiture 4 (Côté Gauche)',
    labelKab: 'Tawlaft n tkarrust 4 (Afus azelmaḍ)',
    icon: Icons.add_a_photo_rounded,
  );

  static const _carImg5 = QuoteDocumentSpec(
    key: 'car_img_5',
    labelAr: 'صورة السيارة 5 (الداخلية)',
    labelEn: 'Car Image 5 (Interior)',
    labelFr: 'Image Voiture 5 (Intérieur)',
    labelKab: 'Tawlaft n tkarrust 5 (Daxel)',
    icon: Icons.add_a_photo_rounded,
  );

  /// Resolve required uploads from plan code, then icon type, then category.
  static List<QuoteDocumentSpec> forPlan(PlanModel plan) {
    final code = plan.planCode.toUpperCase();

    if (['AUTO_RC', 'AUTO_TR', 'AL_RAFIK'].contains(code)) {
      return [_carteGrise, _nationalId, _drivingLicense, _carImg1, _carImg2, _carImg3, _carImg4, _carImg5];
    }
    if (['AL_SAFAR', 'TRAVEL'].contains(code)) {
      return [_nationalId, _passport, _travelBooking];
    }
    if (['AL_WAKY', 'HOME'].contains(code)) {
      return [_nationalId, _propertyDeed, _propertyPhotos];
    }
    if (['COMMERCIAL', 'MULTIRISQUE_PRO', 'AL_CHAMIL'].contains(code)) {
      return [_nationalId, _commercialRegister, _nif];
    }
    if (['RCP', 'AL_TAAZUR'].contains(code)) {
      return [_nationalId, _professionalCard, _drivingLicense];
    }
    if (['TRANSPORT_MARCHANDISES'].contains(code)) {
      return [_nationalId, _cargoInvoice, _routeDoc];
    }
    if (['AGRI_INDUS'].contains(code)) {
      return [_nationalId, _nif, _facilityPhotos];
    }

    switch (plan.iconType) {
      case 'car':
      case 'directions_car':
        return [_carteGrise, _nationalId, _drivingLicense, _carImg1, _carImg2, _carImg3, _carImg4, _carImg5];
      case 'flight':
      case 'flight_takeoff':
        return [_nationalId, _passport, _travelBooking];
      case 'home':
        return [_nationalId, _propertyDeed, _propertyPhotos];
      case 'store':
      case 'business':
      case 'business_center':
        return [_nationalId, _commercialRegister, _nif];
      case 'gavel':
        return [_nationalId, _professionalCard, _drivingLicense];
      case 'shipping':
      case 'local_shipping':
        return [_nationalId, _cargoInvoice, _routeDoc];
      case 'agriculture':
      case 'build':
        return [_nationalId, _nif, _facilityPhotos];
      default:
        return [_nationalId, _commercialRegister, _nif];
    }
  }

  /// Resolve required uploads from a PolicyModel's metadata plan_code.
  static List<QuoteDocumentSpec> forPolicy(PolicyModel policy) {
    final code = (policy.metadata?['plan_code'] as String?)?.toUpperCase() ?? '';

    if (['AUTO_RC', 'AUTO_TR', 'AL_RAFIK'].contains(code)) {
      return [_carteGrise, _nationalId, _drivingLicense, _carImg1, _carImg2, _carImg3, _carImg4, _carImg5];
    }
    if (['AL_SAFAR', 'TRAVEL'].contains(code)) {
      return [_nationalId, _passport, _travelBooking];
    }
    if (['AL_WAKY', 'HOME'].contains(code)) {
      return [_nationalId, _propertyDeed, _propertyPhotos];
    }
    if (['COMMERCIAL', 'MULTIRISQUE_PRO', 'AL_CHAMIL'].contains(code)) {
      return [_nationalId, _commercialRegister, _nif];
    }
    if (['RCP', 'AL_TAAZUR'].contains(code)) {
      return [_nationalId, _professionalCard, _drivingLicense];
    }
    if (['TRANSPORT_MARCHANDISES'].contains(code)) {
      return [_nationalId, _cargoInvoice, _routeDoc];
    }
    if (['AGRI_INDUS'].contains(code)) {
      return [_nationalId, _nif, _facilityPhotos];
    }

    // Default fallback if we can't determine it
    return [_carteGrise, _nationalId, _drivingLicense];
  }
}
