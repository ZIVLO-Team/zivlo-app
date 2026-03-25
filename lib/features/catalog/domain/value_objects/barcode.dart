import 'package:equatable/equatable.dart';

/// Barcode Value Object
/// Encapsulates barcode validation and comparison
class Barcode extends Equatable {
  final String value;
  
  const Barcode._(this.value);
  
  /// Factory constructor with validation
  factory Barcode(String value) {
    // Validate barcode format
    if (value.trim().isEmpty) {
      throw const FormatException('Barcode cannot be empty');
    }
    
    // Common barcode formats validation
    final trimmed = value.trim();
    
    // EAN-13: 13 digits
    if (trimmed.length == 13 && RegExp(r'^\d+$').hasMatch(trimmed)) {
      return Barcode._(trimmed);
    }
    
    // EAN-8: 8 digits
    if (trimmed.length == 8 && RegExp(r'^\d+$').hasMatch(trimmed)) {
      return Barcode._(trimmed);
    }
    
    // UPC-A: 12 digits
    if (trimmed.length == 12 && RegExp(r'^\d+$').hasMatch(trimmed)) {
      return Barcode._(trimmed);
    }
    
    // Code128, Code39: alphanumeric (allow as-is)
    if (trimmed.length >= 1 && trimmed.length <= 80) {
      return Barcode._(trimmed);
    }
    
    throw const FormatException('Invalid barcode format');
  }
  
  /// Creates a Barcode without validation (for internal use)
  factory Barcode.unsafe(String value) {
    return Barcode._(value);
  }
  
  /// Returns true if this is an EAN-13 barcode
  bool get isEAN13 => value.length == 13 && RegExp(r'^\d+$').hasMatch(value);
  
  /// Returns true if this is an EAN-8 barcode
  bool get isEAN8 => value.length == 8 && RegExp(r'^\d+$').hasMatch(value);
  
  /// Returns true if this is a UPC-A barcode
  bool get isUPCA => value.length == 12 && RegExp(r'^\d+$').hasMatch(value);
  
  /// Returns the barcode type
  String get type {
    if (isEAN13) return 'EAN-13';
    if (isEAN8) return 'EAN-8';
    if (isUPCA) return 'UPC-A';
    return 'Other';
  }
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => 'Barcode($value)';
}
