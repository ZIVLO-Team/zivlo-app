import 'package:equatable/equatable.dart';
import 'sale_item.dart';
import '../value_objects/payment_method.dart';

/// Sale Entity
/// Represents an immutable transaction record after payment is completed
/// 
/// This is a snapshot of the sale at the time of transaction
/// All monetary values are in base currency (no cents conversion)
class Sale extends Equatable {
  /// Unique identifier for the sale
  final String id;

  /// List of items sold (snapshot of cart items at time of sale)
  final List<SaleItem> items;

  /// Subtotal before discount
  final double subtotal;

  /// Discount applied (0 if no discount)
  final double discount;

  /// Final total after discount
  final double total;

  /// Payment method used
  final PaymentMethod paymentMethod;

  /// Amount received from customer (for cash/mixed payments)
  /// Null for pure card payments
  final double? amountReceived;

  /// Change returned to customer (for cash/mixed payments)
  /// Null for pure card payments
  final double? change;

  /// Timestamp when the sale was created
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.amountReceived,
    this.change,
    required this.createdAt,
  });

  /// Returns true if this is a cash-only payment
  bool get isCashPayment => paymentMethod == PaymentMethod.cash;

  /// Returns true if this is a card-only payment
  bool get isCardPayment => paymentMethod == PaymentMethod.card;

  /// Returns true if this is a mixed payment (cash + card)
  bool get isMixedPayment => paymentMethod == PaymentMethod.mixed;

  /// Returns the number of items in this sale
  int get itemCount => items.length;

  /// Returns the total quantity of all items
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Creates a copy of this Sale with updated fields
  Sale copyWith({
    String? id,
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? total,
    PaymentMethod? paymentMethod,
    double? amountReceived,
    double? change,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: amountReceived ?? this.amountReceived,
      change: change ?? this.change,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns formatted subtotal for display
  String get formattedSubtotal {
    return '\$${subtotal.toStringAsFixed(2)}';
  }

  /// Returns formatted discount for display
  String get formattedDiscount {
    if (discount <= 0) return '\$0.00';
    return '-\$${discount.toStringAsFixed(2)}';
  }

  /// Returns formatted total for display
  String get formattedTotal {
    return '\$${total.toStringAsFixed(2)}';
  }

  /// Returns formatted amount received for display
  String get formattedAmountReceived {
    if (amountReceived == null) return '\$0.00';
    return '\$${amountReceived!.toStringAsFixed(2)}';
  }

  /// Returns formatted change for display
  String get formattedChange {
    if (change == null) return '\$0.00';
    return '\$${change!.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        items,
        subtotal,
        discount,
        total,
        paymentMethod,
        amountReceived,
        change,
        createdAt,
      ];

  @override
  String toString() {
    return 'Sale(id: $id, total: $total, paymentMethod: ${paymentMethod.name}, '
        'items: ${items.length}, createdAt: $createdAt)';
  }
}
