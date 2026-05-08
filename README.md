# Taminy Elite - Digital Islamic Takaful Platform

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Flutter-blue?style=flat&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/License-Professional-green" alt="License">
  <img src="https://img.shields.io/badge/Status-Active-brightgreen" alt="Status">
</p>

## Overview

Taminy Elite is a comprehensive digital Islamic Takaful (insurance) platform built with Flutter. It implements Decree 21-81 compliance for Islamic insurance operations in Algeria, featuring multi-portal architecture for clients, insurance operators (Algeria Takaful, Al-Ittihad), and master administrators.

## Features

### 🔐 Multi-Portal Architecture

| Portal              | Purpose                    | Authentication          |
| ------------------- | -------------------------- | ----------------------- |
| **Client**          | Policyholders, subscribers | OTP-based registration  |
| **Algeria Takaful** | Employee dashboard         | Company credentials     |
| **Al-Ittihad**      | Employee dashboard         | Company credentials     |
| **Master Admin**    | System administration      | 3-factor authentication |

### 📋 Key Functionality

- **Policy Management**: Full lifecycle management with Decree 21-81 workflow
- **Fund Separation**: Visual distinction between Subscriber Fund and Shareholder Fund
- **Hard-Lock Payment**: Payment button disabled until final policy acceptance (Decree 21-81 compliance)
- **Renewal Alerts**: 30-day, 7-day, and 24-hour renewal notifications
- **Document Management**: Upload and verification of policy documents
- **Audit Trail**: Immutable timestamp logging for compliance
- **Commission Tracking**: 4% commission monitoring for agents
- **Surplus Distribution**: Transparent surplus distribution logs
- **Realtime Integration**: Seamless Supabase Realtime integration with automatic exponential backoff reconnections and live status badges.
- **Dynamic Theming**: Full dark mode and dynamic theme extension support providing premium UI aesthetics.

### 🌍 Internationalization

Fully localized across 4 languages to serve diverse demographics:
- Arabic (العربية) - Primary (RTL Support)
- French (Français)
- English
- Tamazight (ⵝⴰⵡⵉⵍⵉⵖⵟ / Kabyle)

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/                   # App constants
│   │   ├── app_colors.dart         # Brand colors
│   │   ├── app_strings.dart     # String constants
│   │   └── supabase_constants.dart
│   ├── theme/                      # App theming
│   │   └── app_theme.dart
│   └── router/                    # Navigation
│       └── app_router.dart
├── shared/
│   ├── enums/                    # Shared enums
│   │   └── policy_status.dart
│   └── widgets/                  # Reusable widgets
│       ├── status_badge.dart
│       ├── hard_lock_payment_button.dart
│       ├── immutable_timestamp.dart
│       ├── renewal_alert_banner.dart
│       └── document_upload_card.dart
└── features/
    ├── client/                   # Client portal
    │   ├── onboarding/
    │   ├── auth/
    │   ├── home/
    │   ├── plans/
    │   ├── payment/
    │   └── legal_hub/
    ├── algeria_takaful/          # Algeria Takaful portal
    │   ├── auth/
    │   ├── dashboard/
    │   ├── applications/
    │   └── surplus/
    ├── al_ittihad/              # Al-Ittihad portal
    │   ├── auth/
    │   ├── dashboard/
    │   ├── applications/
    │   └── surplus/
    └── admin/                   # Master Admin portal
        ├── auth/
        ├── dashboard/
        ├── commission/
        ├── audit_trail/
        └── user_management/
```

## Getting Started

### Prerequisites

- Flutter SDK 3.7.0+
- Dart SDK 3.7.0+
- Supabase project
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd tameenidz
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   Update `lib/core/constants/supabase_constants.dart`:

   ```dart
   class SupabaseConstants {
     static const String url = 'YOUR_SUPABASE_URL';
     static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

4. **Add fonts**

   Download the Cairo font and place in `assets/fonts/`:
   - Cairo-Regular.ttf
   - Cairo-Bold.ttf

5. **Run the app**
   ```bash
   flutter run
   ```

## Decrees & Compliance

### Decree 21-81 Implementation

This platform implements key requirements from Algerian Insurance Decree 21-81:

1. **Hard-Lock Payment**: The payment button (`HardLockPaymentButton`) remains disabled until an insurance representative formally accepts the policy application. This prevents premature payment collection.

2. **Fund Separation**: Visual indicators show:
   - `subscriberFund` (teal): Represents participant contributions
   - `shareholderFund` (green): Represents company capital

3. **Immutable Audit Trail**: All critical actions are timestamped with `ImmutableTimestamp` widget, ensuring tamper-proof logging.

4. **Status Workflow**: Policy applications progress through:
   - Pending (قيد المراجعة)
   - Accepted (مقبول) - Unlocks payment
   - Rejected (مرفوض)
   - Modification Requested (يحتاج تعديل)

### Renewal Alerts

The system provides proactive renewal notifications:

- 30 days before expiry (amber)
- 7 days before expiry (orange)
- 24 hours before expiry (red)

## Dependencies

Main packages in `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0 # Backend
  go_router: ^13.2.0 # Navigation
  flutter_riverpod: ^2.5.1 # State management
  file_picker: ^8.0.3 # Document upload
  image_picker: ^1.1.2 # Image handling
  intl: ^0.19.0 # i18n
  shared_preferences: ^2.2.3 # Local storage
```

## Screen Reference

| Route                 | Screen           | Description          |
| --------------------- | ---------------- | -------------------- |
| `/`                   | Splash           | Onboarding splash    |
| `/register/step1`     | Personal Info    | Registration step 1  |
| `/register/otp`       | OTP Verification | Phone verification   |
| `/register/step3`     | Document Upload  | ID & documents       |
| `/client/home`        | Client Dashboard | Policy overview      |
| `/client/plans`       | Plan Comparison  | Plan selection       |
| `/client/payment`     | Payment          | Hard-locked payment  |
| `/client/legal`       | Legal Hub        | Decree documentation |
| `/at/login`           | AT Login         | Algeria Takaful      |
| `/at/dashboard`       | AT Dashboard     | Employee view        |
| `/at/application/:id` | AT Application   | Review & decide      |
| `/at/surplus`         | AT Surplus       | Distribution log     |
| `/ai/login`           | AI Login         | Al-Ittihad           |
| `/ai/dashboard`       | AI Dashboard     | Employee view        |
| `/ai/application/:id` | AI Application   | Review & decide      |
| `/ai/surplus`         | AI Surplus       | Distribution log     |
| `/admin/login`        | Admin Login      | 3-factor auth        |
| `/admin/dashboard`    | Admin Dashboard  | Overview             |
| `/admin/commission`   | Commission       | 4% monitoring        |
| `/admin/audit`        | Audit Trail      | Immutable log        |
| `/admin/users`        | User Management  | User CRUD            |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Flutter best practices
4. Run analysis: `flutter analyze`
5. Submit a pull request

## Next Steps

After initial setup:

1. **Backend Setup**: Configure Supabase tables for users, policies, applications
2. **Implement Logic**: Connect screen stubs to real backend APIs
3. **UI/UX**: Enhance screens from stub implementations
4. **Testing**: Add unit and widget tests
5. **Deployment**: Build for production

## License

Professional License - All Rights Reserved

## Support

For questions or support, please contact the development team.

---

<p align="center">Taminy Elite - Digital Islamic Takaful Platform</p>
