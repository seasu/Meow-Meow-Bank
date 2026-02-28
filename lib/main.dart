import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'utils/theme.dart';
import 'utils/version.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/more_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 將所有未處理的 Flutter framework 錯誤回報給 Crashlytics
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // 將所有未處理的 Dart 非同步錯誤回報給 Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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

  void _showAccountSwitcher(AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('切換帳號', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...state.accounts.map((acc) => ListTile(
                  leading: Text(acc.emoji, style: const TextStyle(fontSize: 28)),
                  title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: acc.id == state.currentAccountId
                      ? Icon(Icons.check_circle, color: Colors.green.shade400)
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: acc.id == state.currentAccountId ? Colors.amber.shade50 : null,
                  onTap: () {
                    state.switchAccount(acc.id);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddAccount(state);
                },
                icon: const Icon(Icons.add),
                label: const Text('新增帳號'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccount(AppState state) {
    String emoji = '🐱';
    final nameCtrl = TextEditingController();
    final emojis = [
      '🐱', '🐶', '🐰', '🐻', '🦊', '🐸', '🐧', '🦄',
      '🐼', '🐨', '🦁', '🐯', '🐮', '🐷', '🐵', '🐔',
      '🦋', '🐢', '🐙', '🦖', '👦', '👧', '👶', '🧒',
      '👸', '🤴', '🦸', '🧙', '🎅', '🤖', '👽', '💀',
    ];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('新增帳號', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 240,
                width: double.maxFinite,
                child: GridView.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setS(() => emoji = e),
                    child: Container(
                      decoration: BoxDecoration(
                        color: emoji == e ? Colors.amber.shade100 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: emoji == e ? Border.all(color: Colors.amber, width: 3) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 32)),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '名字',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                final n = nameCtrl.text.trim();
                if (n.isNotEmpty) {
                  state.addAccount(n, emoji);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('建立', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final acc = state.currentAccount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏦 喵喵金幣屋'),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('v$appVersion',
                  style: TextStyle(fontSize: 10, color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          // Account switcher button
          GestureDetector(
            onTap: () => _showAccountSwitcher(state),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(acc?.emoji ?? '🐱', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(acc?.name ?? '小朋友',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                  Icon(Icons.arrow_drop_down, size: 18, color: Colors.amber.shade600),
                ],
              ),
            ),
          ),
        ],
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
          NavigationDestination(icon: Text('🐱', style: TextStyle(fontSize: 26)), label: '存錢'),
          NavigationDestination(icon: Text('📊', style: TextStyle(fontSize: 26)), label: '統計'),
          NavigationDestination(icon: Text('⚙️', style: TextStyle(fontSize: 26)), label: '更多'),
        ],
      ),
    );
  }
}
