import 'package:hive_flutter/hive_flutter.dart';
import 'package:zivlo/features/checkout/domain/entities/sale_item.dart';
/// Hive Data Model for SaleItem
/// This is a DTO for Hive storage, separate from domain entity
class SaleItemHiveModel {
  late String id;
  late String productId;
  late String productName;
  String? barcode;
  late int quantity;
  late double unitPrice;
  late double subtotal;

  SaleItemHiveModel();

  /// Creates model from domain entity
  factory SaleItemHiveModel.fromEntity(SaleItem item) {
    final model = SaleItemHiveModel()
      ..id = item.id
      ..productId = item.productId
      ..productName = item.productName
      ..barcode = item.barcode
      ..quantity = item.quantity
      ..unitPrice = item.unitPrice
      ..subtotal = item.subtotal;

    return model;
  }

  /// Converts model to domain entity
  SaleItem toEntity() {
    return SaleItem(
      id: id,
      productId: productId,
      productName: productName,
      barcode: barcode,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
    );
  }

  /// Serializes this model to a list for Hive storage
  List<dynamic> toJson() {
    return [
      id,
      productId,
      productName,
      barcode,
      quantity,
      unitPrice,
      subtotal,
    ];
  }

  /// Deserializes from Hive storage
  static SaleItemHiveModel fromJson(List<dynamic> data) {
    return SaleItemHiveModel()
      ..id = data[0] as String
      ..productId = data[1] as String
      ..productName = data[2] as String
      ..barcode = data[3] as String?
      ..quantity = data[4] as int
      ..unitPrice = (data[5] as num).toDouble()
      ..subtotal = (data[6] as num).toDouble();
  }

  @override
  String toString() {
    return 'SaleItemHiveModel(id: $id, productName: $productName, quantity: $quantity)';
  }
}

/// Manual TypeAdapter for SaleItemHiveModel
class SaleItemHiveModelAdapter extends TypeAdapter<SaleItemHiveModel> {
  @override
  final int typeId = 1;

  @override
  SaleItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItemHiveModel()
      ..id = fields[0] as String
      ..productId = fields[1] as String
      ..productName = fields[2] as String
      ..barcode = fields[3] as String?
      ..quantity = fields[4] as int
      ..unitPrice = (fields[5] as num).toDouble()
      ..subtotal = (fields[6] as num).toDouble();
  }

  @override
  void write(BinaryWriter writer, SaleItemHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unitPrice)
      ..writeByte(6)
      ..write(obj.subtotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
