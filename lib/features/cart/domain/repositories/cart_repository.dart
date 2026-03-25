import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../value_objects/discount.dart';

/// Cart Repository Port (Interface)
/// Defines what the domain layer needs from the infrastructure layer
/// Implementation is done in infrastructure layer (e.g., HiveCartRepository)
abstract class ICartRepository {
  /// Obtiene el carrito actual
  Future<Either<Failure, Cart>> getCurrentCart();
  
  /// Agrega un ítem al carrito (o incrementa cantidad si ya existe)
  Future<Either<Failure, Cart>> addItem(CartItem item);
  
  /// Actualiza la cantidad de un ítem
  Future<Either<Failure, Cart>> updateItemQuantity(String itemId, int quantity);
  
  /// Elimina un ítem del carrito
  Future<Either<Failure, Cart>> removeItem(String itemId);
  
  /// Aplica un descuento al carrito
  Future<Either<Failure, Cart>> applyDiscount(Discount discount);
  
  /// Elimina el descuento aplicado
  Future<Either<Failure, Cart>> clearDiscount();
  
  /// Vacía el carrito completamente
  Future<Either<Failure, Unit>> clearCart();
  
  /// Guarda el carrito (usado internamente)
  Future<Either<Failure, Unit>> saveCart(Cart cart);
}
