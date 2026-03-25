import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/value_objects/discount.dart';
import '../../../catalog/domain/entities/product.dart';

/// Cart Event - Base class
abstract class CartEvent extends Equatable {
  const CartEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event: Load current cart
class LoadCart extends CartEvent {
  @override
  List<Object?> get props => [];
}

/// Event: Add item to cart
class AddItemToCart extends CartEvent {
  final Product product;
  final int quantity;
  
  const AddItemToCart(this.product, this.quantity);
  
  @override
  List<Object?> get props => [product, quantity];
}

/// Event: Remove item from cart
class RemoveItem extends CartEvent {
  final String itemId;
  
  const RemoveItem(this.itemId);
  
  @override
  List<Object?> get props => [itemId];
}

/// Event: Undo remove item (for undo functionality)
class UndoRemoveItemEvent extends CartEvent {
  @override
  List<Object?> get props => [];
}

/// Event: Update item quantity
class UpdateItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;
  
  const UpdateItemQuantity(this.itemId, this.quantity);
  
  @override
  List<Object?> get props => [itemId, quantity];
}

/// Event: Apply discount
class ApplyDiscountEvent extends CartEvent {
  final Discount discount;
  
  const ApplyDiscountEvent(this.discount);
  
  @override
  List<Object?> get props => [discount];
}

/// Event: Clear discount
class ClearDiscountEvent extends CartEvent {
  @override
  List<Object?> get props => [];
}

/// Event: Clear cart
class ClearCartEvent extends CartEvent {
  @override
  List<Object?> get props => [];
}
