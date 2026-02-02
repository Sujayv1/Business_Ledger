// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      productName: fields[1] as String,
      productPrice: fields[2] as double,
      date: fields[3] as DateTime,
      personName: fields[4] as String,
      amountReceived: fields[5] as double,
      timestamp: fields[7] as DateTime,
      personPhone: fields[8] as String,
      items: (fields[9] as List?)?.cast<TransactionItem>(),
    )..balance = fields[6] as double;
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.productPrice)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.personName)
      ..writeByte(5)
      ..write(obj.amountReceived)
      ..writeByte(6)
      ..write(obj.balance)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.personPhone)
      ..writeByte(9)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
