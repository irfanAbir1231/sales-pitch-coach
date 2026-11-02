import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'product_list_screen.dart';
import 'settings_screen.dart';

/// App frame: bottom navigation with four tabs that keep their state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  // Tabs visited before the current one, so Back returns to the previous tab.
  final List<int> _trail = [];

  void _goTo(int i) {
    if (i == _index) return;
    setState(() {
      _trail.add(_index);
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _trail.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _trail.isNotEmpty) setState(() => _index = _trail.removeLast());
      },
      child: _scaffold(),
    );
  }

  Widget _scaffold() {
    final l = context.l10n;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onGoTo: _goTo),
          const ProductListScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.chrome,
          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: [
            NavigationDestination(icon: const Icon(AppIcons.home), selectedIcon: const Icon(AppIcons.homeFill), label: l.navHome),
            NavigationDestination(icon: const Icon(AppIcons.mic), selectedIcon: const Icon(AppIcons.micFill), label: l.navPractice),
            NavigationDestination(icon: const Icon(AppIcons.history), selectedIcon: const Icon(AppIcons.historyFill), label: l.navHistory),
            NavigationDestination(icon: const Icon(AppIcons.profile), selectedIcon: const Icon(AppIcons.profileFill), label: l.navProfile),
          ],
        ),
      ),
    );
  }
}
