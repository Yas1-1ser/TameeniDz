# Supabase Integration Audit Report (Local + MCP status)

## MCP Connectivity
- list_mcp_resources: empty
- list_mcp_resource_templates: empty
- list_mcp_resources(server: supabase): unknown MCP server `supabase`
- .mcp.json contains https://mcp.supabase.com/mcp, but no active MCP server is available in this session.

## Supabase Calls Inventory (Auth + Table)
| File | Line | Supabase Call | Target Exists | Status |
|---|---:|---|---|---|
| D:\tameenidz\lib\core\providers\service_providers.dart | 29 | final userId = client.auth.currentUser?.id; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\providers\service_providers.dart | 36 | final userId = client.auth.currentUser?.id; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\providers\service_providers.dart | 40 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\auth_service.dart | 38 | final session = Supabase.instance.client.auth.currentSession; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\auth_service.dart | 49 | _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\auth_service.dart | 81 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\auth_service.dart | 109 | final auth = await Supabase.instance.client.auth.signInWithPassword( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\auth_service.dart | 119 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\auth_service.dart | 125 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\auth_service.dart | 133 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\auth_service.dart | 166 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\notification_service.dart | 108 | final user = _supabase.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\notification_service.dart | 114 | await _supabase.from('users').update({'fcm_token': token}).eq('id', user.id); | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\session_guard.dart | 30 | final user = supabase.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\session_guard.dart | 36 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 29 | final userId = _client.auth.currentUser?.id; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 31 | await _client.from('users').upsert({ | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 39 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 49 | await _client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 52 | User? get currentUser => _client.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 67 | await _client.from('policies').insert({ | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 84 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 96 | .from('plans') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 110 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\core\services\supabase_service.dart | 118 | .from('audit_logs') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\core\services\user_profile_service.dart | 17 | await _client.from('users').upsert({ | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\user_profile_service.dart | 41 | await _client.from('users').upsert({ | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\user_profile_service.dart | 62 | await _client.from('users').upsert({ | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\user_profile_service.dart | 78 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\core\services\user_profile_service.dart | 92 | await _client.from('users').select().eq('id', userId).maybeSingle(); | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\admin\auth\admin_login_screen.dart | 356 | final res = await Supabase.instance.client.auth.signInWithPassword( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\admin\auth\admin_login_screen.dart | 369 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\admin\auth\admin_login_screen.dart | 375 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\admin\auth\admin_login_screen.dart | 588 | await Supabase.instance.client.auth.verifyOTP( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\admin\auth\admin_login_screen.dart | 613 | await Supabase.instance.client.auth.resend( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\admin\settings\admin_settings_screen.dart | 92 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\admin\settings\admin_settings_screen.dart | 128 | final email = Supabase.instance.client.auth.currentUser?.email ?? ''; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\admin\wallet\wallet_screen.dart | 63 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\al_ittihad\auth\ai_login_screen.dart | 41 | final res = await Supabase.instance.client.auth.signInWithPassword( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\al_ittihad\auth\ai_login_screen.dart | 53 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\al_ittihad\auth\ai_login_screen.dart | 61 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\algeria_takaful\auth\at_login_screen.dart | 39 | final res = await Supabase.instance.client.auth.signInWithPassword( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\algeria_takaful\auth\at_login_screen.dart | 51 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\algeria_takaful\auth\at_login_screen.dart | 59 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\client_login_screen.dart | 51 | final response = await supabase.auth.signInWithPassword( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\otp\otp_verification_screen.dart | 119 | await Supabase.instance.client.auth.verifyOTP( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\otp\otp_verification_screen.dart | 163 | await Supabase.instance.client.auth.signInWithOtp( | YES (valid Supabase auth member) | WARN (requires Phone provider + SMS provider config) |
| D:\tameenidz\lib\features\client\auth\phone_login_screen.dart | 83 | await Supabase.instance.client.auth.signInWithOtp(phone: _formattedPhone); | YES (valid Supabase auth member) | WARN (requires Phone provider + SMS provider config) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step1_personal_info.dart | 122 | await client.auth.signInWithOtp(phone: phone); | YES (valid Supabase auth member) | WARN (requires Phone provider + SMS provider config) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step2_password_setup.dart | 72 | final otpSessionUser = client.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step2_password_setup.dart | 78 | final updated = await client.auth.updateUser( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step2_password_setup.dart | 93 | final response = await client.auth.signUp( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step2_password_setup.dart | 111 | final hasSession = client.auth.currentSession != null; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step2_password_setup.dart | 130 | await client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step3_document_upload.dart | 78 | final userId = client.auth.currentUser?.id; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step3_document_upload.dart | 95 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\auth\registration\steps\step3_document_upload.dart | 108 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\auth\reset_password_screen.dart | 45 | await Supabase.instance.client.auth.updateUser( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\home\client_dashboard_screen.dart | 290 | final authUser = Supabase.instance.client.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\onboarding\app_boot_screen.dart | 72 | _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) { | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\onboarding\app_boot_screen.dart | 83 | final session = Supabase.instance.client.auth.currentSession; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\onboarding\splash_screen.dart | 197 | final session = Supabase.instance.client.auth.currentSession; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 228 | final authUser = ref.read(supabaseProvider).auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 252 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 262 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 269 | receiptUrl = client.storage.from('documents').getPublicUrl(storagePath); | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 276 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 294 | .from('plans') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 305 | await client.from('policies').insert({ | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\client\payment\payment_screen.dart | 316 | await client.from('policies').insert({ | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\client\policies\policy_document_upload_screen.dart | 83 | final userId = client.auth.currentUser?.id; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\policies\policy_document_upload_screen.dart | 103 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\policies\policy_document_upload_screen.dart | 116 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\policies\policy_document_upload_screen.dart | 128 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\client\policies\policy_document_upload_screen.dart | 143 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\client\policies\policy_providers.dart | 7 | final userId = supabase.auth.currentUser?.id; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\policies\policy_providers.dart | 12 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\client\roadside\roadside_assistance_screen.dart | 55 | .from('tow_trucks') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\client\roadside\roadside_assistance_screen.dart | 344 | .from('garages') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\client\settings\client_settings_screen.dart | 21 | final user = Supabase.instance.client.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\client\settings\client_settings_screen.dart | 244 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\operator\auth\operator_register_screen.dart | 80 | final response = await client.auth.signUp( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\operator\dashboard\operator_dashboard_screen.dart | 165 | final authUser = Supabase.instance.client.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\operator\operator_settings_screen.dart | 108 | await Supabase.instance.client.auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\operator\operator_settings_screen.dart | 144 | final email = Supabase.instance.client.auth.currentUser?.email ?? ''; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\features\shared\data\audit_repository.dart | 18 | .from('audit_logs') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\legal_repository.dart | 18 | .from('legal_sections') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\legal_repository.dart | 28 | .from('documents') | YES (storage bucket in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\offer_repository.dart | 13 | .from('plans') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\offer_repository.dart | 21 | await _client.from('plans').insert(data); | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\offer_repository.dart | 29 | await _client.from('plans').update(data).eq('id', id); | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\offer_repository.dart | 37 | await _client.from('plans').delete().eq('id', id); | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\plan_repository.dart | 24 | .from('plans') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\plan_repository.dart | 34 | .from('plans') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\plan_repository.dart | 47 | .from('plans') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 19 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 29 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 40 | await _client.from('policies').select().eq('id', id).maybeSingle(); | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 49 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 78 | await _client.from('policies').update(updateData).eq('id', id); | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 86 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 94 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 101 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\policy_repository.dart | 110 | await _client.from('policies').insert(policyData).select().single(); | YES (public.policies in migrations) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\surplus_repository.dart | 18 | .from('surplus_distributions') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\surplus_repository.dart | 26 | .from('surplus_quarters') | UNKNOWN (MCP/live DB required) | WARN (reviewed in code, live verify needed) |
| D:\tameenidz\lib\features\shared\data\user_repository.dart | 18 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\user_repository.dart | 26 | await _client.from('users').insert(user.toJson()); | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\user_repository.dart | 34 | await _client.from('users').update(user.toJson()).eq('id', user.id); | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\data\user_repository.dart | 42 | await _client.from('users').delete().eq('id', id); | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\features\shared\widgets\app_sidebar.dart | 254 | await ref.read(supabaseClientProvider).auth.signOut(); | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\shared\widgets\email_verification_modal.dart | 158 | final user = supabase.auth.currentUser; | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\shared\widgets\email_verification_modal.dart | 161 | await supabase.auth.verifyOTP( | YES (valid Supabase auth member) | OK (code path audited) |
| D:\tameenidz\lib\shared\widgets\email_verification_modal.dart | 168 | .from('users') | YES (public.users in migration) | OK (verified locally) |
| D:\tameenidz\lib\widgets\admin\sales_table_widget.dart | 55 | .from('policies') | YES (public.policies in migrations) | OK (verified locally) |

## Local Migration Snapshot
- public.users is defined with RLS policies.
- public.policies is altered/enhanced with RLS policies.
- storage bucket documents exists and is private with per-user policies.
- Realtime publication logic exists for public.policies.

## Manual Actions Required
- Reconnect Supabase MCP server in this environment, then re-run live inspection.
- Apply migration supabase/migrations/20260515123000_harden_policies_and_storage.sql.
- Verify Auth providers/settings in Supabase dashboard (email/phone/SMS provider, OTP expiry, redirect URLs).
- Verify existence + RLS for non-local-schema tables: plans, audit_logs, legal_sections, surplus_distributions, surplus_quarters, tow_trucks, garages.
