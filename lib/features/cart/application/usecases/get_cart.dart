import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';

/// Use Case: Get Current Cart
/// Retrieves the current active cart
class GetCart {
  final ICartRepository repository;
  
  GetCart(this.repository);
  
  Future<Either<Failure, Cart>> execute() async {
    return await repository.getCurrentCart();
  }
}
