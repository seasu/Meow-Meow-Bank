import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'utils/theme.dart';
import 'utils/version.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/more_screen.dart';

void main() {
  runApp(const MeowMeowBankApp());
}

class MeowMeowBankApp extends StatelessWidget {
  const MeowMeowBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: '喵喵金幣屋',
        theme: appTheme(),
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    StatsScreen(),
    MoreScreen(),
  ];

  static const _titles = ['🏦 喵喵金幣屋', '📊 統計', '⚙️ 更多'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_titles[_currentIndex]),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v$appVersion',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        indicatorColor: Colors.amber.shade100,
        height: 65,
        destinations: const [
          NavigationDestination(
              icon: Text('🐱', style: TextStyle(fontSize: 26)), label: '存錢'),
          NavigationDestination(
              icon: Text('📊', style: TextStyle(fontSize: 26)), label: '統計'),
          NavigationDestination(
              icon: Text('⚙️', style: TextStyle(fontSize: 26)), label: '更多'),
        ],
      ),
    );
  }
}
