import 'package:hive_flutter/hive_flutter.dart';
import 'package:zivlo/features/checkout/domain/entities/sale.dart';
import 'package:zivlo/features/checkout/domain/value_objects/payment_method.dart';
import 'sale_item_hive_model.dart';

/// Hive Data Model for Sale
/// This is a DTO for Hive storage, separate from domain entity
class SaleHiveModel {
  late String id;
  late List<SaleItemHiveModel> items;
  late double subtotal;
  late double discount;
  late double total;
  late int paymentMethodIndex;
  double? amountReceived;
  double? change;
  late DateTime createdAt;

  SaleHiveModel();

  /// Creates model from domain entity
  factory SaleHiveModel.fromEntity(Sale sale) {
    final model = SaleHiveModel()
      ..id = sale.id
      ..items = sale.items.map((item) => SaleItemHiveModel.fromEntity(item)).toList()
      ..subtotal = sale.subtotal
      ..discount = sale.discount
      ..total = sale.total
      ..paymentMethodIndex = sale.paymentMethod.index
      ..amountReceived = sale.amountReceived
      ..change = sale.change
      ..createdAt = sale.createdAt;

    return model;
  }

  /// Converts model to domain entity
  Sale toEntity() {
    return Sale(
      id: id,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      discount: discount,
      total: total,
      paymentMethod: PaymentMethod.values[paymentMethodIndex],
      amountReceived: amountReceived,
      change: change,
      createdAt: createdAt,
    );
  }

  /// Serializes this model to a list for Hive storage
  List<dynamic> toJson() {
    return [
      id,
      items.map((item) => item.toJson()).toList(),
      subtotal,
      discount,
      total,
      paymentMethodIndex,
      amountReceived,
      change,
      createdAt,
    ];
  }

  /// Deserializes from Hive storage
  static SaleHiveModel fromJson(List<dynamic> data) {
    final model = SaleHiveModel()
      ..id = data[0] as String
      ..items = (data[1] as List).map((itemData) => 
          SaleItemHiveModel.fromJson(itemData as List)).toList()
      ..subtotal = (data[2] as num).toDouble()
      ..discount = (data[3] as num).toDouble()
      ..total = (data[4] as num).toDouble()
      ..paymentMethodIndex = data[5] as int
      ..amountReceived = data[6] as double?
      ..change = data[7] as double?
      ..createdAt = data[8] as DateTime;

    return model;
  }

  @override
  String toString() {
    return 'SaleHiveModel(id: $id, total: $total, items: ${items.length})';
  }
}

/// Manual TypeAdapter for SaleHiveModel
class SaleHiveModelAdapter extends TypeAdapter<SaleHiveModel> {
  @override
  final int typeId = 2;

  @override
  SaleHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    final itemsData = fields[1] as List;
    final items = itemsData.map((itemData) {
      if (itemData is List) {
        return SaleItemHiveModel.fromJson(itemData);
      }
      // Handle case where items are already deserialized
      return itemData as SaleItemHiveModel;
    }).toList();

    return SaleHiveModel()
      ..id = fields[0] as String
      ..items = items
      ..subtotal = (fields[2] as num).toDouble()
      ..discount = (fields[3] as num).toDouble()
      ..total = (fields[4] as num).toDouble()
      ..paymentMethodIndex = fields[5] as int
      ..amountReceived = fields[6] as double?
      ..change = fields[7] as double?
      ..createdAt = fields[8] as DateTime;
  }

  @override
  void write(BinaryWriter writer, SaleHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.items.map((item) => item.toJson()).toList())
      ..writeByte(2)
      ..write(obj.subtotal)
      ..writeByte(3)
      ..write(obj.discount)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.paymentMethodIndex)
      ..writeByte(6)
      ..write(obj.amountReceived)
      ..writeByte(7)
      ..write(obj.change)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
