import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import '../value_objects/discount.dart';

/// Cart Entity
/// Represents the current shopping cart
/// Immutable - changes create a new instance
class Cart extends Equatable {
  final String id;                    // UUID del carrito
  final List<CartItem> items;         // Lista de ítems
  final Discount? discount;           // Descuento aplicado (opcional)
  final DateTime createdAt;           // Fecha de creación
  final DateTime updatedAt;           // Última actualización
  
  const Cart({
    required this.id,
    this.items = const [],
    this.discount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Subtotal antes de descuento
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  
  /// Monto del descuento
  double get discountAmount {
    if (discount == null) return 0;
    return discount!.calculateDiscountAmount(subtotal);
  }
  
  /// Total final después de descuento
  double get total => subtotal - discountAmount;
  
  /// Cantidad total de ítems (suma de cantidades)
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  /// Verifica si el carrito está vacío
  bool get isEmpty => items.isEmpty;
  
  /// Verifica si el carrito tiene ítems
  bool get isNotEmpty => items.isNotEmpty;
  
  /// Crea una nueva instancia del carrito con cambios
  Cart copyWith({
    String? id,
    List<CartItem>? items,
    Discount? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [id, items, discount, createdAt, updatedAt];
  
  @override
  String toString() {
    return 'Cart(id: $id, items: ${items.length}, total: $total, discount: ${discount?.type})';
  }
}
