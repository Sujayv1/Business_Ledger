import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../widgets/glass_widgets.dart';
import 'add_transaction_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Business Ledger", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GradientBackground(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.transactions.isEmpty) {
              return Center(
                child: GlassContainer(
                  child: const Text(
                    "No transactions yet.\nTap + to add one.",
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
                  child: _TransactionCard(transaction: transaction),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(transaction.date);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Person Name (Top Priority)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaction.personName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                    onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: transaction)),
                       );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmDelete(context, transaction),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Product List
          if (transaction.items.isNotEmpty)
            ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                   const Icon(Icons.circle, size: 6, color: Colors.white54),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       "${item.productName} (x${item.quantity})",
                       style: const TextStyle(color: Colors.white70, fontSize: 14),
                     ),
                   ),
                   Text(
                     NumberFormat.currency(symbol: '', decimalDigits: 0).format(item.totalPrice),
                     style: const TextStyle(color: Colors.white70, fontSize: 14),
                   ),
                ],
              ),
            )).toList()
          else
            // Fallback for legacy data
            Text(
               transaction.productName,
               style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // 3. Metadata (Phone & Date)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.personPhone.isNotEmpty ? "Ph: ${transaction.personPhone}" : "No Phone",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _ValueColumn(label: "Total", value: transaction.totalAmount, color: Colors.blueAccent),
               _ValueColumn(label: "Received", value: transaction.amountReceived, color: Colors.greenAccent),
               _ValueColumn(label: "Balance", value: transaction.balance, color: transaction.balance > 0 ? Colors.orangeAccent : Colors.white60),
            ],
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C5364),
        title: const Text("Delete Transaction?", style: TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(transaction);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ValueColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '', decimalDigits: 0).format(value),
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
