import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../utils/receipt_parser.dart';
import '../utils/sounds.dart';

enum _ScanState { initial, loading, confirm }

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final _picker = ImagePicker();
  final _noteController = TextEditingController();

  _ScanState _state = _ScanState.initial;
  Uint8List? _imageBytes;
  double _amount = 0;
  TxCategory _selectedCategory =
      kCategories.firstWhere((c) => c.id == 'shopping');
  bool _ocrAvailable = true;

  static final _expenseCategories =
      kCategories.where((c) => c.type == TransactionType.expense).toList();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    XFile? xFile;
    try {
      xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法開啟相機，請確認已授予相機權限')),
        );
      }
      return;
    }

    if (xFile == null || !mounted) return;

    final bytes = await xFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
      _state = _ScanState.loading;
    });

    try {
      final result = await ReceiptParser.parseReceipt(xFile);
      if (!mounted) return;
      setState(() {
        _amount = result?.amount ?? 0;
        _noteController.text = result?.suggestedNote ?? '';
        _ocrAvailable = result != null;
        _state = _ScanState.confirm;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _amount = 0;
        _ocrAvailable = false;
        _state = _ScanState.confirm;
      });
    }
  }

  void _confirm(AppState state) {
    if (_amount <= 0) return;
    SoundService.playSpendMoney();
    HapticFeedback.mediumImpact();
    state.addTransaction(
        _amount, _selectedCategory, TransactionType.expense, _noteController.text.trim());
    Navigator.pop(context, true);
  }

  void _showAmountEditor() {
    final ctrl = TextEditingController(
        text: _amount > 0 ? _amount.toInt().toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('輸入金額'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: '0',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val >= 0) setState(() => _amount = val);
              Navigator.pop(ctx);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('📷 掃描發票記帳',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: switch (_state) {
          _ScanState.initial => _buildInitial(),
          _ScanState.loading => _buildLoading(),
          _ScanState.confirm => _buildConfirm(state),
        },
      ),
    );
  }

  // ─── Initial state ────────────────────────────────────────────────────────

  Widget _buildInitial() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('選擇發票照片',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '拍下或選取發票，自動辨識金額並記帳',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),
          _BigButton(
            emoji: '📷',
            label: '立即拍照',
            subtitle: '用相機拍攝發票',
            color: Colors.pink.shade400,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          _BigButton(
            emoji: '🖼️',
            label: '從相簿選取',
            subtitle: '選取已儲存的發票照片',
            color: Colors.orange.shade400,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  // ─── Loading state ────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _imageBytes!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('正在辨識發票金額...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('🔍 掃描中',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ─── Confirm state ────────────────────────────────────────────────────────

  Widget _buildConfirm(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          if (_imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _imageBytes!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 20),

          // Amount section
          Text('💰 消費金額',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showAmountEditor,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.12),
                      blurRadius: 12)
                ],
                border: Border.all(color: Colors.pink.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _amount > 0
                        ? '\$ ${_amount.toInt()}'
                        : '點擊輸入金額',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: _amount > 0
                          ? Colors.pink.shade400
                          : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                _ocrAvailable
                    ? Icons.auto_awesome
                    : Icons.info_outline,
                size: 14,
                color: _ocrAvailable
                    ? Colors.amber.shade600
                    : Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                _ocrAvailable
                    ? (_amount > 0 ? '自動辨識金額，可點擊修改' : '未辨識到金額，請點擊輸入')
                    : '目前平台不支援自動辨識，請手動輸入金額',
                style: TextStyle(
                  fontSize: 12,
                  color: _ocrAvailable
                      ? Colors.amber.shade700
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Category section
          Text('🏷️ 消費類別',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _expenseCategories.map((cat) {
              final selected = cat.id == _selectedCategory.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        selected ? Colors.pink.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? Colors.pink.shade300
                          : Colors.grey.shade200,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? Colors.pink.shade600
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Note section
          Text('📝 備註（選填）',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: '例如：早餐、文具等',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.pink.shade300),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _amount > 0 ? () => _confirm(state) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: _amount > 0 ? 4 : 0,
              ),
              child: Text(
                _amount > 0
                    ? '確認記帳 ${_selectedCategory.emoji}  −\$${_amount.toInt()}'
                    : '請輸入金額',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _amount > 0 ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: TextButton.icon(
              onPressed: () => setState(() {
                _imageBytes = null;
                _amount = 0;
                _noteController.clear();
                _state = _ScanState.initial;
              }),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重新掃描'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widget ─────────────────────────────────────────────────────────

class _BigButton extends StatelessWidget {
  final String emoji, label, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BigButton({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
          border: Border.all(
              color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                  child:
                      Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: color.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }
}
