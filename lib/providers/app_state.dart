import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/constants.dart';

class AppState extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Wish> _wishes = [];
  String _name = '小朋友';
  String? _lastRecordDate;
  int _streak = 0;
  double _catHunger = kMaxHunger;
  int _buildingLevel = 0;
  List<String> _unlockedAccessories = [];
  List<String> _equippedAccessories = [];
  double _interestRate = 1;
  String _interestPeriod = 'weekly';

  // Multi-account
  List<Account> _accounts = [];
  String? _currentAccountId;

  final _uuid = const Uuid();

  List<Transaction> get transactions => _transactions;
  List<Wish> get wishes => _wishes;
  String get name => _name;
  int get streak => _streak;
  double get catHunger => _catHunger;
  int get buildingLevel => _buildingLevel;
  List<String> get unlockedAccessories => _unlockedAccessories;
  List<String> get equippedAccessories => _equippedAccessories;
  double get interestRate => _interestRate;
  String get interestPeriod => _interestPeriod;
  List<Account> get accounts => _accounts;
  String? get currentAccountId => _currentAccountId;
  Account? get currentAccount =>
      _currentAccountId != null && _accounts.isNotEmpty
          ? _accounts.cast<Account?>().firstWhere((a) => a?.id == _currentAccountId, orElse: () => null)
          : null;

  double get balance => _transactions.fold(
      0.0, (s, t) => t.type == TransactionType.income ? s + t.amount : s - t.amount);

  double get totalSaved => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load accounts list
    final accRaw = prefs.getString('accounts');
    if (accRaw != null) {
      try {
        _accounts = (jsonDecode(accRaw) as List)
            .map((e) => Account.fromJson(e))
            .toList();
      } catch (_) {}
    }

    // Load current account id
    _currentAccountId = prefs.getString('current_account');

    // If no accounts, create default
    if (_accounts.isEmpty) {
      final defaultAcc = Account(
        id: _uuid.v4(),
        name: '小朋友',
        emoji: '🐱',
        createdAt: DateTime.now(),
      );
      _accounts.add(defaultAcc);
      _currentAccountId = defaultAcc.id;
      await _saveAccountsList();
    }

    // If current not set, use first
    if (_currentAccountId == null || !_accounts.any((a) => a.id == _currentAccountId)) {
      _currentAccountId = _accounts.first.id;
    }

    await _loadAccountData();
    notifyListeners();
  }

  Future<void> _loadAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'account_$_currentAccountId';
    final raw = prefs.getString(key);

    // Reset to defaults
    _transactions = [];
    _wishes = [];
    _name = currentAccount?.name ?? '小朋友';
    _lastRecordDate = null;
    _streak = 0;
    _catHunger = kMaxHunger;
    _buildingLevel = 0;
    _unlockedAccessories = [];
    _equippedAccessories = [];
    _interestRate = 1;
    _interestPeriod = 'weekly';

    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _transactions = (data['transactions'] as List?)
                ?.map((e) => Transaction.fromJson(e))
                .toList() ??
            [];
        _wishes = (data['wishes'] as List?)
                ?.map((e) => Wish.fromJson(e))
                .toList() ??
            [];
        _lastRecordDate = data['lastRecordDate'];
        _streak = data['streak'] ?? 0;
        _catHunger = (data['catHunger'] as num?)?.toDouble() ?? kMaxHunger;
        _buildingLevel = data['buildingLevel'] ?? 0;
        _unlockedAccessories = List<String>.from(data['unlockedAccessories'] ?? []);
        _equippedAccessories = List<String>.from(data['equippedAccessories'] ?? []);
        _interestRate = (data['interestRate'] as num?)?.toDouble() ?? 1;
        _interestPeriod = data['interestPeriod'] ?? 'weekly';
      } catch (_) {}
    }

    // Migrate: also try old 'app_state' key for first account
    if (_transactions.isEmpty) {
      final oldRaw = prefs.getString('app_state');
      if (oldRaw != null) {
        try {
          final data = jsonDecode(oldRaw) as Map<String, dynamic>;
          _transactions = (data['transactions'] as List?)
                  ?.map((e) => Transaction.fromJson(e))
                  .toList() ??
              [];
          _wishes = (data['wishes'] as List?)
                  ?.map((e) => Wish.fromJson(e))
                  .toList() ??
              [];
          _lastRecordDate = data['lastRecordDate'];
          _streak = data['streak'] ?? 0;
          _catHunger = (data['catHunger'] as num?)?.toDouble() ?? kMaxHunger;
          _buildingLevel = data['buildingLevel'] ?? 0;
          _unlockedAccessories = List<String>.from(data['unlockedAccessories'] ?? []);
          _equippedAccessories = List<String>.from(data['equippedAccessories'] ?? []);
          _interestRate = (data['interestRate'] as num?)?.toDouble() ?? 1;
          _interestPeriod = data['interestPeriod'] ?? 'weekly';
          await _save();
          await prefs.remove('app_state');
        } catch (_) {}
      }
    }

    _updateHunger();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'account_$_currentAccountId';
    await prefs.setString(
        key,
        jsonEncode({
          'transactions': _transactions.map((e) => e.toJson()).toList(),
          'wishes': _wishes.map((e) => e.toJson()).toList(),
          'lastRecordDate': _lastRecordDate,
          'streak': _streak,
          'catHunger': _catHunger,
          'buildingLevel': _buildingLevel,
          'unlockedAccessories': _unlockedAccessories,
          'equippedAccessories': _equippedAccessories,
          'interestRate': _interestRate,
          'interestPeriod': _interestPeriod,
        }));
    await prefs.setString('current_account', _currentAccountId ?? '');
  }

  Future<void> _saveAccountsList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'accounts', jsonEncode(_accounts.map((a) => a.toJson()).toList()));
  }

  // Account management
  Future<void> addAccount(String name, String emoji) async {
    final acc = Account(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      createdAt: DateTime.now(),
    );
    _accounts.add(acc);
    await _saveAccountsList();
    await switchAccount(acc.id);
  }

  Future<void> switchAccount(String accountId) async {
    if (_currentAccountId == accountId) return;
    _currentAccountId = accountId;
    await _loadAccountData();
    notifyListeners();
  }

  Future<void> renameAccount(String accountId, String newName, String newEmoji) async {
    final acc = _accounts.firstWhere((a) => a.id == accountId);
    acc.name = newName;
    acc.emoji = newEmoji;
    if (accountId == _currentAccountId) _name = newName;
    await _saveAccountsList();
    notifyListeners();
  }

  Future<void> deleteAccount(String accountId) async {
    if (_accounts.length <= 1) return;
    _accounts.removeWhere((a) => a.id == accountId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account_$accountId');
    await _saveAccountsList();
    if (_currentAccountId == accountId) {
      await switchAccount(_accounts.first.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> clearAccountData() async {
    _transactions = [];
    _wishes = [];
    _lastRecordDate = null;
    _streak = 0;
    _catHunger = kMaxHunger;
    _buildingLevel = 0;
    _unlockedAccessories = [];
    _equippedAccessories = [];
    await _save();
    notifyListeners();
  }

  // Existing methods
  String _today() => DateTime.now().toIso8601String().split('T')[0];

  int _daysBetween(String a, String b) {
    final d1 = DateTime.parse(a);
    final d2 = DateTime.parse(b);
    return d2.difference(d1).inDays.abs();
  }

  void _updateHunger() {
    if (_lastRecordDate == null) return;
    final days = _daysBetween(_lastRecordDate!, _today());
    if (days > 0) {
      _catHunger = (_catHunger - days * kHungerDecayPerDay).clamp(0, kMaxHunger);
      if (days > 1) _streak = 0;
    }
  }

  void addTransaction(double amount, TxCategory category, TransactionType type, String note, {DateTime? customDate}) {
    final tx = Transaction(id: _uuid.v4(), amount: amount, category: category, type: type, note: note, createdAt: customDate ?? DateTime.now());
    _transactions.add(tx);
    final todayStr = _today();
    if (_lastRecordDate == null) { _streak = 1; }
    else if (_lastRecordDate == todayStr) {}
    else if (_daysBetween(_lastRecordDate!, todayStr) == 1) { _streak++; }
    else { _streak = 1; }
    _lastRecordDate = todayStr;
    _catHunger = (_catHunger + kHungerFeedAmount).clamp(0, kMaxHunger);
    _updateBuildingLevel();
    _checkAccessoryUnlocks();
    _save();
    notifyListeners();
  }

  void _updateBuildingLevel() {
    final saved = totalSaved;
    if (saved >= kBuildingThresholds[2]!) {
      _buildingLevel = 2;
    } else if (saved >= kBuildingThresholds[1]!) {
      _buildingLevel = 1;
    } else {
      _buildingLevel = 0;
    }
  }

  void _checkAccessoryUnlocks() {
    for (final acc in kAccessories) {
      if (_unlockedAccessories.contains(acc.id)) continue;
      if (acc.reqType == 'streak' && _streak >= acc.reqValue) {
        _unlockedAccessories.add(acc.id);
      }
      if (acc.reqType == 'savings' && totalSaved >= acc.reqValue) {
        _unlockedAccessories.add(acc.id);
      }
    }
  }

  void addWish(String name, String emoji, double targetAmount) {
    _wishes.add(Wish(id: _uuid.v4(), name: name, emoji: emoji, targetAmount: targetAmount, createdAt: DateTime.now()));
    _save(); notifyListeners();
  }

  void waterWish(String wishId, double amount) {
    final w = _wishes.firstWhere((e) => e.id == wishId);
    w.savedAmount = (w.savedAmount + amount).clamp(0, w.targetAmount);
    if (w.savedAmount >= w.targetAmount) w.completedAt = DateTime.now();
    _save(); notifyListeners();
  }

  void deleteWish(String wishId) { _wishes.removeWhere((e) => e.id == wishId); _save(); notifyListeners(); }
  void toggleAccessory(String id) {
    _equippedAccessories.contains(id) ? _equippedAccessories.remove(id) : _equippedAccessories.add(id);
    _save(); notifyListeners();
  }
  void updateTransaction(String id, {double? amount, TxCategory? category, TransactionType? type, String? note, DateTime? createdAt}) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final tx = _transactions[idx];
    if (amount != null) tx.amount = amount;
    if (category != null) tx.category = category;
    if (type != null) tx.type = type;
    if (note != null) tx.note = note;
    if (createdAt != null) tx.createdAt = createdAt;
    _updateBuildingLevel();
    _save();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _updateBuildingLevel();
    _save();
    notifyListeners();
  }

  void approveTransaction(String id) { _transactions.firstWhere((t) => t.id == id).approved = true; _save(); notifyListeners(); }
  void sendHeart(String id) { _transactions.firstWhere((t) => t.id == id).parentHeart = true; _save(); notifyListeners(); }
  void updateInterestConfig(double rate, String period) { _interestRate = rate; _interestPeriod = period; _save(); notifyListeners(); }
  void applyInterest() {
    if (balance <= 0) return;
    final interest = (balance * _interestRate / 100).roundToDouble();
    if (interest <= 0) return;
    addTransaction(interest, const TxCategory(id: 'interest', name: '利息', emoji: '🏦', type: TransactionType.income),
        TransactionType.income, '${_interestPeriod == "weekly" ? "週" : "月"}利息');
  }
}
