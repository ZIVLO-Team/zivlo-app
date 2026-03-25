import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

/// Use Case: Remove Item from Cart
/// Removes an item from the cart by its ID
class RemoveFromCart {
  final ICartRepository repository;
  
  RemoveFromCart(this.repository);
  
  Future<Either<Failure, Cart>> execute(String itemId) async {
    // Validar ID
    if (itemId.trim().isEmpty) {
      return Left(const CartOperationFailure(
        'remove_from_cart',
        message: 'Invalid item ID',
      ));
    }
    
    return await repository.removeItem(itemId);
  }
}

/// Use Case: Undo Remove Item
/// Re-adds a previously removed item (for undo functionality)
class UndoRemoveItem {
  final ICartRepository repository;
  
  UndoRemoveItem(this.repository);
  
  Future<Either<Failure, Cart>> execute(CartItem removedItem) async {
    // Re-agregar el ítem eliminado
    return await repository.addItem(removedItem);
  }
}
