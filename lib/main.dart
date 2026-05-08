import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/service_providers.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SupabaseConstants.assertConfigured();
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  // Initialize Notifications
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();

  debugPrint('DEBUG: Calling runApp...');
  runApp(UncontrolledProviderScope(
    container: container,
    child: const TaminyEliteApp(),
  ));
}

class TaminyEliteApp extends ConsumerWidget {
  const TaminyEliteApp({super.key});

  static const _supportedLocales = [
    Locale('ar'),
    Locale('fr'),
    Locale('en'),
    Locale('kab'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    // FIX: watch localeProvider so the whole widget tree rebuilds on language change
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Taminy Elite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      supportedLocales: _supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        KabMaterialLocalizationsDelegate(),
        KabCupertinoLocalizationsDelegate(),
        KabWidgetsLocalizationsDelegate(),
      ],
      // FIX: explicit locale assignment + resolution callback
      // Without locale: here, MaterialApp.router ignores the watched value.
      locale: locale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // If the user has explicitly chosen a language, always use it.
        // localeProvider defaults to 'ar' on first launch.
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

class KabMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const KabMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kab';
  @override
  Future<MaterialLocalizations> load(Locale locale) => GlobalMaterialLocalizations.delegate.load(const Locale('fr'));
  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class KabCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const KabCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kab';
  @override
  Future<CupertinoLocalizations> load(Locale locale) => GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));
  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}

class KabWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const KabWidgetsLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kab';
  @override
  Future<WidgetsLocalizations> load(Locale locale) => GlobalWidgetsLocalizations.delegate.load(const Locale('fr'));
  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) => false;
}
