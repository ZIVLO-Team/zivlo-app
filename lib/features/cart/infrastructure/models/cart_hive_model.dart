import 'package:hive/hive.dart';
import '../../domain/entities/cart.dart';
import 'cart_item_hive_model.dart';
import 'discount_hive_model.dart';

part 'cart_hive_model.g.dart';

/// Hive Data Model for Cart
/// This is a DTO for Hive storage, separate from domain entity
@HiveType(typeId: 1)
class CartHiveModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late List<CartItemHiveModel> items;
  
  @HiveField(2)
  DiscountHiveModel? discount;
  
  @HiveField(3)
  late DateTime createdAt;
  
  @HiveField(4)
  late DateTime updatedAt;
  
  CartHiveModel();
  
  /// Creates model from domain entity
  factory CartHiveModel.fromEntity(Cart cart) {
    final model = CartHiveModel()
      ..id = cart.id
      ..items = cart.items.map((item) => CartItemHiveModel.fromEntity(item)).toList()
      ..discount = cart.discount != null ? DiscountHiveModel.fromEntity(cart.discount!) : null
      ..createdAt = cart.createdAt
      ..updatedAt = cart.updatedAt;
    
    return model;
  }
  
  /// Converts model to domain entity
  Cart toEntity() {
    return Cart(
      id: id,
      items: items.map((item) => item.toEntity()).toList(),
      discount: discount?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'CartHiveModel(id: $id, items: ${items.length}, total: ${toEntity().total})';
  }
}
