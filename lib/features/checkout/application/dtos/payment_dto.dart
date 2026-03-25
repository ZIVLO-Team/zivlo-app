import 'package:equatable/equatable.dart';
import 'package:zivlo/features/checkout/domain/value_objects/payment_method.dart';
/// Payment Data Transfer Object
/// Used for transferring payment data between layers
/// 
/// This DTO is used in the application layer to pass payment information
/// without exposing domain entities
class PaymentDTO extends Equatable {
  final PaymentMethod method;
  final double totalAmount;
  final double? amountReceived;
  final double? cardAmount;

  const PaymentDTO({
    required this.method,
    required this.totalAmount,
    this.amountReceived,
    this.cardAmount,
  });

  /// Factory constructor for cash payment DTO
  factory PaymentDTO.cash({
    required double totalAmount,
    required double amountReceived,
  }) {
    return PaymentDTO(
      method: PaymentMethod.cash,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
    );
  }

  /// Factory constructor for card payment DTO
  factory PaymentDTO.card({
    required double totalAmount,
  }) {
    return PaymentDTO(
      method: PaymentMethod.card,
      totalAmount: totalAmount,
    );
  }

  /// Factory constructor for mixed payment DTO
  factory PaymentDTO.mixed({
    required double totalAmount,
    required double cashAmount,
    required double cardAmount,
  }) {
    return PaymentDTO(
      method: PaymentMethod.mixed,
      totalAmount: totalAmount,
      amountReceived: cashAmount,
      cardAmount: cardAmount,
    );
  }

  /// Creates a copy of this PaymentDTO with updated fields
  PaymentDTO copyWith({
    PaymentMethod? method,
    double? totalAmount,
    double? amountReceived,
    double? cardAmount,
  }) {
    return PaymentDTO(
      method: method ?? this.method,
      totalAmount: totalAmount ?? this.totalAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      cardAmount: cardAmount ?? this.cardAmount,
    );
  }

  @override
  List<Object?> get props => [method, totalAmount, amountReceived, cardAmount];

  @override
  String toString() {
    return 'PaymentDTO(method: ${method.name}, total: $totalAmount, '
        'received: $amountReceived, card: $cardAmount)';
  }
}
