import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/product.dart';

part 'product_hive_model.g.dart';

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
