import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/product.dart';

/// Cart Item Entity
/// Represents an item in the shopping cart
class CartItem {
  final String id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  /// Returns the subtotal for this item (price * quantity)
  double get subtotal => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Cart Repository Port (Interface)
/// Defines what the domain layer needs from the infrastructure layer
/// for cart operations
abstract class ICartRepository {
  /// Returns all items in the cart
  Future<Either<Failure, List<CartItem>>> getItems();

  /// Returns the total number of items in the cart
  Future<Either<Failure, int>> getItemCount();

  /// Returns the cart subtotal (sum of all items before discount)
  Future<Either<Failure, double>> getSubtotal();

  /// Returns the cart total (after discount if any)
  Future<Either<Failure, double>> getTotal();

  /// Returns the discount applied to the cart
  Future<Either<Failure, double>> getDiscount();

  /// Adds a product to the cart
  /// [quantity] defaults to 1 if not specified
  Future<Either<Failure, CartItem>> addProduct(Product product, {int quantity = 1});

  /// Updates the quantity of a cart item
  Future<Either<Failure, CartItem>> updateQuantity(String itemId, int quantity);

  /// Removes an item from the cart
  Future<Either<Failure, Unit>> removeItem(String itemId);

  /// Clears all items from the cart
  Future<Either<Failure, Unit>> clear();

  /// Applies a discount to the cart
  /// [discount] can be absolute value or percentage based on [isPercentage]
  Future<Either<Failure, double>> applyDiscount(double discount, {bool isPercentage = false});

  /// Removes any applied discount
  Future<Either<Failure, Unit>> removeDiscount();
}
