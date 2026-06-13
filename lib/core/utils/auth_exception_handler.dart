// lib/core/utils/auth_exception_handler.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthExceptionHandler {
  AuthExceptionHandler._();

  /// Returns a user-friendly message for any Exception (Auth or Postgrest)
  static String handle(Object e, String locale) {
    if (e is AuthException) {
      return translate(e, locale);
    }
    if (e is PostgrestException) {
      return "${translatePostgrest(e, locale)}\n\n[Debug: ${e.code} - ${e.message}]";
    }
    if (e is StorageException) {
      return translateCode('storage_error', locale);
    }
    // Catch generic socket / timeout / format exceptions via message
    final msg = e.toString().toLowerCase();
    if (msg.contains('socketexception') || msg.contains('handshakeexception')) {
      return translateCode('network_error', locale);
    }
    if (msg.contains('timeout')) {
      return translateCode('request_timeout', locale);
    }
    return translateCode('auth_unexpected_error', locale);
  }

  static String translate(AuthException e, String locale) {
    final code = (e.code ?? '').trim();
    final msg  = e.message.toLowerCase();

    switch (locale) {
      case 'en':  return _en(code, msg);
      case 'fr':  return _fr(code, msg);
      case 'kab': return _kab(code, msg);
      default:    return _ar(code, msg);
    }
  }

  static String translatePostgrest(PostgrestException e, String locale) {
    final code = e.code ?? '';
    final msg  = (e.message).toLowerCase();

    // ── Postgres-level error codes ───────────────────────────────────────
    // 23505 = unique_violation (duplicate key)
    if (code == '23505') {
      if (msg.contains('email')) return translateCode('auth_email_taken', locale);
      if (msg.contains('phone')) return translateCode('auth_phone_taken', locale);
      return translateCode('duplicate_record', locale);
    }
    // 23503 = foreign_key_violation
    if (code == '23503') return translateCode('reference_error', locale);
    // 42501 = insufficient_privilege
    if (code == '42501') return translateCode('permission_denied', locale);
    // 42P01 = undefined_table
    if (code == '42P01') return translateCode('system_error', locale);
    // 23514 = check_violation
    if (code == '23514') return translateCode('validation_error', locale);

    // ── PostgREST-level error codes ──────────────────────────────────────
    if (code == 'PGRST204') {
      return translateCode('system_error', locale);
    }
    if (code == 'PGRST301') {
      return translateCode('permission_denied', locale);
    }

    return translateCode('database_error', locale);
  }

  static String translateCode(String code, String locale) {
    final map = _codeTranslations[code];
    if (map == null) {
      switch (locale) {
        case 'en':  return _en(code, '');
        case 'fr':  return _fr(code, '');
        case 'kab': return _kab(code, '');
        default:    return _ar(code, '');
      }
    }
    return map[locale] ?? map['ar']!;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Static translations (used by translateCode)
  // ═══════════════════════════════════════════════════════════════════════
  static const _codeTranslations = <String, Map<String, String>>{
    // ── Generic errors ──────────────────────────────────────────────────
    'database_error': {
      'ar':  'حدث خطأ في قاعدة البيانات. تحقق من الاتصال وأعد المحاولة.',
      'en':  'A database error occurred. Check your connection and try again.',
      'fr':  'Erreur de base de données. Vérifiez votre connexion et réessayez.',
      'kab': 'Tuccḍa deg taffa n isefka. Ssenqed taneqqalt-ik syen ɛreḍ.',
    },
    'auth_unexpected_error': {
      'ar':  'حدث خطأ غير متوقع. حاول مجدداً.',
      'en':  'An unexpected error occurred. Please try again.',
      'fr':  'Une erreur inattendue s\'est produite. Veuillez réessayer.',
      'kab': 'Tella tuccḍa ur nettwali ara. Ttxil-k ɛreḍ.',
    },
    'auth_login_failed': {
      'ar':  'فشل تسجيل الدخول.',
      'en':  'Login failed.',
      'fr':  'Échec de la connexion.',
      'kab': 'Akcem yemmut.',
    },
    'auth_profile_not_found': {
      'ar':  'ملف المستخدم غير موجود.',
      'en':  'User profile not found.',
      'fr':  'Profil utilisateur introuvable.',
      'kab': 'Amaɣnu n umseqdac ur yufi ara.',
    },

    // ── Registration conflicts ──────────────────────────────────────────
    'auth_phone_taken': {
      'ar':  'رقم الهاتف هذا مسجل بالفعل لحساب آخر.',
      'en':  'This phone number is already registered to another account.',
      'fr':  'Ce numéro de téléphone est déjà enregistré pour un autre compte.',
      'kab': 'Uṭṭun n tlifun-agi yettwasejjel yakan deg umaɣnu nniḍen.',
    },
    'auth_email_taken': {
      'ar':  'البريد الإلكتروني هذا مسجل بالفعل لحساب آخر.',
      'en':  'This email address is already registered to another account.',
      'fr':  'Cette adresse e-mail est déjà enregistrée pour un autre compte.',
      'kab': 'Tansa n yimayl-agi yettwasejjel yakan deg umaɣnu nniḍen.',
    },
    'duplicate_record': {
      'ar':  'هذا السجل موجود بالفعل.',
      'en':  'This record already exists.',
      'fr':  'Cet enregistrement existe déjà.',
      'kab': 'Asekles-agi yella yakan.',
    },

    // ── Network / connectivity ──────────────────────────────────────────
    'network_error': {
      'ar':  'خطأ في الاتصال بالإنترنت. تحقق من شبكتك وحاول مجدداً.',
      'en':  'Network error. Check your internet connection and try again.',
      'fr':  'Erreur réseau. Vérifiez votre connexion internet et réessayez.',
      'kab': 'Tuccḍa n uẓeṭṭa. Ssenqed internet-ik syen ɛreḍ.',
    },
    'request_timeout': {
      'ar':  'انتهت مهلة الطلب. حاول مجدداً لاحقاً.',
      'en':  'Request timed out. Please try again later.',
      'fr':  'La requête a expiré. Veuillez réessayer plus tard.',
      'kab': 'Aṭas n wakud i tuṭṭfa. Ɛreḍ ticki.',
    },

    // ── Permission / system ─────────────────────────────────────────────
    'permission_denied': {
      'ar':  'ليس لديك صلاحية للقيام بهذا الإجراء.',
      'en':  'You do not have permission to perform this action.',
      'fr':  'Vous n\'avez pas la permission d\'effectuer cette action.',
      'kab': 'Ur tesɛiḍ ara tasiregt i tigawt-agi.',
    },
    'reference_error': {
      'ar':  'خطأ في مرجع البيانات. تأكد من صحة المعلومات المدخلة.',
      'en':  'Data reference error. Please verify the entered information.',
      'fr':  'Erreur de référence de données. Veuillez vérifier les informations saisies.',
      'kab': 'Tuccḍa deg usaɣ n isefka. Senqed talɣut yettunefken.',
    },
    'system_error': {
      'ar':  'خطأ في النظام. يرجى التواصل مع الدعم الفني.',
      'en':  'System error. Please contact technical support.',
      'fr':  'Erreur système. Veuillez contacter le support technique.',
      'kab': 'Tuccḍa n unagraw. Nermes tallelt tatiknikant.',
    },
    'validation_error': {
      'ar':  'البيانات المدخلة غير صالحة. تحقق من المعلومات وحاول مجدداً.',
      'en':  'Invalid input data. Please check your information and try again.',
      'fr':  'Données saisies invalides. Vérifiez vos informations et réessayez.',
      'kab': 'Isefka yettunefken d arameɣtu. Senqed talɣut-ik syen ɛreḍ.',
    },

    // ── Password-specific ───────────────────────────────────────────────
    'weak_password': {
      'ar':  'كلمة المرور ضعيفة جداً. استخدم 8 أحرف على الأقل مع حرف كبير ورقم.',
      'en':  'Password is too weak. Use at least 8 characters with an uppercase letter and a number.',
      'fr':  'Mot de passe trop faible. Utilisez au moins 8 caractères avec une majuscule et un chiffre.',
      'kab': 'Awal uffir d adɛif aṭas. Seqdec ma drus 8 isekkilen s yiwet n tmeqqrant d wuṭṭun.',
    },
    'same_password': {
      'ar':  'كلمة المرور الجديدة يجب أن تختلف عن القديمة.',
      'en':  'New password must be different from the old password.',
      'fr':  'Le nouveau mot de passe doit être différent de l\'ancien.',
      'kab': 'Awal uffir amaynut ilaq ad yemgarad seg uqdim.',
    },

    // ── Email-specific ──────────────────────────────────────────────────
    'email_not_confirmed': {
      'ar':  'يرجى تأكيد بريدك الإلكتروني أولاً قبل تسجيل الدخول.',
      'en':  'Please confirm your email address before signing in.',
      'fr':  'Veuillez confirmer votre adresse e-mail avant de vous connecter.',
      'kab': 'Ttxil-k sentem tansa n yimayl-ik send akcem.',
    },
    'email_address_not_authorized': {
      'ar':  'عنوان البريد الإلكتروني غير مسموح به. استخدم بريداً إلكترونياً صالحاً.',
      'en':  'This email address is not authorized. Please use a valid email.',
      'fr':  'Cette adresse e-mail n\'est pas autorisée. Utilisez un e-mail valide.',
      'kab': 'Tansa n yimayl-agi ur tettwasireg ara. Seqdec imayl ameɣtu.',
    },
    'email_exists': {
      'ar':  'هذا البريد الإلكتروني مسجل بالفعل. حاول تسجيل الدخول بدلاً من ذلك.',
      'en':  'This email is already registered. Try signing in instead.',
      'fr':  'Cet e-mail est déjà enregistré. Essayez de vous connecter.',
      'kab': 'Imayl-agi yettwasejjel yakan. Ɛreḍ akcem deg wemkan-is.',
    },

    // ── OTP / verification ──────────────────────────────────────────────
    'otp_expired': {
      'ar':  'انتهت صلاحية رمز التحقق. اطلب رمزاً جديداً.',
      'en':  'Verification code has expired. Request a new one.',
      'fr':  'Le code de vérification a expiré. Demandez un nouveau code.',
      'kab': 'Tangalt n usentem texsa. Suter yiwet tamaynut.',
    },
    'otp_disabled': {
      'ar':  'خاصية التحقق بالرمز غير مفعّلة حالياً.',
      'en':  'OTP verification is currently disabled.',
      'fr':  'La vérification par code OTP est actuellement désactivée.',
      'kab': 'Asentem s tangalt OTP yensa akka tura.',
    },

    // ── SMS ─────────────────────────────────────────────────────────────
    'sms_send_failed': {
      'ar':  'فشل إرسال الرسالة النصية. تحقق من رقم الهاتف وحاول مجدداً.',
      'en':  'Failed to send SMS. Verify your phone number and try again.',
      'fr':  'Échec de l\'envoi du SMS. Vérifiez votre numéro et réessayez.',
      'kab': 'Tuzna n SMS texser. Senqed uṭṭun-ik syen ɛreḍ.',
    },

    // ── Rate limiting ───────────────────────────────────────────────────
    'over_request_rate_limit': {
      'ar':  'لقد تجاوزت الحد المسموح. انتظر قليلاً ثم حاول مجدداً.',
      'en':  'Too many requests. Please wait a moment and try again.',
      'fr':  'Trop de requêtes. Patientez un moment et réessayez.',
      'kab': 'Aṭas n tutriwin. Rǧu ciṭuḥ syen ɛreḍ.',
    },
    'over_email_send_rate_limit': {
      'ar':  'تم إرسال عدة رسائل بريد بالفعل. انتظر بضع دقائق وحاول مجدداً.',
      'en':  'Too many emails sent. Please wait a few minutes and try again.',
      'fr':  'Trop d\'e-mails envoyés. Patientez quelques minutes et réessayez.',
      'kab': 'Aṭas n yimaylen yettwaznen. Rǧu kra n tesdatin syen ɛreḍ.',
    },
    'over_sms_send_rate_limit': {
      'ar':  'تم إرسال عدة رسائل نصية بالفعل. انتظر بضع دقائق وحاول مجدداً.',
      'en':  'Too many SMS sent. Please wait a few minutes and try again.',
      'fr':  'Trop de SMS envoyés. Patientez quelques minutes et réessayez.',
      'kab': 'Aṭas n SMS yettwaznen. Rǧu kra n tesdatin syen ɛreḍ.',
    },

    // ── Session / token ─────────────────────────────────────────────────
    'session_not_found': {
      'ar':  'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.',
      'en':  'Session expired. Please sign in again.',
      'fr':  'Session expirée. Veuillez vous reconnecter.',
      'kab': 'Tiɣimit texsa. Ttxil-k ales akcem.',
    },
    'refresh_token_not_found': {
      'ar':  'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.',
      'en':  'Session expired. Please sign in again.',
      'fr':  'Session expirée. Veuillez vous reconnecter.',
      'kab': 'Tiɣimit texsa. Ttxil-k ales akcem.',
    },
    'refresh_token_already_used': {
      'ar':  'انتهت الجلسة لأسباب أمنية. يرجى تسجيل الدخول مجدداً.',
      'en':  'Session expired for security reasons. Please sign in again.',
      'fr':  'Session expirée pour des raisons de sécurité. Reconnectez-vous.',
      'kab': 'Tiɣimit texsa i lmendad n tɣellist. Ales akcem.',
    },

    // ── User management ─────────────────────────────────────────────────
    'user_not_found': {
      'ar':  'لم يتم العثور على المستخدم.',
      'en':  'User not found.',
      'fr':  'Utilisateur introuvable.',
      'kab': 'Amseqdac ur yufi ara.',
    },
    'user_already_exists': {
      'ar':  'المستخدم مسجل بالفعل. حاول تسجيل الدخول بدلاً من ذلك.',
      'en':  'User already exists. Try signing in instead.',
      'fr':  'L\'utilisateur existe déjà. Essayez de vous connecter.',
      'kab': 'Amseqdac yella yakan. Ɛreḍ akcem deg wemkan-is.',
    },
    'user_banned': {
      'ar':  'تم حظر هذا الحساب. يرجى التواصل مع الدعم.',
      'en':  'This account has been banned. Please contact support.',
      'fr':  'Ce compte a été banni. Veuillez contacter le support.',
      'kab': 'Amiḍan-agi yettwaḥerrem. Nermes tallelt.',
    },

    // ── Signup disabled ─────────────────────────────────────────────────
    'signup_disabled': {
      'ar':  'التسجيل غير متاح حالياً. يرجى المحاولة لاحقاً.',
      'en':  'Sign-up is currently disabled. Please try later.',
      'fr':  'L\'inscription est actuellement désactivée. Réessayez plus tard.',
      'kab': 'Ajerred yensa akka tura. Ɛreḍ ticki.',
    },

    // ── Flow state / PKCE ───────────────────────────────────────────────
    'flow_state_not_found': {
      'ar':  'انتهت صلاحية عملية المصادقة. أعد المحاولة من البداية.',
      'en':  'Authentication flow expired. Please start over.',
      'fr':  'Le flux d\'authentification a expiré. Veuillez recommencer.',
      'kab': 'Taggara n usesteb texsa. Ales seg tazwara.',
    },
    'flow_state_expired': {
      'ar':  'انتهت صلاحية عملية المصادقة. أعد المحاولة من البداية.',
      'en':  'Authentication flow expired. Please start over.',
      'fr':  'Le flux d\'authentification a expiré. Veuillez recommencer.',
      'kab': 'Taggara n usesteb texsa. Ales seg tazwara.',
    },

    // ── Unexpected failure (database trigger / constraint) ───────────────
    'unexpected_failure': {
      'ar':  'حدث خطأ في النظام أثناء المعالجة. يرجى التواصل مع الدعم إذا استمرت المشكلة.',
      'en':  'A system error occurred during processing. Contact support if this persists.',
      'fr':  'Erreur système lors du traitement. Contactez le support si le problème persiste.',
      'kab': 'Tella tuccḍa n unagraw deg usesfer. Nermes tallelt ma yella yeqqim wugur.',
    },

    // ── Storage / upload ────────────────────────────────────────────────
    'storage_error': {
      'ar':  'فشل رفع الملف. تأكد من نوع الملف وحجمه وحاول مجدداً.',
      'en':  'File upload failed. Check the file type and size, then try again.',
      'fr':  'Échec du téléchargement. Vérifiez le type et la taille du fichier, puis réessayez.',
      'kab': 'Asali n ufaylu yexser. Senqed anaw d teɣzi n ufaylu syen ɛreḍ.',
    },
  };

  // ═══════════════════════════════════════════════════════════════════════
  //  Locales — Switch logic for Supabase Auth `.code` values
  // ═══════════════════════════════════════════════════════════════════════

  static String _ar(String code, String msg) {
    switch (code) {
      case 'invalid_credentials':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      case 'email_not_confirmed':
        return 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.';
      case 'user_not_found':
        return 'لم يتم العثور على المستخدم.';
      case 'user_already_exists':
        return 'المستخدم مسجل بالفعل. حاول تسجيل الدخول بدلاً من ذلك.';
      case 'user_banned':
        return 'تم حظر هذا الحساب. يرجى التواصل مع الدعم.';
      case 'weak_password':
        return 'كلمة المرور ضعيفة جداً. استخدم 8 أحرف على الأقل مع حرف كبير ورقم.';
      case 'same_password':
        return 'كلمة المرور الجديدة يجب أن تختلف عن القديمة.';
      case 'email_exists':
        return 'هذا البريد الإلكتروني مسجل بالفعل. حاول تسجيل الدخول بدلاً من ذلك.';
      case 'email_address_not_authorized':
        return 'عنوان البريد الإلكتروني غير مسموح به.';
      case 'otp_expired':
        return 'انتهت صلاحية رمز التحقق. اطلب رمزاً جديداً.';
      case 'otp_disabled':
        return 'خاصية التحقق بالرمز غير مفعّلة حالياً.';
      case 'sms_send_failed':
        return 'فشل إرسال الرسالة النصية. تحقق من رقم الهاتف.';
      case 'over_request_rate_limit':
        return 'لقد تجاوزت الحد المسموح. انتظر قليلاً ثم حاول مجدداً.';
      case 'over_email_send_rate_limit':
        return 'تم إرسال عدة رسائل بالفعل. انتظر بضع دقائق.';
      case 'over_sms_send_rate_limit':
        return 'تم إرسال عدة رسائل نصية بالفعل. انتظر بضع دقائق.';
      case 'session_not_found':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.';
      case 'signup_disabled':
        return 'التسجيل غير متاح حالياً. يرجى المحاولة لاحقاً.';
      case 'flow_state_not_found':
      case 'flow_state_expired':
        return 'انتهت صلاحية عملية المصادقة. أعد المحاولة من البداية.';
      case 'unexpected_failure':
        return 'حدث خطأ في النظام أثناء المعالجة. يرجى التواصل مع الدعم.';
      default:
        if (msg.contains('network') || msg.contains('socket')) {
          return 'خطأ في الاتصال بالإنترنت. تحقق من شبكتك وحاول مجدداً.';
        }
        if (msg.contains('timeout')) {
          return 'انتهت مهلة الطلب. حاول مجدداً لاحقاً.';
        }
        if (msg.contains('rate') || msg.contains('limit')) {
          return 'لقد تجاوزت الحد المسموح. انتظر قليلاً ثم حاول مجدداً.';
        }
        if (msg.contains('already registered') || msg.contains('already been registered')) {
          return 'هذا الحساب مسجل بالفعل. حاول تسجيل الدخول بدلاً من ذلك.';
        }
        if (msg.contains('password') && msg.contains('weak')) {
          return 'كلمة المرور ضعيفة جداً. استخدم 8 أحرف على الأقل مع حرف كبير ورقم.';
        }
        return 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }

  static String _en(String code, String msg) {
    switch (code) {
      case 'invalid_credentials':
        return 'Incorrect email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email before signing in.';
      case 'user_not_found':
        return 'User not found.';
      case 'user_already_exists':
        return 'User already exists. Try signing in instead.';
      case 'user_banned':
        return 'This account has been banned. Please contact support.';
      case 'weak_password':
        return 'Password is too weak. Use at least 8 characters with an uppercase letter and a number.';
      case 'same_password':
        return 'New password must be different from the old password.';
      case 'email_exists':
        return 'This email is already registered. Try signing in instead.';
      case 'email_address_not_authorized':
        return 'This email address is not authorized.';
      case 'otp_expired':
        return 'Verification code has expired. Request a new one.';
      case 'otp_disabled':
        return 'OTP verification is currently disabled.';
      case 'sms_send_failed':
        return 'Failed to send SMS. Verify your phone number and try again.';
      case 'over_request_rate_limit':
        return 'Too many requests. Please wait a moment and try again.';
      case 'over_email_send_rate_limit':
        return 'Too many emails sent. Please wait a few minutes and try again.';
      case 'over_sms_send_rate_limit':
        return 'Too many SMS sent. Please wait a few minutes and try again.';
      case 'session_not_found':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return 'Session expired. Please sign in again.';
      case 'signup_disabled':
        return 'Sign-up is currently disabled. Please try later.';
      case 'flow_state_not_found':
      case 'flow_state_expired':
        return 'Authentication flow expired. Please start over.';
      case 'unexpected_failure':
        return 'A system error occurred. Contact support if this persists.';
      default:
        if (msg.contains('network') || msg.contains('socket')) {
          return 'Network error. Check your internet connection and try again.';
        }
        if (msg.contains('timeout')) {
          return 'Request timed out. Please try again later.';
        }
        if (msg.contains('rate') || msg.contains('limit')) {
          return 'Too many requests. Please wait a moment and try again.';
        }
        if (msg.contains('already registered') || msg.contains('already been registered')) {
          return 'This account is already registered. Try signing in instead.';
        }
        if (msg.contains('password') && msg.contains('weak')) {
          return 'Password is too weak. Use at least 8 characters with an uppercase letter and a number.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _fr(String code, String msg) {
    switch (code) {
      case 'invalid_credentials':
        return 'E-mail ou mot de passe incorrect.';
      case 'email_not_confirmed':
        return 'Veuillez confirmer votre e-mail avant de vous connecter.';
      case 'user_not_found':
        return 'Utilisateur introuvable.';
      case 'user_already_exists':
        return 'L\'utilisateur existe déjà. Essayez de vous connecter.';
      case 'user_banned':
        return 'Ce compte a été banni. Veuillez contacter le support.';
      case 'weak_password':
        return 'Mot de passe trop faible. Utilisez au moins 8 caractères avec une majuscule et un chiffre.';
      case 'same_password':
        return 'Le nouveau mot de passe doit être différent de l\'ancien.';
      case 'email_exists':
        return 'Cet e-mail est déjà enregistré. Essayez de vous connecter.';
      case 'email_address_not_authorized':
        return 'Cette adresse e-mail n\'est pas autorisée.';
      case 'otp_expired':
        return 'Le code de vérification a expiré. Demandez un nouveau code.';
      case 'otp_disabled':
        return 'La vérification OTP est actuellement désactivée.';
      case 'sms_send_failed':
        return 'Échec de l\'envoi du SMS. Vérifiez votre numéro et réessayez.';
      case 'over_request_rate_limit':
        return 'Trop de requêtes. Patientez un moment et réessayez.';
      case 'over_email_send_rate_limit':
        return 'Trop d\'e-mails envoyés. Patientez quelques minutes.';
      case 'over_sms_send_rate_limit':
        return 'Trop de SMS envoyés. Patientez quelques minutes.';
      case 'session_not_found':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return 'Session expirée. Veuillez vous reconnecter.';
      case 'signup_disabled':
        return 'L\'inscription est actuellement désactivée. Réessayez plus tard.';
      case 'flow_state_not_found':
      case 'flow_state_expired':
        return 'Le flux d\'authentification a expiré. Veuillez recommencer.';
      case 'unexpected_failure':
        return 'Erreur système. Contactez le support si le problème persiste.';
      default:
        if (msg.contains('network') || msg.contains('socket')) {
          return 'Erreur réseau. Vérifiez votre connexion internet et réessayez.';
        }
        if (msg.contains('timeout')) {
          return 'La requête a expiré. Veuillez réessayer plus tard.';
        }
        if (msg.contains('rate') || msg.contains('limit')) {
          return 'Trop de requêtes. Patientez un moment et réessayez.';
        }
        if (msg.contains('already registered') || msg.contains('already been registered')) {
          return 'Ce compte est déjà enregistré. Essayez de vous connecter.';
        }
        if (msg.contains('password') && msg.contains('weak')) {
          return 'Mot de passe trop faible. Utilisez au moins 8 caractères avec une majuscule et un chiffre.';
        }
        return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    }
  }

  static String _kab(String code, String msg) {
    switch (code) {
      case 'invalid_credentials':
        return 'Imayl neɣ awal uffir mačči d iswi.';
      case 'email_not_confirmed':
        return 'Ttxil-k sentem tansa n yimayl-ik send akcem.';
      case 'user_not_found':
        return 'Amseqdac ur yufi ara.';
      case 'user_already_exists':
        return 'Amseqdac yella yakan. Ɛreḍ akcem deg wemkan-is.';
      case 'user_banned':
        return 'Amiḍan-agi yettwaḥerrem. Nermes tallelt.';
      case 'weak_password':
        return 'Awal uffir d adɛif aṭas. Seqdec ma drus 8 isekkilen.';
      case 'same_password':
        return 'Awal uffir amaynut ilaq ad yemgarad seg uqdim.';
      case 'email_exists':
        return 'Imayl-agi yettwasejjel yakan. Ɛreḍ akcem.';
      case 'email_address_not_authorized':
        return 'Tansa n yimayl-agi ur tettwasireg ara.';
      case 'otp_expired':
        return 'Tangalt n usentem texsa. Suter yiwet tamaynut.';
      case 'otp_disabled':
        return 'Asentem s tangalt OTP yensa akka tura.';
      case 'sms_send_failed':
        return 'Tuzna n SMS texser. Senqed uṭṭun-ik syen ɛreḍ.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return 'Aṭas n tutriwin. Rǧu ciṭuḥ syen ɛreḍ.';
      case 'session_not_found':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return 'Tiɣimit texsa. Ttxil-k ales akcem.';
      case 'signup_disabled':
        return 'Ajerred yensa akka tura. Ɛreḍ ticki.';
      case 'flow_state_not_found':
      case 'flow_state_expired':
        return 'Taggara n usesteb texsa. Ales seg tazwara.';
      case 'unexpected_failure':
        return 'Tuccḍa n unagraw. Nermes tallelt ma yella yeqqim wugur.';
      default:
        if (msg.contains('network') || msg.contains('socket')) {
          return 'Tuccḍa n uẓeṭṭa. Ssenqed internet-ik syen ɛreḍ.';
        }
        if (msg.contains('timeout')) {
          return 'Aṭas n wakud i tuṭṭfa. Ɛreḍ ticki.';
        }
        if (msg.contains('rate') || msg.contains('limit')) {
          return 'Aṭas n tutriwin. Rǧu ciṭuḥ syen ɛreḍ.';
        }
        if (msg.contains('already registered') || msg.contains('already been registered')) {
          return 'Amiḍan-agi yettwasejjel yakan. Ɛreḍ akcem.';
        }
        if (msg.contains('password') && msg.contains('weak')) {
          return 'Awal uffir d adɛif aṭas. Seqdec ma drus 8 isekkilen.';
        }
        return 'Tella tuccḍa ur nettwali ara. Ttxil-k ɛreḍ.';
    }
  }
}
