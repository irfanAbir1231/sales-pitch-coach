import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ai/ai_service.dart';
import 'data/product_repository.dart';
import 'screens/product_list_screen.dart';
import 'services/history_store.dart';
import 'services/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = ProductRepository();
  final settings = SettingsStore();
  final history = HistoryStore();
  await Future.wait([repo.load(), settings.init(), history.init()]);

  runApp(MultiProvider(
    providers: [
      Provider<ProductRepository>.value(value: repo),
      Provider<SettingsStore>.value(value: settings),
      Provider<AiService>.value(value: AiService(settings)),
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

class SalesPitchApp extends StatelessWidget {
  const SalesPitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Pitch Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B6B50)),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}
