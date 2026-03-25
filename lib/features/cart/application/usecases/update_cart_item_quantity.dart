import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/repositories/cart_repository.dart';

/// Use Case: Update Cart Item Quantity
/// Updates the quantity of an existing cart item
class UpdateCartItemQuantity {
  final ICartRepository repository;
  
  UpdateCartItemQuantity(this.repository);
  
  Future<Either<Failure, Cart>> execute(String itemId, int quantity) async {
    // Validaciones
    if (itemId.trim().isEmpty) {
      return Left(const CartOperationFailure(
        'update_quantity',
        message: 'Invalid item ID',
      ));
    }
    
    if (quantity < 1) {
      return Left(const CartOperationFailure(
        'update_quantity',
        message: 'Quantity must be at least 1',
      ));
    }
    
    return await repository.updateItemQuantity(itemId, quantity);
  }
}
