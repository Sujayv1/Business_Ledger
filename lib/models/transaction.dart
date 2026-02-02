import 'package:hive/hive.dart';
import 'transaction_item.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double productPrice;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String personName;

  @HiveField(5)
  double amountReceived;

  @HiveField(6)
  double balance;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  String personPhone;

  @HiveField(9)
  List<TransactionItem> items;

  Transaction({
    required this.id,
    this.productName = '',
    this.productPrice = 0.0,
    required this.date,
    required this.personName,
    required this.amountReceived,
    required this.timestamp,
    this.personPhone = '',
    List<TransactionItem>? items,
  }) : items = items ?? [],
       balance = (items != null && items.isNotEmpty 
          ? items.fold(0.0, (sum, item) => sum + item.totalPrice) 
          : productPrice) - amountReceived;
          
  double get totalAmount {
    if (items.isNotEmpty) {
      return items.fold(0, (sum, item) => sum + item.totalPrice);
    }
    return productPrice;
  }
  
  void updateBalance() {
    balance = totalAmount - amountReceived;
  }
}
