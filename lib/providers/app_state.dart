import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
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
    final raw = prefs.getString('app_state');
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
        _name = data['name'] ?? '小朋友';
        _lastRecordDate = data['lastRecordDate'];
        _streak = data['streak'] ?? 0;
        _catHunger = (data['catHunger'] as num?)?.toDouble() ?? kMaxHunger;
        _buildingLevel = data['buildingLevel'] ?? 0;
        _unlockedAccessories =
            List<String>.from(data['unlockedAccessories'] ?? []);
        _equippedAccessories =
            List<String>.from(data['equippedAccessories'] ?? []);
        _interestRate = (data['interestRate'] as num?)?.toDouble() ?? 1;
        _interestPeriod = data['interestPeriod'] ?? 'weekly';
      } catch (_) {}
    }
    _updateHunger();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'app_state',
        jsonEncode({
          'transactions': _transactions.map((e) => e.toJson()).toList(),
          'wishes': _wishes.map((e) => e.toJson()).toList(),
          'name': _name,
          'lastRecordDate': _lastRecordDate,
          'streak': _streak,
          'catHunger': _catHunger,
          'buildingLevel': _buildingLevel,
          'unlockedAccessories': _unlockedAccessories,
          'equippedAccessories': _equippedAccessories,
          'interestRate': _interestRate,
          'interestPeriod': _interestPeriod,
        }));
  }

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

  void addTransaction(double amount, TxCategory category, TransactionType type,
      String note) {
    final tx = Transaction(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      type: type,
      note: note,
      createdAt: DateTime.now(),
    );
    _transactions.add(tx);

    final todayStr = _today();
    if (_lastRecordDate == null) {
      _streak = 1;
    } else if (_lastRecordDate == todayStr) {
      // same day
    } else if (_daysBetween(_lastRecordDate!, todayStr) == 1) {
      _streak++;
    } else {
      _streak = 1;
    }
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
    _wishes.add(Wish(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
    ));
    _save();
    notifyListeners();
  }

  void waterWish(String wishId, double amount) {
    final w = _wishes.firstWhere((e) => e.id == wishId);
    w.savedAmount = (w.savedAmount + amount).clamp(0, w.targetAmount);
    if (w.savedAmount >= w.targetAmount) w.completedAt = DateTime.now();
    _save();
    notifyListeners();
  }

  void deleteWish(String wishId) {
    _wishes.removeWhere((e) => e.id == wishId);
    _save();
    notifyListeners();
  }

  void toggleAccessory(String id) {
    if (_equippedAccessories.contains(id)) {
      _equippedAccessories.remove(id);
    } else {
      _equippedAccessories.add(id);
    }
    _save();
    notifyListeners();
  }

  void approveTransaction(String id) {
    _transactions.firstWhere((t) => t.id == id).approved = true;
    _save();
    notifyListeners();
  }

  void sendHeart(String id) {
    _transactions.firstWhere((t) => t.id == id).parentHeart = true;
    _save();
    notifyListeners();
  }

  void updateInterestConfig(double rate, String period) {
    _interestRate = rate;
    _interestPeriod = period;
    _save();
    notifyListeners();
  }

  void applyInterest() {
    if (balance <= 0) return;
    final interest = (balance * _interestRate / 100).roundToDouble();
    if (interest <= 0) return;
    final cat = const TxCategory(
        id: 'interest', name: '利息', emoji: '🏦', type: TransactionType.income);
    addTransaction(interest, cat, TransactionType.income,
        '${_interestPeriod == "weekly" ? "週" : "月"}利息');
  }
}
