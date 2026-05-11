import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'state/reset_app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = ResetAppState(
    storage: StorageService(),
    notifications: NotificationService(),
  );
  await appState.initialize();

  runApp(ResetApp(appState: appState));
}

class ResetApp extends StatelessWidget {
  const ResetApp({super.key, required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reset',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F4FA),
      ),
      home: ResetShell(appState: appState),
    );
  }
}

class ResetShell extends StatefulWidget {
  const ResetShell({super.key, required this.appState});

  final ResetAppState appState;

  @override
  State<ResetShell> createState() => _ResetShellState();
}

class _ResetShellState extends State<ResetShell> {
  int _selectedIndex = 0;

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(appState: widget.appState, onChanged: _refresh),
      StatsScreen(appState: widget.appState),
      SettingsScreen(appState: widget.appState, onChanged: _refresh),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        indicatorColor: Colors.deepPurple.withValues(alpha: 0.16),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
