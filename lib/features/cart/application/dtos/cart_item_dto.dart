import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

/// CartItem DTO
class CartItemDTO extends Equatable {
  final String id;
  final Product product;  // Usamos la entidad completa, no un DTO
  final int quantity;
  final double unitPrice;
  
  const CartItemDTO({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });
  
  /// Converts DTO to Entity
  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
  
  /// Creates DTO from Entity
  factory CartItemDTO.fromEntity(CartItem item) {
    return CartItemDTO(
      id: item.id,
      product: item.product,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    );
  }
  
  @override
  List<Object?> get props => [id, product, quantity, unitPrice];
}
