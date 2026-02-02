import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  Box<Transaction>? _box;

  TransactionProvider();

  List<Transaction> get transactions => _transactions;

  // Analytics
  double get totalSales => _transactions.fold(0, (sum, item) => sum + item.totalAmount);
  double get totalReceived => _transactions.fold(0, (sum, item) => sum + item.amountReceived);
  double get totalPending => _transactions.fold(0, (sum, item) => sum + item.balance);

  Future<void> init() async {
    debugPrint("TransactionProvider: init() called");
    // Assumes Hive.initFlutter() is called in main
    try {
      _box = await Hive.openBox<Transaction>('transactions');
      debugPrint("TransactionProvider: Box opened successfully. Length: ${_box?.length}");
    } catch (e) {
      debugPrint("TransactionProvider: Hive Error opening box: $e. Attempting to delete...");
      try {
        await Hive.deleteBoxFromDisk('transactions');
        _box = await Hive.openBox<Transaction>('transactions');
        debugPrint("TransactionProvider: Box recreated successfully.");
      } catch (e2) {
        debugPrint("TransactionProvider: Critical Storage Error recreation failed: $e2");
        _box = null; 
      }
    }
    _updateList();
  }

  void _updateList() {
    if (_box != null) {
      _transactions = _box!.values.toList();
      _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      debugPrint("TransactionProvider: List updated. Count: ${_transactions.length}");
      notifyListeners();
    } else {
      debugPrint("TransactionProvider: Box is null, cannot update list.");
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    debugPrint("TransactionProvider: Adding transaction ${transaction.id}");
    if (_box == null) {
      debugPrint("TransactionProvider: Box is null, re-initializing...");
      await init();
    }
    if (_box != null) {
      await _box!.add(transaction);
      debugPrint("TransactionProvider: Transaction added to box. New length: ${_box!.length}");
      _updateList();
    } else {
      debugPrint("TransactionProvider: FAILED to add transaction. Box is null.");
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await transaction.delete(); // Removes from Hive
    _updateList();
  }

  Future<void> editTransaction(Transaction oldTx, Transaction newTx) async {
    // Since Hive objects are active, we can just save property changes if we modify the object directly.
    // However, since we passed a new object with updated values, we might want to update the old object's fields.
    
    // Better approach: Update fields of oldTx and save.
    oldTx.productName = newTx.productName; // Legacy support
    oldTx.items.clear();
    oldTx.items.addAll(newTx.items);
    oldTx.productPrice = newTx.productPrice; // Legacy
    oldTx.amountReceived = newTx.amountReceived;
    oldTx.personName = newTx.personName;
    oldTx.personPhone = newTx.personPhone;
    oldTx.date = newTx.date;
    // timestamp usually remains creation time, or we can add updatedAt
    
    oldTx.updateBalance();
    await oldTx.save();
    _updateList();
  }
}
