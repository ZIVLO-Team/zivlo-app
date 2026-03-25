import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

/// CartItem Entity
/// Represents an item in the shopping cart
/// Immutable - changes create a new instance
class CartItem extends Equatable {
  final String id;                    // UUID del ítem
  final Product product;              // Snapshot del producto al momento de agregar
  final int quantity;                 // Cantidad seleccionada (mínimo 1)
  final double unitPrice;             // Precio unitario al momento de agregar (inmutable)
  
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });
  
  /// Subtotal del ítem (precio × cantidad)
  double get subtotal => unitPrice * quantity;
  
  /// Crea una nueva instancia del ítem con cambios
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,  // Nunca cambiar por defecto
    );
  }
  
  @override
  List<Object?> get props => [id, product, quantity, unitPrice];
  
  @override
  String toString() {
    return 'CartItem(id: $id, product: ${product.name}, quantity: $quantity, subtotal: $subtotal)';
  }
}
