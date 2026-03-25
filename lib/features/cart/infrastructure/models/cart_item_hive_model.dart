import 'package:hive/hive.dart';
import '../../domain/entities/cart_item.dart';
import 'product_snapshot_hive_model.dart';

part 'cart_item_hive_model.g.dart';

/// Hive Data Model for CartItem
/// Stores a snapshot of the product at the time of adding to cart
@HiveType(typeId: 2)
class CartItemHiveModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late ProductSnapshotHiveModel product;  // Snapshot completo
  
  @HiveField(2)
  late int quantity;
  
  @HiveField(3)
  late double unitPrice;
  
  CartItemHiveModel();
  
  /// Creates model from domain entity
  factory CartItemHiveModel.fromEntity(CartItem item) {
    final model = CartItemHiveModel()
      ..id = item.id
      ..product = ProductSnapshotHiveModel.fromEntity(item.product)
      ..quantity = item.quantity
      ..unitPrice = item.unitPrice;
    
    return model;
  }
  
  /// Converts model to domain entity
  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product.toEntity(),
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
  
  @override
  String toString() {
    return 'CartItemHiveModel(id: $id, product: ${product.name}, quantity: $quantity)';
  }
}
