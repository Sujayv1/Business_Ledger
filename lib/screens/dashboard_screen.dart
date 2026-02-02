import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/glass_widgets.dart';
import 'bill_generator_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Bill Generator",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillGeneratorScreen()),
              );
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
             final totalSales = provider.totalSales;
             final totalReceived = provider.totalReceived;
             final totalPending = provider.totalPending;
             
             final hasData = totalSales > 0;
             final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

             return SingleChildScrollView(
               padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
               child: Column(
                 children: [
                   _SummaryCard(title: "Total Sales", value: totalSales, color: Colors.blueAccent),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(child: _SummaryCard(title: "Received", value: totalReceived, color: Colors.greenAccent)),
                       const SizedBox(width: 16),
                       Expanded(child: _SummaryCard(title: "Pending Due", value: totalPending, color: Colors.orangeAccent)),
                     ],
                   ),
                   const SizedBox(height: 32),
                   if (hasData)
                     SizedBox(
                       height: 350,
                       child: GlassContainer(
                         child: Column(
                           children: [
                             const Text(
                               "Income Analysis", 
                               style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                             ),
                             const SizedBox(height: 20),
                             Expanded(
                               child: PieChart(
                                 PieChartData(
                                   sections: [
                                     PieChartSectionData(
                                       value: totalReceived,
                                       color: Colors.greenAccent,
                                       title: totalReceived > 0 ? '${((totalReceived/totalSales)*100).toStringAsFixed(0)}%' : '',
                                       radius: 80,
                                       titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                     ),
                                     PieChartSectionData(
                                       value: totalPending,
                                       color: Colors.orangeAccent,
                                       title: totalPending > 0 ? '${((totalPending/totalSales)*100).toStringAsFixed(0)}%' : '',
                                       radius: 80,
                                       titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                     ),
                                   ],
                                   sectionsSpace: 4,
                                   centerSpaceRadius: 50,
                                   borderData: FlBorderData(show: false),
                                 ),
                               ),
                             ),
                             const SizedBox(height: 16),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 _LegendItem(color: Colors.greenAccent, text: "Received"),
                                 const SizedBox(width: 16),
                                 _LegendItem(color: Colors.orangeAccent, text: "Pending"),
                               ],
                             )
                           ],
                         ),
                       ),
                     )
                   else
                     const Padding(
                       padding: EdgeInsets.only(top: 40),
                       child: Text("Add transactions to see analytics", style: TextStyle(color: Colors.white54)),
                     ),
                 ],
               ),
             );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
           const SizedBox(height: 8),
           Text(
             NumberFormat.currency(symbol: '', decimalDigits: 0).format(value),
             style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
           ),
         ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
