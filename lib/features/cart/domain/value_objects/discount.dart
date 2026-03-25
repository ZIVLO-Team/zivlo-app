import 'package:equatable/equatable.dart';

/// Discount Value Object
/// Encapsulates discount logic for the cart
/// Can be either percentage-based or fixed amount
class Discount extends Equatable {
  final DiscountType type;
  final double value;
  
  const Discount._({
    required this.type,
    required this.value,
  });
  
  /// Creates a percentage discount (0-100%)
  factory Discount.percentage(double percentage) {
    if (percentage < 0 || percentage > 100) {
      throw const FormatException('Percentage must be between 0 and 100');
    }
    return Discount._(type: DiscountType.percentage, value: percentage);
  }
  
  /// Creates a fixed amount discount
  factory Discount.fixed(double amount) {
    if (amount < 0) {
      throw const FormatException('Fixed amount cannot be negative');
    }
    return Discount._(type: DiscountType.fixed, value: amount);
  }
  
  /// Calculates the discount amount based on subtotal
  double calculateDiscountAmount(double subtotal) {
    switch (type) {
      case DiscountType.percentage:
        return subtotal * (value / 100);
      case DiscountType.fixed:
        // El descuento fijo no puede exceder el subtotal
        return value.clamp(0, subtotal);
    }
  }
  
  /// Returns the formatted discount value for display
  String get formattedValue {
    switch (type) {
      case DiscountType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case DiscountType.fixed:
        return '\$${value.toStringAsFixed(2)}';
    }
  }
  
  @override
  List<Object?> get props => [type, value];
  
  @override
  String toString() {
    return 'Discount(type: $type, value: $value)';
  }
}

/// Discount Type Enum
enum DiscountType { percentage, fixed }
