import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://zqihvfzxgrfsgbfziwly.supabase.co',
    'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW',
  );

  print('Deleting old plans...');
  await supabase.from('plans').delete().neq('id', '00000000-0000-0000-0000-000000000000');

  final plans = [
    {
      'operator_id': 'algeria_takaful',
      'name_ar': 'الجزائر تكافل',
      'name_en': 'Algerie Takaful',
      'plan_code': 'تأمين السفر (تكافل)',
      'category_ar': 'تأمين السفر',
      'premium_amount': 2500,
      'coverage_details': 'تغطية السفر والمساعدة في الخارج',
      'tabarru_rate': 0.1,
      'surplus_rate': 0.05,
      'claims_duration': '24 ساعة',
      'icon_type': 'flight',
      'is_best_value': true,
      'description_ar': 'تأمين سفر يغطي التكاليف الطبية والمساعدة.',
    },
    {
      'operator_id': 'algeria_takaful',
      'name_ar': 'الجزائر تكافل',
      'name_en': 'Algerie Takaful',
      'plan_code': 'تأمين الكوارث (تكافل)',
      'category_ar': 'تأمين الكوارث',
      'premium_amount': 8000,
      'coverage_details': 'تغطية شاملة للكوارث الطبيعية',
      'tabarru_rate': 0.15,
      'surplus_rate': 0.05,
      'claims_duration': '48 ساعة',
      'icon_type': 'home',
      'is_best_value': false,
      'description_ar': 'يغطي الأضرار الناجمة عن الزلازل والفيضانات وغيرها.',
    },
    {
      'operator_id': 'algeria_takaful',
      'name_ar': 'الجزائر تكافل',
      'name_en': 'Algerie Takaful',
      'plan_code': 'تأمين الحياة (تكافل)',
      'category_ar': 'تأمين الحياة',
      'premium_amount': 15000,
      'coverage_details': 'تأمين على الحياة التكافلي',
      'tabarru_rate': 0.2,
      'surplus_rate': 0.05,
      'claims_duration': '15 يوم',
      'icon_type': 'business_center',
      'is_best_value': false,
      'description_ar': 'تغطية تكافلية شاملة للحياة.',
    },
    {
      'operator_id': 'algeria_takaful',
      'name_ar': 'الجزائر تكافل',
      'name_en': 'Algerie Takaful',
      'plan_code': 'تأمين الشامل (تكافل)',
      'category_ar': 'تأمين الشامل',
      'premium_amount': 35000,
      'coverage_details': 'تغطية شاملة لكل الأخطار',
      'tabarru_rate': 0.15,
      'surplus_rate': 0.05,
      'claims_duration': '3 أيام',
      'icon_type': 'car',
      'is_best_value': true,
      'description_ar': 'تأمين شامل يغطي جميع الأضرار.',
    },
    {
      'operator_id': 'algeria_takaful',
      'name_ar': 'الجزائر تكافل',
      'name_en': 'Algerie Takaful',
      'plan_code': 'التأمين الجزئي (تكافل)',
      'category_ar': 'التأمين الجزئي',
      'premium_amount': 12000,
      'coverage_details': 'تغطية جزئية أساسية',
      'tabarru_rate': 0.1,
      'surplus_rate': 0.05,
      'claims_duration': '3 أيام',
      'icon_type': 'directions_car',
      'is_best_value': false,
      'description_ar': 'تأمين جزئي يغطي الأضرار الأساسية.',
    },
  ];

  final ittihadPlans = plans.map((p) => {
    ...p,
    'operator_id': 'al_ittihad',
    'name_ar': 'الجزائر المتحدة',
    'name_en': 'Algerie Ittihad',
    'plan_code': (p['plan_code'] as String).replaceAll('(تكافل)', '(المتحدة)'),
  }).toList();

  print('Inserting new plans...');
  await supabase.from('plans').insert([...plans, ...ittihadPlans]);
  
  print('Done!');
}
