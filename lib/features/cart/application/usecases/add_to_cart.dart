import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../catalog/domain/entities/product.dart';

/// Use Case: Add Item to Cart
/// Adds a product to the cart or increments quantity if it already exists
class AddToCart {
  final ICartRepository repository;
  final Uuid _uuid;
  
  AddToCart(this.repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();
  
  Future<Either<Failure, Cart>> execute(Product product, int quantity) async {
    // Validaciones
    if (quantity < 1) {
      return Left(const CartOperationFailure(
        'add_to_cart',
        message: 'Quantity must be at least 1',
      ));
    }
    
    if (product.price < 0) {
      return Left(const CartOperationFailure(
        'add_to_cart',
        message: 'Invalid product price',
      ));
    }
    
    // Crear CartItem con snapshot del producto
    final cartItem = CartItem(
      id: _uuid.v4(),
      product: product,
      quantity: quantity,
      unitPrice: product.price,  // Precio inmutable
    );
    
    // Agregar al carrito
    return await repository.addItem(cartItem);
  }
}
