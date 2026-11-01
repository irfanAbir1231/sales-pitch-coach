import 'package:flutter/material.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'হোম'),
          NavigationDestination(
              icon: Icon(Icons.record_voice_over_outlined), selectedIcon: Icon(Icons.record_voice_over), label: 'প্র্যাকটিস'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'ইতিহাস'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'সেটিংস'),
        ],
      ),
    );
  }
}
