import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/glass_widgets.dart';
import '../utils/pdf_helper.dart';

class BillGeneratorScreen extends StatelessWidget {
  const BillGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Select Transaction for Bill", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.transactions.isEmpty) {
              return Center(
                child: GlassContainer(
                  child: const Text(
                    "No transactions found.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 80, bottom: 80, left: 16, right: 16),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () async {
                      // Trigger PDF Generation
                      await PdfHelper.generateBill(transaction);
                    },
                    child: _BillTransactionCard(transaction: transaction),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BillTransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _BillTransactionCard({required this.transaction});



  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(transaction.date);
    final indianR = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      name: 'INR',
      decimalDigits: 0,
    );

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.personName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                   'Total: ${indianR.format(transaction.totalAmount)}',
                   style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                )
              ],
            ),
          ),
          const Icon(Icons.picture_as_pdf, color: Colors.white70),
        ],
      ),
    );
  }
}

