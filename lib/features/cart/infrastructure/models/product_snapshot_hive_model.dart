import 'package:hive_flutter/hive_flutter.dart';
import '../../../../catalog/domain/entities/product.dart';

part 'product_snapshot_hive_model.g.dart';

/// Hive Data Model for Product Snapshot in Cart
/// Stores a copy of product data at the time of adding to cart
/// This ensures price changes don't affect existing cart items
@HiveType(typeId: 4)
class ProductSnapshotHiveModel extends HiveObject {
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
  
  ProductSnapshotHiveModel();
  
  /// Creates model from domain entity
  factory ProductSnapshotHiveModel.fromEntity(Product product) {
    final model = ProductSnapshotHiveModel()
      ..id = product.id
      ..name = product.name
      ..price = product.price
      ..barcode = product.barcode
      ..category = product.category;
    
    return model;
  }
  
  /// Converts model to domain entity
  Product toEntity() {
    // Creamos un producto con fecha arbitraria (no relevante para el carrito)
    return Product(
      id: id,
      name: name,
      price: price,
      barcode: barcode,
      category: category,
      stock: 0,  // Stock no es relevante para el snapshot
      createdAt: DateTime(2024),  // Fecha placeholder
    );
  }
  
  @override
  String toString() {
    return 'ProductSnapshotHiveModel(id: $id, name: $name, price: $price)';
  }
}
