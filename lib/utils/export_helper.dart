import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction.dart';

class ExportHelper {
  /// Generates a CSV file from [transactions] and opens the system share sheet.
  static Future<void> exportCsv(
    List<Transaction> transactions,
    String accountName,
  ) async {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    final today = DateFormat('yyyyMMdd').format(DateTime.now());

    final rows = <String>['日期,類型,類別,金額,備註,已審核'];
    for (final tx in transactions) {
      final note = tx.note.replaceAll('"', '""');
      rows.add([
        df.format(tx.createdAt),
        tx.type == TransactionType.income ? '收入' : '支出',
        tx.category.name,
        tx.amount.toStringAsFixed(0),
        '"$note"',
        tx.approved ? '是' : '否',
      ].join(','));
    }

    // UTF-8 BOM so Excel opens Chinese text correctly
    final csv = '\uFEFF${rows.join('\n')}';

    final dir = await getTemporaryDirectory();
    final fileName = '喵喵金幣屋_${accountName}_$today.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: '喵喵金幣屋 $accountName 記帳明細',
    );
  }
}
