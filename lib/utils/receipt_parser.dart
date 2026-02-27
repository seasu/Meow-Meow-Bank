// Conditional export: mobile uses ML Kit OCR, web uses stub.
export 'receipt_parser_stub.dart'
    if (dart.library.io) 'receipt_parser_mobile.dart';
