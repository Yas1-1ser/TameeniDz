import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class for creating in-app notification records in the `notifications` table.
///
/// Notification types:
/// - `new_registration` – Admin is notified when a new client registers
/// - `new_request`      – Operator is notified when a client submits a quote
/// - `request_accepted` – Client is notified when their request is accepted
/// - `request_rejected` – Client is notified when their request is rejected
/// - `request_modified` – Client is notified when modification is requested
/// - `policy_expiry`    – Client is notified 15 days before policy expiry
/// - `general`          – General notification
class NotificationHelper {
  NotificationHelper._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Insert a notification record into the `notifications` table.
  ///
  /// Uses the service_role key (via privilegedClient) so that RLS INSERT
  /// policies don't block system-generated notifications.
  static Future<void> _insert({
    required String userId,
    required String title,
    required String body,
    required String type,
    String senderRole = 'system',
    String recipientRole = 'client',
    String? referenceId,
    SupabaseClient? privilegedClient,
  }) async {
    try {
      final client = privilegedClient ?? _client;
      await client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'sender_role': senderRole,
        'recipient_role': recipientRole,
        if (referenceId != null) 'reference_id': referenceId,
      });
    } catch (e) {
      // Never let notification failures crash the main flow
      if (kDebugMode) print('NotificationHelper error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 1. NEW CLIENT REGISTRATION → Notify all admin users
  // ─────────────────────────────────────────────────────────────

  /// Notify admin users that a new client has registered.
  static Future<void> notifyAdminNewRegistration({
    required String clientName,
    required String clientEmail,
    SupabaseClient? privilegedClient,
  }) async {
    try {
      final client = privilegedClient ?? _client;

      // Fetch all admin user IDs
      final admins = await client
          .from('users')
          .select('id')
          .eq('role', 'admin');

      for (final admin in admins) {
        await _insert(
          userId: admin['id'] as String,
          title: 'عميل جديد مسجل',
          body: 'قام العميل "$clientName" ($clientEmail) بالتسجيل في المنصة.',
          type: 'new_registration',
          senderRole: 'system',
          recipientRole: 'admin',
          privilegedClient: client,
        );
      }
    } catch (e) {
      if (kDebugMode) print('NotificationHelper.notifyAdminNewRegistration error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 2. NEW QUOTE REQUEST → Notify operator accounts
  // ─────────────────────────────────────────────────────────────

  /// Notify operator users that a new quote, insurance, or claim request was submitted.
  ///
  /// [operatorId] is the operator code like `algeria_takaful` or `al_ittihad`.
  static Future<void> notifyOperatorNewRequest({
    required String operatorId,
    required String clientName,
    required String planName,
    String? policyId,
    String requestType = 'quote', // 'quote', 'insurance', 'claim'
    SupabaseClient? privilegedClient,
  }) async {
    try {
      final client = privilegedClient ?? _client;

      // Map operator_id to company field in users table
      final companyFilter = operatorId;

      // Fetch all operator users for this company
      final operators = await client
          .from('users')
          .select('id')
          .eq('role', 'operator')
          .eq('company', companyFilter);

      final operatorLabel = operatorId == 'algeria_takaful'
          ? 'جزائر تكافل'
          : (operatorId == 'al_ittihad' ? 'الاتحاد للتأمين' : operatorId);

      String title = 'طلب تسعيرة جديد';
      String body = 'قام العميل "$clientName" بتقديم طلب تسعيرة لخطة "$planName" في $operatorLabel.';
      
      if (requestType == 'insurance') {
        title = 'طلب تأمين جديد';
        body = 'قام العميل "$clientName" بتقديم طلب تأمين لخطة "$planName" في $operatorLabel.';
      } else if (requestType == 'claim') {
        title = 'طلب تعويض جديد';
        body = 'قام العميل "$clientName" بتقديم طلب تعويض للبوليصة "$planName" في $operatorLabel.';
      }

      for (final op in operators) {
        await _insert(
          userId: op['id'] as String,
          title: title,
          body: body,
          type: 'new_request',
          senderRole: 'client',
          recipientRole: 'operator',
          referenceId: policyId,
          privilegedClient: client,
        );
      }
    } catch (e) {
      if (kDebugMode) print('NotificationHelper.notifyOperatorNewRequest error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 3. REQUEST STATUS CHANGE → Notify the client
  // ─────────────────────────────────────────────────────────────

  /// Notify a client that their policy request status has changed.
  static Future<void> notifyClientStatusChange({
    required String clientId,
    required String status,
    String? policyId,
    String? planName,
    SupabaseClient? privilegedClient,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'accepted':
        title = 'تم قبول طلبك';
        body = 'تمت الموافقة على طلب التأمين الخاص بك${planName != null ? ' لخطة "$planName"' : ''}. يمكنك الآن متابعة عملية الدفع.';
        break;
      case 'rejected':
        title = 'تم رفض طلبك';
        body = 'للأسف، تم رفض طلب التأمين الخاص بك${planName != null ? ' لخطة "$planName"' : ''}. يرجى التواصل مع الدعم لمزيد من المعلومات.';
        break;
      case 'modificationRequested':
        title = 'مطلوب تعديل على طلبك';
        body = 'يرجى مراجعة طلب التأمين الخاص بك${planName != null ? ' لخطة "$planName"' : ''} وتعديل المعلومات المطلوبة.';
        break;
      case 'paid':
        title = 'تم تأكيد الدفع';
        body = 'تم تأكيد دفع بوليصة التأمين الخاصة بك${planName != null ? ' لخطة "$planName"' : ''} بنجاح.';
        break;
      default:
        title = 'تحديث حالة الطلب';
        body = 'تم تحديث حالة طلب التأمين الخاص بك إلى: $status';
    }

    await _insert(
      userId: clientId,
      title: title,
      body: body,
      type: 'request_$status',
      senderRole: 'operator',
      recipientRole: 'client',
      referenceId: policyId,
      privilegedClient: privilegedClient,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. POLICY EXPIRY WARNING → Notify the client
  // ─────────────────────────────────────────────────────────────

  /// Notify a client that their policy is about to expire.
  static Future<void> notifyClientPolicyExpiry({
    required String clientId,
    required String planName,
    required int daysLeft,
    String? policyId,
    SupabaseClient? privilegedClient,
  }) async {
    await _insert(
      userId: clientId,
      title: 'تنبيه: اقتراب انتهاء التأمين',
      body: 'بوليصة التأمين "$planName" ستنتهي خلال $daysLeft يوم. يرجى التجديد لتجنب انقطاع التغطية.',
      type: 'policy_expiry',
      senderRole: 'system',
      recipientRole: 'client',
      referenceId: policyId,
      privilegedClient: privilegedClient,
    );
  }
}
