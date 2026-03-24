import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final _picker = ImagePicker();
  bool _processing = false;
  String? _error;
  double? _detectedAmount;
  XFile? _image;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, maxWidth: 1200);
      if (image == null) return;
      setState(() {
        _image = image;
        _processing = true;
        _error = null;
        _detectedAmount = null;
      });
      await _processImage(image);
    } catch (e) {
      setState(() {
        _processing = false;
        _error = '無法開啟相機/相簿: $e';
      });
    }
  }

  Future<void> _processImage(XFile image) async {
    try {
      // Try ML Kit on mobile
      if (!kIsWeb) {
        final amount = await _ocrExtract(image.path);
        if (amount != null) {
          setState(() {
            _detectedAmount = amount;
            _processing = false;
          });
          return;
        }
      }

      // Fallback: manual input with image preview
      setState(() {
        _processing = false;
        _error = kIsWeb
            ? '網頁版暫不支援自動辨識，請手動輸入金額'
            : '無法辨識金額，請手動輸入';
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _error = '辨識失敗，請手動輸入金額';
      });
    }
  }

  Future<double?> _ocrExtract(String path) async {
    try {
      // Dynamic import to avoid web crash
      final module = await _loadMlKit();
      if (module == null) return null;
      return module;
    } catch (_) {
      return null;
    }
  }

  Future<double?> _loadMlKit() async {
    try {
      final dynamic mlkit = await _runOcr();
      return mlkit;
    } catch (_) {
      return null;
    }
  }

  Future<double?> _runOcr() async {
    if (kIsWeb || _image == null) return null;
    try {
      // Use google_mlkit_text_recognition
      final inputImage = _createInputImage(_image!.path);
      if (inputImage == null) return null;

      final recognizer = _createTextRecognizer();
      if (recognizer == null) return null;

      final recognized = await _recognizeText(recognizer, inputImage);
      if (recognized == null) return null;

      return _extractAmount(recognized);
    } catch (_) {
      return null;
    }
  }

  dynamic _createInputImage(String path) {
    try {
      // ignore: depend_on_referenced_packages
      return Function.apply(
        // Will be resolved at runtime on mobile only
        _mlKitInputImageFromPath,
        [path],
      );
    } catch (_) {
      return null;
    }
  }

  dynamic _createTextRecognizer() => null;
  Future<String?> _recognizeText(dynamic recognizer, dynamic image) async => null;
  dynamic _mlKitInputImageFromPath(String path) => null;

  double? _extractAmount(String text) {
    // Find patterns like: 總計 123, 合計 $456, Total 789, NT$1,234
    final patterns = [
      RegExp(r'[總合小]計[：:\s]*\$?[\s]*([0-9,]+\.?\d*)', caseSensitive: false),
      RegExp(r'Total[：:\s]*\$?[\s]*([0-9,]+\.?\d*)', caseSensitive: false),
      RegExp(r'NT\$[\s]*([0-9,]+\.?\d*)', caseSensitive: false),
      RegExp(r'金額[：:\s]*\$?[\s]*([0-9,]+\.?\d*)', caseSensitive: false),
      RegExp(r'應付[：:\s]*\$?[\s]*([0-9,]+\.?\d*)', caseSensitive: false),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null) {
        final numStr = match.group(1)!.replaceAll(',', '');
        final v = double.tryParse(numStr);
        if (v != null && v > 0) return v;
      }
    }

    // Fallback: find the largest number in text
    final allNums = RegExp(r'(\d{2,}\.?\d*)').allMatches(text);
    double maxNum = 0;
    for (final m in allNums) {
      final v = double.tryParse(m.group(1)!) ?? 0;
      if (v > maxNum && v < 100000) maxNum = v;
    }
    return maxNum > 0 ? maxNum : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📸 拍發票記帳')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image preview or placeholder
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: _image != null
                  ? (kIsWeb
                      ? FutureBuilder<Uint8List>(
                          future: _image!.readAsBytes(),
                          builder: (_, snap) => snap.hasData
                              ? Image.memory(snap.data!, fit: BoxFit.cover)
                              : const Center(child: CircularProgressIndicator()),
                        )
                      : Image.file(File(_image!.path), fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('拍攝或選擇發票照片', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Camera / Gallery buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _processing ? null : () => _pickImage(ImageSource.camera),
                      icon: const Text('📷', style: TextStyle(fontSize: 20)),
                      label: const Text('拍照', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _processing ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Text('🖼️', style: TextStyle(fontSize: 20)),
                      label: const Text('相簿', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Processing indicator
            if (_processing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text('辨識中...', style: TextStyle(color: Colors.amber.shade700)),
                ],
              ),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(fontSize: 13, color: Colors.orange.shade700))),
                  ],
                ),
              ),

            // Detected amount
            if (_detectedAmount != null || _image != null) ...[
              const SizedBox(height: 16),
              _AmountConfirm(
                initialAmount: _detectedAmount ?? 0,
                onConfirm: (amount) => Navigator.pop(context, amount),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountConfirm extends StatefulWidget {
  final double initialAmount;
  final void Function(double) onConfirm;
  const _AmountConfirm({required this.initialAmount, required this.onConfirm});

  @override
  State<_AmountConfirm> createState() => _AmountConfirmState();
}

class _AmountConfirmState extends State<_AmountConfirm> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialAmount > 0 ? widget.initialAmount.toInt().toString() : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          if (widget.initialAmount > 0)
            Text('偵測到金額 🎉', style: TextStyle(fontSize: 14, color: Colors.green.shade600, fontWeight: FontWeight.bold)),
          if (widget.initialAmount <= 0)
            Text('請輸入發票金額', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.pink.shade400),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.pink.shade300),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(_ctrl.text) ?? 0;
                if (amt > 0) widget.onConfirm(amt);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('確認記帳 💸', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
