import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/constants.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/value_objects/discount.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_hive_model.dart';

/// Hive implementation of ICartRepository
/// Handles all local database operations for the cart
class HiveCartRepository implements ICartRepository {
  final Box<CartHiveModel> _box;
  static const String _cartKey = 'current_cart';
  
  HiveCartRepository(this._box);
  
  @override
  Future<Either<Failure, Cart>> getCurrentCart() async {
    try {
      final model = _box.get(_cartKey);
      
      if (model == null) {
        // Retornar carrito vacío
        return Right(_createEmptyCart());
      }
      
      return Right(model.toEntity());
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'get_cart',
        message: 'Failed to get cart from database',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> addItem(CartItem item) async {
    try {
      final currentCartResult = await getCurrentCart();
      
      return currentCartResult.fold(
        (failure) => Left(failure),
        (cart) async {
          // Verificar si el producto ya está en el carrito
          final existingIndex = cart.items.indexWhere(
            (existing) => 
                existing.product.id == item.product.id && 
                existing.unitPrice == item.unitPrice
          );
          
          List<CartItem> updatedItems;
          
          if (existingIndex >= 0) {
            // Incrementar cantidad
            final existingItem = cart.items[existingIndex];
            final updatedItem = existingItem.copyWith(
              quantity: existingItem.quantity + item.quantity
            );
            updatedItems = List<CartItem>.from(cart.items)
              ..[existingIndex] = updatedItem;
          } else {
            // Agregar nuevo ítem
            updatedItems = [...cart.items, item];
          }
          
          final updatedCart = cart.copyWith(
            items: updatedItems,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'add_item',
        message: 'Failed to add item to cart',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> updateItemQuantity(String itemId, int quantity) async {
    try {
      final currentCartResult = await getCurrentCart();
      
      return currentCartResult.fold(
        (failure) => Left(failure),
        (cart) async {
          final updatedItems = cart.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(quantity: quantity);
            }
            return item;
          }).toList();
          
          final updatedCart = cart.copyWith(
            items: updatedItems,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'update_quantity',
        message: 'Failed to update item quantity',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> removeItem(String itemId) async {
    try {
      final currentCartResult = await getCurrentCart();
      
      return currentCartResult.fold(
        (failure) => Left(failure),
        (cart) async {
          final updatedItems = cart.items.where((item) => item.id != itemId).toList();
          
          final updatedCart = cart.copyWith(
            items: updatedItems,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'remove_item',
        message: 'Failed to remove item from cart',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> applyDiscount(Discount discount) async {
    try {
      final currentCartResult = await getCurrentCart();
      
      return currentCartResult.fold(
        (failure) => Left(failure),
        (cart) async {
          // Validar que el descuento no exceda el subtotal
          final discountAmount = discount.calculateDiscountAmount(cart.subtotal);
          
          if (discountAmount > cart.subtotal) {
            return Left(const CartOperationFailure(
              'apply_discount',
              message: 'Discount amount cannot exceed cart subtotal',
            ));
          }
          
          final updatedCart = cart.copyWith(
            discount: discount,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'apply_discount',
        message: 'Failed to apply discount',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> clearDiscount() async {
    try {
      final currentCartResult = await getCurrentCart();
      
      return currentCartResult.fold(
        (failure) => Left(failure),
        (cart) async {
          final updatedCart = cart.copyWith(
            discount: null,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'clear_discount',
        message: 'Failed to clear discount',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await _box.delete(_cartKey);
      return right(unit);
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'clear_cart',
        message: 'Failed to clear cart',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> saveCart(Cart cart) async {
    try {
      final model = CartHiveModel.fromEntity(cart);
      await _box.put(_cartKey, model);
      return right(unit);
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'save_cart',
        message: 'Failed to save cart',
        exception: e,
      ));
    }
  }
  
  Cart _createEmptyCart() {
    return Cart(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
