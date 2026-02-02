import 'package:hive/hive.dart';

part 'transaction_item.g.dart';

@HiveType(typeId: 1)
class TransactionItem extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final double unitPrice;

  @HiveField(3)
  final double totalPrice;

  TransactionItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  }) : totalPrice = quantity * unitPrice;
}
