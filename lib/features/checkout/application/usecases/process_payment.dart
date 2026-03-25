import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/value_objects/payment.dart';
import '../../domain/value_objects/payment_method.dart';

/// Use Case: Process Payment
/// 
/// Handles the complete payment process:
/// 1. Validates payment amount >= total
/// 2. Creates Sale entity with all items
/// 3. Saves sale to repository
/// 4. Clears cart
/// 5. Returns Either<Failure, Sale>
/// 
/// This is the main use case for completing a transaction
class ProcessPayment {
  final ICheckoutRepository checkoutRepository;
  final ICartRepository cartRepository;
  final Uuid uuid;

  const ProcessPayment({
    required this.checkoutRepository,
    required this.cartRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// Executes the payment process
  /// 
  /// [payment] - Payment information with method and amounts
  /// 
  /// Returns [Sale] on success, [Failure] on error
  Future<Either<Failure, Sale>> execute(Payment payment) async {
    // Validate payment amount
    final validation = _validatePayment(payment);
    if (validation.isLeft()) {
      return validation;
    }

    try {
      // Get cart items
      final cartItemsResult = await cartRepository.getItems();
      if (cartItemsResult.isLeft()) {
        return left(CartOperationFailure('get_items', 
          message: 'Failed to get cart items'));
      }
      final cartItems = cartItemsResult.getOrElse(() => []);

      if (cartItems.isEmpty) {
        return left(const CartOperationFailure('empty_cart', 
          message: 'Cannot process payment with empty cart'));
      }

      // Get cart totals
      final subtotalResult = await cartRepository.getSubtotal();
      final discountResult = await cartRepository.getDiscount();
      final totalResult = await cartRepository.getTotal();

      final subtotal = subtotalResult.getOrElse(() => 0.0);
      final discount = discountResult.getOrElse(() => 0.0);
      final total = totalResult.getOrElse(() => 0.0);

      // Create sale items from cart items
      final saleItems = cartItems.map((cartItem) {
        return SaleItem(
          id: uuid.v4(),
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          barcode: cartItem.product.barcode,
          quantity: cartItem.quantity,
          unitPrice: cartItem.product.price,
          subtotal: cartItem.subtotal,
        );
      }).toList();

      // Calculate change for cash/mixed payments
      double? change;
      if (payment.method == PaymentMethod.cash || 
          payment.method == PaymentMethod.mixed) {
        change = payment.change;
      }

      // Create Sale entity
      final sale = Sale(
        id: uuid.v4(),
        items: saleItems,
        subtotal: subtotal,
        discount: discount,
        total: total,
        paymentMethod: payment.method,
        amountReceived: payment.method == PaymentMethod.card ? null : payment.amountReceived,
        change: change,
        createdAt: DateTime.now(),
      );

      // Save sale to repository
      final saveResult = await checkoutRepository.createSale(sale);
      if (saveResult.isLeft()) {
        return saveResult;
      }

      // Clear cart
      final clearResult = await cartRepository.clear();
      if (clearResult.isLeft()) {
        // Sale was saved but cart couldn't be cleared
        // This is a recoverable error - log it but return the sale
        // The cart will be cleared on next app start or manually
      }

      // Return the created sale
      return right(sale);

    } catch (e) {
      return left(SaleCreationFailure(
        message: 'Failed to process payment: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  /// Validates payment amount
  Either<Failure, Unit> _validatePayment(Payment payment) {
    final totalReceived = payment.totalReceived;
    
    if (totalReceived < payment.totalAmount) {
      return left(const PaymentValidationFailure(
        'Insufficient payment amount',
      ));
    }

    return right(unit);
  }
}

/// Failure for payment validation errors
class PaymentValidationFailure extends Failure {
  const PaymentValidationFailure(super.message);
}
