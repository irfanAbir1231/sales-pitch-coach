import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'ai/ai_service.dart';
import 'data/product_repository.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_shell.dart';
import 'services/history_store.dart';
import 'services/locale_store.dart';
import 'services/profile_store.dart';
import 'services/settings_store.dart';
import 'services/tts_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = ProductRepository();
  final settings = SettingsStore();
  final history = HistoryStore();
  final profile = ProfileStore();
  final locale = LocaleStore();
  await Future.wait([repo.load(), settings.init(), history.init(), profile.init(), locale.init()]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(MultiProvider(
    providers: [
      Provider<ProductRepository>.value(value: repo),
      Provider<SettingsStore>.value(value: settings),
      ChangeNotifierProvider<ProfileStore>.value(value: profile),
      ChangeNotifierProvider<LocaleStore>.value(value: locale),
      Provider<AiService>.value(value: AiService(settings)),
      Provider<TtsService>(create: (_) => TtsService()),
      ChangeNotifierProvider<HistoryNotifier>(create: (_) => HistoryNotifier(history)),
    ],
    child: const SalesPitchApp(),
  ));
}

/// Wraps [HistoryStore] so screens rebuild when a new attempt is saved.
class HistoryNotifier extends ChangeNotifier {
  final HistoryStore store;
  HistoryNotifier(this.store);

  Future<void> add(Attempt a) async {
    await store.add(a);
    notifyListeners();
  }
}

/// No stretch/glow at the scroll edges: lists stop firmly, like a native app.
class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}

class SalesPitchApp extends StatelessWidget {
  const SalesPitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleStore>().locale;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scrollBehavior: const _NoStretchScrollBehavior(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}
