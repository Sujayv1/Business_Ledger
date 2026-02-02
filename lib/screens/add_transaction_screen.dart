import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../widgets/glass_widgets.dart';
import '../utils/product_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Person Details
  final _personNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Payment Details
  final _receivedController = TextEditingController();
  final _dateController = TextEditingController();
  
  // Item Entry State
  String? _selectedProduct;
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController(); // Unit Price
  
  // List of added items
  List<TransactionItem> _items = [];
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _personNameController.text = tx.personName;
      _phoneController.text = tx.personPhone;
      _receivedController.text = tx.amountReceived.toString();
      _selectedDate = tx.date;
      _items = List.from(tx.items); // Copy items
      
      // Legacy support: if items empty but has productName
      if (_items.isEmpty && tx.productName.isNotEmpty) {
        _items.add(TransactionItem(
          productName: tx.productName,
          quantity: 1,
          unitPrice: tx.productPrice,
        ));
      }
    }
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _phoneController.dispose();
    _receivedController.dispose();
    _dateController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Calculation Helpers
  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get _receivedAmount => double.tryParse(_receivedController.text) ?? 0;
  double get _balance => _totalAmount - _receivedAmount;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
             colorScheme: const ColorScheme.dark(
               primary: Colors.green,
               onPrimary: Colors.white,
               surface: Color(0xFF2C5364),
               onSurface: Colors.white,
             ),
             dialogBackgroundColor: const Color(0xFF2C5364),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addItem() {
    if (_selectedProduct == null) return;
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_priceController.text) ?? 0;

    if (qty <= 0 || unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Quantity or Price")));
      return;
    }

    setState(() {
      _items.add(TransactionItem(
        productName: _selectedProduct!,
        quantity: qty,
        unitPrice: unitPrice,
      ));
      
      // Reset Item Entry
      _selectedProduct = null;
      _quantityController.clear();
      _priceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
       if (_items.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one product")));
         return;
       }

       // Create temporary object with new values
       final newTransaction = Transaction(
         id: widget.transactionToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
         personName: _personNameController.text,
         personPhone: _phoneController.text,
         items: _items,
         amountReceived: _receivedAmount,
         date: _selectedDate,
         timestamp: widget.transactionToEdit?.timestamp ?? DateTime.now(),
       );

       final provider = Provider.of<TransactionProvider>(context, listen: false);
       
       if (widget.transactionToEdit != null) {
         provider.editTransaction(widget.transactionToEdit!, newTransaction);
       } else {
         provider.addTransaction(newTransaction);
       }
       Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.transactionToEdit != null ? "Edit Transaction" : "New Transaction", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Person Details
                GlassContainer(
                   child: Column(
                     children: [
                       GlassTextField(
                         hintText: "Person Name",
                         controller: _personNameController,
                         validator: (v) => v == null || v.isEmpty ? "Required" : null,
                       ),
                       const SizedBox(height: 16),
                       GlassTextField(
                         hintText: "Person Phone",
                         controller: _phoneController,
                         keyboardType: TextInputType.phone,
                       ),
                       const SizedBox(height: 16),
                       GlassTextField(
                         hintText: "Date",
                         controller: _dateController,
                         readOnly: true,
                         onTap: _pickDate,
                       ),
                     ],
                   ),
                ),
                const SizedBox(height: 16),

                // 2. Add Products
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text("Add Products", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 12),
                       // Dropdown
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.white24),
                         ),
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<String>(
                             value: _selectedProduct,
                             hint: const Text("Select Product", style: TextStyle(color: Colors.white54)),
                             dropdownColor: const Color(0xFF203A43),
                             isExpanded: true,
                             style: const TextStyle(color: Colors.white),
                             items: ProductConstants.products.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                             onChanged: (val) => setState(() => _selectedProduct = val),
                           ),
                         ),
                       ),
                       const SizedBox(height: 12),
                       Row(
                         children: [
                           Expanded(
                             child: GlassTextField(
                               hintText: "Qty",
                               controller: _quantityController,
                               keyboardType: TextInputType.number,
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             flex: 2,
                             child: GlassTextField(
                               hintText: "Unit Price",
                               controller: _priceController,
                               keyboardType: TextInputType.number,
                             ),
                           ),
                           const SizedBox(width: 12),
                           IconButton(
                             onPressed: _addItem,
                             icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 32),
                           ),
                         ],
                       ),
                    ],
                  ),
                ),
                
                // 3. Items List
                if (_items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          for (int i=0; i<_items.length; i++)
                            ListTile(
                              title: Text("${_items[i].productName} x ${_items[i].quantity}", style: const TextStyle(color: Colors.white)),
                              subtitle: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(text: "@ ", style: TextStyle(color: Colors.white54)),
                                    TextSpan(text: "${_items[i].unitPrice}", style: const TextStyle(color: Colors.white70)),
                                    const TextSpan(text: "  =  ", style: TextStyle(color: Colors.white54)),
                                    TextSpan(text: "${_items[i].totalPrice}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => _removeItem(i),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // 4. Totals & Payment
                GlassContainer(
                   child: Column(
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const Text("Total Amount", style: TextStyle(color: Colors.white70)),
                           Text("${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       const SizedBox(height: 12),
                       GlassTextField(
                         hintText: "Amount Received",
                         controller: _receivedController,
                         keyboardType: TextInputType.number,
                         // Force rebuild to update balance when user types
                         // Note: We used listener in initState in previous version, adding specific listener here would be better but simple rebuild on keyboard close or similar works. 
                         // Lets add listener in initState actually.
                       ),
                       const SizedBox(height: 12),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const Text("Balance", style: TextStyle(color: Colors.white70)),
                           Text("${_balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ],
                   ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(widget.transactionToEdit != null ? "Update Transaction" : "Save Transaction", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
