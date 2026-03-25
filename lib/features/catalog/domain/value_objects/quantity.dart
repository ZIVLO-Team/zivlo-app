import 'package:equatable/equatable.dart';

/// Quantity Value Object
/// Encapsulates product quantity validation
class Quantity extends Equatable {
  final int value;
  
  const Quantity._(this.value);
  
  /// Factory constructor with validation
  factory Quantity(int value) {
    if (value < 0) {
      throw const FormatException('Quantity cannot be negative');
    }
    return Quantity._(value);
  }
  
  /// Creates Quantity without validation (for internal use)
  factory Quantity.unsafe(int value) {
    return Quantity._(value);
  }
  
  /// Returns true if quantity is zero
  bool get isZero => value == 0;
  
  /// Returns true if quantity is positive
  bool get isPositive => value > 0;
  
  /// Addition
  Quantity operator +(Quantity other) {
    return Quantity(value + other.value);
  }
  
  /// Subtraction
  Quantity operator -(Quantity other) {
    return Quantity(value - other.value);
  }
  
  /// Multiplication
  Quantity operator *(int factor) {
    return Quantity(value * factor);
  }
  
  /// Less than
  bool operator <(Quantity other) => value < other.value;
  
  /// Greater than
  bool operator >(Quantity other) => value > other.value;
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => 'Quantity($value)';
}
