import 'package:equatable/equatable.dart';

/// Receipt Item Entity
/// Represents a single line item on a receipt
/// Used for printing thermal receipts
class ReceiptItem extends Equatable {
  /// Product name
  final String name;

  /// Quantity of the item
  final int quantity;

  /// Unit price
  final double unitPrice;

  /// Subtotal for this item (quantity * unitPrice)
  final double subtotal;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Returns formatted quantity for display
  String get formattedQuantity => '${quantity}x';

  /// Returns formatted unit price for display
  String get formattedUnitPrice => '\$${unitPrice.toStringAsFixed(2)}';

  /// Returns formatted subtotal for display
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  /// Creates a copy of this ReceiptItem with updated fields
  ReceiptItem copyWith({
    String? name,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return ReceiptItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  List<Object?> get props => [name, quantity, unitPrice, subtotal];

  @override
  String toString() {
    return 'ReceiptItem(name: $name, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal)';
  }
}
