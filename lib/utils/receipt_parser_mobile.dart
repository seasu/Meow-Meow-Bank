import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptData {
  final double? amount;
  final String rawText;
  final String suggestedNote;

  const ReceiptData({
    this.amount,
    required this.rawText,
    required this.suggestedNote,
  });
}

class ReceiptParser {
  /// Runs on-device OCR (Google ML Kit) on the given image bytes and extracts
  /// the total amount from a Taiwanese / general receipt.
  ///
  /// Bytes are written to a stable temp file before being passed to ML Kit,
  /// because the original [XFile] path from iOS camera may be invalidated
  /// after [readAsBytes] is called, causing a native crash.
  static Future<ReceiptData?> parseReceipt(Uint8List bytes) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    File? tmpFile;
    try {
      final dir = await getTemporaryDirectory();
      tmpFile = File(
          '${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tmpFile.writeAsBytes(bytes, flush: true);

      final inputImage = InputImage.fromFilePath(tmpFile.path);
      final recognized = await recognizer.processImage(inputImage);
      final text = recognized.text;

      final amount = _extractAmount(text);
      final note = _extractMerchantName(text);

      return ReceiptData(amount: amount, rawText: text, suggestedNote: note);
    } finally {
      recognizer.close();
      tmpFile?.delete().ignore();
    }
  }

  /// Extract the total/payable amount from OCR text.
  /// Tries patterns in priority order: total-line keywords → NT$ prefix → 元 suffix.
  static double? _extractAmount(String text) {
    final prioritized = [
      // Highest priority: explicit total keywords
      RegExp(r'(?:合計|總計|總金額|應收金額|應收|實收|實付)\s*[：:$＄NT]*\s*(\d[\d,.]*)'),
      RegExp(r'TOTAL\s*[：:$＄NT]*\s*(\d[\d,.]*)'),
      RegExp(r'(?:小計|含稅小計)\s*[：:$＄NT]*\s*(\d[\d,.]*)'),
      // NT$ / NTD currency prefix
      RegExp(r'NT\$\s*(\d[\d,.]*)'),
      RegExp(r'NTD\s*(\d[\d,.]*)'),
      // Amount with 元 suffix
      RegExp(r'(\d[\d,.]*)\s*元'),
    ];

    double? bestAmount;
    int bestPriority = prioritized.length;

    for (var i = 0; i < prioritized.length; i++) {
      for (final match in prioritized[i].allMatches(text)) {
        final amtStr = match.group(1)!.replaceAll(',', '').replaceAll('，', '');
        final amt = double.tryParse(amtStr);
        if (amt != null && amt >= 1 && amt <= 500000) {
          // Prefer highest-priority pattern; break ties by largest amount
          if (i < bestPriority || (i == bestPriority && amt > (bestAmount ?? 0))) {
            bestAmount = amt;
            bestPriority = i;
          }
        }
      }
    }

    return bestAmount;
  }

  /// Take the first meaningful line as a suggested note (merchant name).
  static String _extractMerchantName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.length > 1 && !RegExp(r'^\d+$').hasMatch(l))
        .toList();
    return lines.isNotEmpty ? lines.first : '';
  }
}
