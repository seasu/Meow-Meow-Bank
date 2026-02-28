// Web stub — OCR is not supported in the browser.
import 'dart:typed_data';

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
  static Future<ReceiptData?> parseReceipt(Uint8List bytes) async {
    // OCR is not available on web; return null so the UI falls back to
    // manual amount entry.
    return null;
  }
}
