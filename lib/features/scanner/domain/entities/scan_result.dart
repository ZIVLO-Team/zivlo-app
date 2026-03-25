import 'package:equatable/equatable.dart';
import '../../../../core/domain/value_objects/barcode_format.dart';
import '../../../catalog/domain/entities/product.dart';

/// Scan Result Entity
/// Represents the result of a barcode scan operation
/// Immutable - changes create a new instance
class ScanResult extends Equatable {
  /// The raw barcode value that was scanned
  final String barcode;

  /// The detected format of the barcode
  final BarcodeFormat format;

  /// The product found in the catalog, if any
  /// Null if no matching product was found
  final Product? product;

  /// The timestamp when the scan occurred
  final DateTime scannedAt;

  const ScanResult({
    required this.barcode,
    required this.format,
    this.product,
    required this.scannedAt,
  });

  /// Returns true if a product was found for this barcode
  bool get isProductFound => product != null;

  /// Returns true if no product was found for this barcode
  bool get isProductNotFound => product == null;

  /// Creates a copy of this ScanResult with updated fields
  ScanResult copyWith({
    String? barcode,
    BarcodeFormat? format,
    Product? product,
    DateTime? scannedAt,
  }) {
    return ScanResult(
      barcode: barcode ?? this.barcode,
      format: format ?? this.format,
      product: product ?? this.product,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  List<Object?> get props => [barcode, format, product, scannedAt];

  @override
  String toString() {
    final productInfo = product != null 
        ? 'product: ${product!.name}' 
        : 'product: not found';
    return 'ScanResult(barcode: $barcode, format: ${format.name}, $productInfo, scannedAt: $scannedAt)';
  }
}
