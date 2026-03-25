import 'package:equatable/equatable.dart';
import 'barcode_format.dart';

/// Barcode Value Object
/// Encapsulates barcode validation, format detection, and comparison
/// Shared between catalog and scanner features
class Barcode extends Equatable {
  final String value;
  final BarcodeFormat format;

  const Barcode._(this.value, this.format);

  /// Factory constructor with validation and automatic format detection
  factory Barcode.create(String rawValue) {
    // Validate barcode is not empty
    if (rawValue.trim().isEmpty) {
      throw const FormatException('Barcode cannot be empty');
    }

    final trimmed = rawValue.trim();
    final format = _detectFormat(trimmed);

    return Barcode._(trimmed, format);
  }

  /// Creates a Barcode without validation (for internal/testing use)
  factory Barcode.unsafe(String value, [BarcodeFormat format = BarcodeFormat.unknown]) {
    return Barcode._(value, format);
  }

  /// Returns true if this barcode has a known format
  bool get isValid => format != BarcodeFormat.unknown;

  /// Detects the barcode format based on length and pattern
  static BarcodeFormat _detectFormat(String value) {
    // EAN-13: exactly 13 digits
    if (value.length == 13 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeFormat.ean13;
    }

    // EAN-8: exactly 8 digits
    if (value.length == 8 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeFormat.ean8;
    }

    // UPC-A: exactly 12 digits
    if (value.length == 12 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeFormat.upcA;
    }

    // QR Code: can be various lengths, often starts with specific patterns
    // This is a simplified detection - real QR detection is more complex
    if (value.length >= 1 && value.length <= 4296 && 
        (value.startsWith('http') || value.contains('\n') || value.length > 100)) {
      return BarcodeFormat.qrCode;
    }

    // Code 128: alphanumeric, 1-80 characters
    // Can contain letters, numbers, and some special characters
    if (value.length >= 1 && value.length <= 80 && 
        RegExp(r'^[a-zA-Z0-9\s\-\.\$\+\%\@\#\!\^\&\*\(\)\{\}\[\]\,\/\?\!]+$').hasMatch(value)) {
      // Code 128 often starts with specific control characters in raw format
      // For simplicity, we'll check if it's not Code 39
      return BarcodeFormat.code128;
    }

    // Code 39: alphanumeric, typically starts and ends with asterisk (*)
    if (value.startsWith('*') && value.endsWith('*') && 
        RegExp(r'^\*[a-zA-Z0-9 \$\-\.\%\/\+]+\*$').hasMatch(value)) {
      return BarcodeFormat.code39;
    }

    // Code 39 without asterisks (some scanners strip them)
    if (value.length >= 1 && value.length <= 43 && 
        RegExp(r'^[a-zA-Z0-9 \$\-\.\%\/\+]+$').hasMatch(value)) {
      return BarcodeFormat.code39;
    }

    // Unknown format
    return BarcodeFormat.unknown;
  }

  /// Returns a human-readable format name
  String get formatName {
    switch (format) {
      case BarcodeFormat.ean13: return 'EAN-13';
      case BarcodeFormat.ean8: return 'EAN-8';
      case BarcodeFormat.qrCode: return 'QR Code';
      case BarcodeFormat.code128: return 'Code 128';
      case BarcodeFormat.code39: return 'Code 39';
      case BarcodeFormat.upcA: return 'UPC-A';
      case BarcodeFormat.unknown: return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [value, format];

  @override
  String toString() => 'Barcode(value: $value, format: ${formatName})';
}
