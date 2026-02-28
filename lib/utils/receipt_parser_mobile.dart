import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  /// Runs QR code scan (Taiwan e-invoice) then OCR on the given image bytes.
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

      // 1. Try QR code first — reliable for Taiwan electronic invoices
      final qrAmount = await _extractAmountFromQRCode(tmpFile.path);

      // 2. Always run OCR for merchant name and fallback amount
      final inputImage = InputImage.fromFilePath(tmpFile.path);
      final recognized = await recognizer.processImage(inputImage);
      final text = recognized.text;

      final amount = qrAmount ?? _extractAmount(text);
      final note = _extractMerchantName(text);

      return ReceiptData(amount: amount, rawText: text, suggestedNote: note);
    } finally {
      recognizer.close();
      tmpFile?.delete().ignore();
    }
  }

  // ─── QR Code ─────────────────────────────────────────────────────────────

  /// Attempt to scan barcodes/QR codes from a static image file.
  /// Returns the total amount if a Taiwan e-invoice QR code is found.
  static Future<double?> _extractAmountFromQRCode(String imagePath) async {
    try {
      final controller = MobileScannerController();
      final result = await controller.analyzeImage(imagePath);
      await controller.dispose();

      if (result == null) return null;
      for (final barcode in result.barcodes) {
        final raw = barcode.rawValue;
        if (raw == null) continue;
        final amt = _parseTaiwanInvoiceQR(raw);
        if (amt != null) return amt;
      }
    } catch (_) {
      // QR scanning unavailable on this platform; fall through to OCR
    }
    return null;
  }

  /// Parse Taiwan Ministry of Finance e-invoice left QR code.
  ///
  /// Format (0-indexed):
  ///   [0:10]  Invoice number (e.g. WD98900416)
  ///   [10:17] ROC date YYYMMDD
  ///   [17:21] Random code
  ///   [21:29] Untaxed sales amount (8 uppercase hex digits)
  ///   [29:37] Total amount incl. tax (8 uppercase hex digits)
  static double? _parseTaiwanInvoiceQR(String data) {
    if (data.length < 37) return null;
    // Taiwan invoice numbers start with 2 uppercase letters + 8 digits
    if (!RegExp(r'^[A-Z]{2}\d{8}').hasMatch(data)) return null;
    try {
      final taxedHex = data.substring(29, 37);
      final amt = int.parse(taxedHex, radix: 16);
      if (amt > 0 && amt <= 500000) return amt.toDouble();
    } catch (_) {}
    return null;
  }

  // ─── OCR Amount Extraction ────────────────────────────────────────────────

  /// Correct common OCR misreads in thermal-printer numeric text.
  static String _fixNumericOcr(String s) => s
      .replaceAll(',', '')
      .replaceAll('，', '')
      .replaceAll('D', '0')
      .replaceAll('O', '0')
      .replaceAll('o', '0')
      .replaceAll('口', '0')
      .replaceAll('I', '1')
      .replaceAll('l', '1')
      .replaceAll('S', '5')
      .replaceAll('B', '8');

  /// Extract the total/payable amount from OCR text.
  ///
  /// Patterns are tried in priority order; ties broken by largest amount.
  /// The separator between keyword and number is flexible:
  ///   optional full/half-width colon → optional spaces → optional $ / ＄ / NT
  /// Capture groups use [0-9DOIlSB,]+ to tolerate common OCR error chars.
  static double? _extractAmount(String text) {
    // Flexible separator: optional colon, optional spaces, optional currency symbol
    const sep = r'\s*(?:[：:]\s*)?(?:[＄$NT]+\s*)?';

    final prioritized = [
      // Explicit total / payment keywords
      RegExp('(?:合計|總計|總金額|應收金額|應收|實收|實付|收現|收款)$sep([0-9DOIlSB,]+)'),
      RegExp('TOTAL$sep([0-9DOIlSB,]+)', caseSensitive: false),
      RegExp('(?:小計|含稅小計)$sep([0-9DOIlSB,]+)'),
      // NT$ / NTD prefix
      RegExp(r'NT\$\s*([0-9DOIlSB,]+)'),
      RegExp(r'NTD\s*([0-9,]+)'),
      // Amount with 元 suffix
      RegExp(r'([0-9,]+)\s*元'),
      // Fallback: bare $ / ＄ followed by 3–6 digits
      RegExp(r'[＄$]\s*([0-9]{3,6})\b'),
    ];

    double? bestAmount;
    int bestPriority = prioritized.length;

    for (var i = 0; i < prioritized.length; i++) {
      for (final match in prioritized[i].allMatches(text)) {
        final amtStr = _fixNumericOcr(match.group(1)!);
        final amt = double.tryParse(amtStr);
        if (amt != null && amt >= 1 && amt <= 500000) {
          if (i < bestPriority ||
              (i == bestPriority && amt > (bestAmount ?? 0))) {
            bestAmount = amt;
            bestPriority = i;
          }
        }
      }
    }

    return bestAmount;
  }

  // ─── Merchant Name ────────────────────────────────────────────────────────

  static final _skipPatterns = [
    RegExp(r'電子發票|統一發票|銷貨明細|銷售明細|收銀機'),
    RegExp(r'民國|隨機碼|賣方|總計|合計|收現|收款|小計'),
    RegExp(r'退貨|繳稅|聰明|稅務|稽查'),
    RegExp(r'^NO[:\s]|^TEL[:\s]|^機號|^店名:|^地址'),
    RegExp(r'^\d{4}-\d{2}-\d{2}'), // ISO date
    RegExp(r'^\d{3,4}年'), // ROC year line
    RegExp(r'^[A-Z]{2}[-\s]?\d{7,8}$'), // invoice number
    RegExp(r'^\d{6,}$'), // long digit strings
    RegExp(r'^0{3,}'), // starts with many zeros
  ];

  /// Return the first line that looks like a business name:
  /// short, contains Chinese characters, and isn't a known header/footer.
  static String _extractMerchantName(String text) {
    return text
            .split('\n')
            .map((l) => l.trim())
            .where((l) {
              if (l.length < 2 || l.length > 20) return false;
              if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(l)) return false;
              if (_skipPatterns.any((p) => p.hasMatch(l))) return false;
              return true;
            })
            .firstOrNull ??
        '';
  }
}
