import 'package:equatable/equatable.dart';
import 'payment_method.dart';

/// Payment Value Object
/// Encapsulates payment information for a transaction
/// 
/// This is a value object that represents the payment details
/// including amount received, change, and payment method
class Payment extends Equatable {
  /// The payment method used
  final PaymentMethod method;

  /// The total amount to pay
  final double totalAmount;

  /// The amount received from customer
  /// For card payments, this is typically equal to totalAmount
  /// For cash payments, this is the cash given by customer
  /// For mixed payments, this is the cash portion
  final double amountReceived;

  /// The change to return to customer
  /// Calculated as: amountReceived - totalAmount (for cash portion)
  final double change;

  /// The card portion amount (for mixed payments)
  /// Null for pure cash or card payments
  final double? cardAmount;

  const Payment({
    required this.method,
    required this.totalAmount,
    required this.amountReceived,
    required this.change,
    this.cardAmount,
  });

  /// Factory constructor for cash payment
  factory Payment.cash({
    required double totalAmount,
    required double amountReceived,
  }) {
    final change = amountReceived - totalAmount;
    return Payment(
      method: PaymentMethod.cash,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      change: change,
    );
  }

  /// Factory constructor for card payment
  factory Payment.card({
    required double totalAmount,
  }) {
    return Payment(
      method: PaymentMethod.card,
      totalAmount: totalAmount,
      amountReceived: totalAmount,
      change: 0,
    );
  }

  /// Factory constructor for mixed payment
  factory Payment.mixed({
    required double totalAmount,
    required double cashAmount,
    required double cardAmount,
  }) {
    final change = cashAmount - (totalAmount - cardAmount);
    return Payment(
      method: PaymentMethod.mixed,
      totalAmount: totalAmount,
      amountReceived: cashAmount,
      change: change,
      cardAmount: cardAmount,
    );
  }

  /// Returns true if payment is complete (amount >= total)
  bool get isComplete => (amountReceived + (cardAmount ?? 0)) >= totalAmount;

  /// Returns the total amount received (cash + card)
  double get totalReceived => amountReceived + (cardAmount ?? 0);

  /// Returns true if change should be given
  bool get hasChange => change > 0;

  /// Creates a copy of this Payment with updated fields
  Payment copyWith({
    PaymentMethod? method,
    double? totalAmount,
    double? amountReceived,
    double? change,
    double? cardAmount,
  }) {
    return Payment(
      method: method ?? this.method,
      totalAmount: totalAmount ?? this.totalAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      change: change ?? this.change,
      cardAmount: cardAmount ?? this.cardAmount,
    );
  }

  /// Returns formatted total amount for display
  String get formattedTotalAmount {
    return '\$${totalAmount.toStringAsFixed(2)}';
  }

  /// Returns formatted amount received for display
  String get formattedAmountReceived {
    return '\$${amountReceived.toStringAsFixed(2)}';
  }

  /// Returns formatted change for display
  String get formattedChange {
    return '\$${change.toStringAsFixed(2)}';
  }

  /// Returns formatted card amount for display (mixed payments)
  String get formattedCardAmount {
    if (cardAmount == null) return '\$0.00';
    return '\$${cardAmount!.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        method,
        totalAmount,
        amountReceived,
        change,
        cardAmount,
      ];

  @override
  String toString() {
    return 'Payment(method: ${method.name}, total: $totalAmount, '
        'received: $amountReceived, change: $change'
        '${cardAmount != null ? ', card: $cardAmount' : ''})';
  }
}
