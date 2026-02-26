import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/dream_tree_screen.dart';
import 'screens/accessories_screen.dart';
import 'screens/parent_screen.dart';

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
    DreamTreeScreen(),
    AccessoriesScreen(),
    ParentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏦 喵喵金幣屋'),
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
        destinations: const [
          NavigationDestination(icon: Text('🪙', style: TextStyle(fontSize: 22)), label: '記帳'),
          NavigationDestination(icon: Text('📊', style: TextStyle(fontSize: 22)), label: '統計'),
          NavigationDestination(icon: Text('🌳', style: TextStyle(fontSize: 22)), label: '夢想樹'),
          NavigationDestination(icon: Text('✨', style: TextStyle(fontSize: 22)), label: '收藏'),
          NavigationDestination(icon: Text('👨‍👩‍👧', style: TextStyle(fontSize: 22)), label: '家長'),
        ],
      ),
    );
  }
}
