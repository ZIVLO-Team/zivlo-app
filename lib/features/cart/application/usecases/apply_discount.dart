import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/value_objects/discount.dart';
import '../../domain/repositories/cart_repository.dart';

/// Use Case: Apply Discount to Cart
/// Applies a discount (percentage or fixed) to the cart
class ApplyDiscount {
  final ICartRepository repository;
  
  ApplyDiscount(this.repository);
  
  Future<Either<Failure, Cart>> execute(Discount discount) async {
    // Validar descuento
    try {
      // Validar que el descuento no sea negativo
      if (discount.value < 0) {
        return Left(const CartOperationFailure(
          'apply_discount',
          message: 'Discount value cannot be negative',
        ));
      }
      
      // Validar porcentaje no exceda 100%
      if (discount.type == DiscountType.percentage && discount.value > 100) {
        return Left(const CartOperationFailure(
          'apply_discount',
          message: 'Percentage discount cannot exceed 100%',
        ));
      }
      
      return await repository.applyDiscount(discount);
    } catch (e) {
      return Left(CartOperationFailure(
        'apply_discount',
        message: 'Invalid discount: ${e.toString()}',
      ));
    }
  }
}
