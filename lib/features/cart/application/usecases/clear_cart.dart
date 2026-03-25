import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/repositories/cart_repository.dart';

/// Use Case: Clear Cart
/// Removes all items and discount from the cart
class ClearCart {
  final ICartRepository repository;
  
  ClearCart(this.repository);
  
  Future<Either<Failure, Unit>> execute() async {
    return await repository.clearCart();
  }
}
