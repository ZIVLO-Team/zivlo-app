import 'package:equatable/equatable.dart';

/// ProductName Value Object
/// Encapsulates product name validation
class ProductName extends Equatable {
  final String value;
  
  const ProductName._(this.value);
  
  /// Factory constructor with validation
  factory ProductName(String value) {
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      throw const FormatException('Product name cannot be empty');
    }
    
    if (trimmed.length > 60) {
      throw const FormatException('Product name cannot exceed 60 characters');
    }
    
    return ProductName._(trimmed);
  }
  
  /// Creates a ProductName without validation (for internal use)
  factory ProductName.unsafe(String value) {
    return ProductName._(value);
  }
  
  /// Returns the name in uppercase for display
  String get uppercase => value.toUpperCase();
  
  /// Returns the name in title case
  String get titleCase {
    return value
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => 'ProductName($value)';
}
