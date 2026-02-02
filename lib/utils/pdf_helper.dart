import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/transaction_item.dart';

class PdfHelper {
  static final NumberFormat indianR = NumberFormat.simpleCurrency(
    locale: 'en_IN',
    name: 'INR',
    decimalDigits: 0,
  );

  /// Load font from assets using rootBundle
  static Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  static Future<void> generateBill(Transaction transaction) async {
    final pdf = pw.Document();

    // Load custom fonts
    final fontRegular =
    await _loadFont('assets/fonts/NotoSans-Regular.ttf');
    final fontBold =
    await _loadFont('assets/fonts/NotoSans-Bold.ttf');
    final fontItalic =
    await _loadFont('assets/fonts/NotoSans-Italic.ttf');
    final fontBoldItalic =
    await _loadFont('assets/fonts/NotoSans-BoldItalic.ttf');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
          boldItalic: fontBoldItalic,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              pw.Center(
                child: pw.Text(
                  "Vishwabandhu Organics",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // ============== INVOICE DETAILS =============
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Bill To:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(transaction.personName),
                      if (transaction.personPhone.isNotEmpty)
                        pw.Text("Phone: ${transaction.personPhone}"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Date: ${DateFormat('dd-MM-yyyy').format(transaction.date)}",
                      ),
                      pw.Text(
                        "Invoice #: ${transaction.id.substring(transaction.id.length - 6)}",
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ================= ITEMS TABLE =================
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(width: 0.5),
                  horizontalInside: pw.BorderSide(width: 0.5),
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: const pw.TextStyle(),
                data: <List<String>>[
                  <String>['Item', 'Qty', 'Unit Price', 'Total'],
                  ...transaction.items.map((TransactionItem item) => [
                    item.productName,
                    item.quantity.toString(),
                    indianR.format(item.unitPrice),
                    indianR.format(item.totalPrice),
                  ]),
                  // Legacy single-item support
                  if (transaction.items.isEmpty &&
                      transaction.productName.isNotEmpty)
                    [
                      transaction.productName,
                      "1",
                      indianR.format(transaction.productPrice),
                      indianR.format(transaction.productPrice),
                    ],
                ],
              ),

              pw.SizedBox(height: 20),

              // ================= SUMMARY =================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Total Amount: ${indianR.format(transaction.totalAmount)}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Paid Amount: ${indianR.format(transaction.amountReceived)}",
                      ),
                      pw.Text(
                        "Balance Due: ${indianR.format(transaction.balance)}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // ================= FOOTER =================
              pw.Center(
                child: pw.Text(
                  "Thank you for your business!",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name:
      'Bill_${transaction.personName}_${DateFormat('yyyyMMdd').format(transaction.date)}',
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
