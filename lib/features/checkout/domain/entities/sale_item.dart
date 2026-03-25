import 'package:equatable/equatable.dart';

/// SaleItem Entity
/// Represents a snapshot of a product item at the time of sale
/// 
/// This is immutable and captures the product state when the sale occurred
/// Used for historical records - price changes in catalog won't affect past sales
class SaleItem extends Equatable {
  /// Unique identifier for this sale item (not the product ID)
  final String id;

  /// Product ID reference (for lookup in catalog)
  final String productId;

  /// Product name at time of sale (snapshot)
  final String productName;

  /// Product barcode at time of sale (snapshot)
  final String? barcode;

  /// Quantity sold
  final int quantity;

  /// Unit price at time of sale (snapshot)
  final double unitPrice;

  /// Subtotal for this item (quantity * unitPrice)
  final double subtotal;

  const SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.barcode,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Returns the total price for this item
  double get totalPrice => subtotal;

  /// Creates a copy of this SaleItem with updated fields
  SaleItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? barcode,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return SaleItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  /// Returns formatted unit price for display
  String get formattedUnitPrice {
    return '\$${unitPrice.toStringAsFixed(2)}';
  }

  /// Returns formatted subtotal for display
  String get formattedSubtotal {
    return '\$${subtotal.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        barcode,
        quantity,
        unitPrice,
        subtotal,
      ];

  @override
  String toString() {
    return 'SaleItem(id: $id, productName: $productName, quantity: $quantity, '
        'unitPrice: $unitPrice, subtotal: $subtotal)';
  }
}
