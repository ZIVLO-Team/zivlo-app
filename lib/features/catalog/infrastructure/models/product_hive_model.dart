import 'package:hive_flutter/hive_flutter.dart';
import 'package:zivlo/features/catalog/domain/entities/product.dart';

/// Hive Data Model for Product
/// This is a DTO for Hive storage, separate from domain entity
@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double price;

  @HiveField(3)
  String? barcode;

  @HiveField(4)
  String? category;

  @HiveField(5)
  late int stock;

  @HiveField(6)
  late DateTime createdAt;

  ProductHiveModel();

  /// Creates model from domain entity
  factory ProductHiveModel.fromEntity(Product product) {
    final model = ProductHiveModel()
      ..id = product.id
      ..name = product.name
      ..price = product.price
      ..barcode = product.barcode
      ..category = product.category
      ..stock = product.stock
      ..createdAt = product.createdAt;

    return model;
  }

  /// Converts model to domain entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      barcode: barcode,
      category: category,
      stock: stock,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'ProductHiveModel(id: $id, name: $name, price: $price, barcode: $barcode, stock: $stock)';
  }
}

/// Manual TypeAdapter for ProductHiveModel (without hive_generator)
class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final int typeId = 0;

  @override
  ProductHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHiveModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..price = (fields[2] as num).toDouble()
      ..barcode = fields[3] as String?
      ..category = fields[4] as String?
      ..stock = fields[5] as int
      ..createdAt = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.stock)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
