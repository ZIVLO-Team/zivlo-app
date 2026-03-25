import 'package:equatable/equatable.dart';

/// Money Value Object
/// Encapsulates monetary value with precision
class Money extends Equatable {
  final double amount;
  
  const Money._(this.amount);
  
  /// Factory constructor with validation
  factory Money(double amount) {
    if (amount < 0) {
      throw const FormatException('Money amount cannot be negative');
    }
    
    // Round to 2 decimal places
    final rounded = double.parse(amount.toStringAsFixed(2));
    
    return Money._(rounded);
  }
  
  /// Creates Money from cents (integer)
  factory Money.fromCents(int cents) {
    if (cents < 0) {
      throw const FormatException('Cents cannot be negative');
    }
    return Money._(cents / 100);
  }
  
  /// Creates Money without validation (for internal use)
  factory Money.unsafe(double amount) {
    return Money._(amount);
  }
  
  /// Returns amount in cents
  int get cents => (amount * 100).round();
  
  /// Returns formatted string with currency symbol
  String get formatted => '\$${amount.toStringAsFixed(2)}';
  
  /// Addition
  Money operator +(Money other) {
    return Money(amount + other.amount);
  }
  
  /// Subtraction
  Money operator -(Money other) {
    return Money(amount - other.amount);
  }
  
  /// Multiplication
  Money operator *(double factor) {
    return Money(amount * factor);
  }
  
  /// Division
  Money operator /(double divisor) {
    return Money(amount / divisor);
  }
  
  /// Equality
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Money && amount == other.amount;
  }
  
  /// Less than
  bool operator <(Money other) => amount < other.amount;
  
  /// Greater than
  bool operator >(Money other) => amount > other.amount;
  
  /// Less than or equal
  bool operator <=(Money other) => amount <= other.amount;
  
  /// Greater than or equal
  bool operator >=(Money other) => amount >= other.amount;
  
  @override
  List<Object?> get props => [amount];
  
  @override
  String toString() => 'Money($amount)';
}
