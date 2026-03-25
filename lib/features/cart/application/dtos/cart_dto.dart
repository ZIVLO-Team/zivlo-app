import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/value_objects/discount.dart';

/// Cart DTO (Data Transfer Object)
/// Used for transferring data between layers
class CartDTO extends Equatable {
  final String? id;
  final List<CartItemDTO> items;
  final DiscountDTO? discount;
  
  const CartDTO({
    this.id,
    this.items = const [],
    this.discount,
  });
  
  /// Converts DTO to Entity
  Cart toEntity(DateTime createdAt, DateTime updatedAt) {
    return Cart(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      items: items.map((itemDto) => itemDto.toEntity()).toList(),
      discount: discount?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  /// Creates DTO from Entity
  factory CartDTO.fromEntity(Cart cart) {
    return CartDTO(
      id: cart.id,
      items: cart.items.map((item) => CartItemDTO.fromEntity(item)).toList(),
      discount: cart.discount != null ? DiscountDTO.fromEntity(cart.discount!) : null,
    );
  }
  
  @override
  List<Object?> get props => [id, items, discount];
}

/// CartItem DTO
class CartItemDTO extends Equatable {
  final String id;
  final CartItemProductDTO product;  // Producto simplificado para DTO
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
      product: product.toEntity(),
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
  
  /// Creates DTO from Entity
  factory CartItemDTO.fromEntity(CartItem item) {
    return CartItemDTO(
      id: item.id,
      product: CartItemProductDTO.fromEntity(item.product),
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    );
  }
  
  @override
  List<Object?> get props => [id, product, quantity, unitPrice];
}

/// Simplified Product DTO for CartItem
class CartItemProductDTO extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? barcode;
  final String? category;
  
  const CartItemProductDTO({
    required this.id,
    required this.name,
    required this.price,
    this.barcode,
    this.category,
  });
  
  /// Converts DTO to Entity
  CartItemProductDTO toEntity() {
    // Nota: Esto crea un producto parcial, solo para snapshot en el carrito
    // Usamos DateTime.min para createdAt ya que no es relevante en el carrito
    return CartItemProductDTO(
      id: id,
      name: name,
      price: price,
      barcode: barcode,
      category: category,
    ).toFullProduct();
  }
  
  /// Creates DTO from Entity
  factory CartItemProductDTO.fromEntity(dynamic product) {
    return CartItemProductDTO(
      id: product.id,
      name: product.name,
      price: product.price,
      barcode: product.barcode,
      category: product.category,
    );
  }
  
  /// Creates a full Product entity (import from catalog)
  dynamic toFullProduct() {
    // Esto requiere importar la entidad Product del catálogo
    // Se deja como método placeholder para evitar importación circular
    throw UnimplementedError('Use catalog domain to create full Product');
  }
  
  @override
  List<Object?> get props => [id, name, price, barcode, category];
}

/// Discount DTO
class DiscountDTO extends Equatable {
  final DiscountType type;
  final double value;
  
  const DiscountDTO({
    required this.type,
    required this.value,
  });
  
  /// Converts DTO to Entity
  Discount toEntity() {
    switch (type) {
      case DiscountType.percentage:
        return Discount.percentage(value);
      case DiscountType.fixed:
        return Discount.fixed(value);
    }
  }
  
  /// Creates DTO from Entity
  factory DiscountDTO.fromEntity(Discount discount) {
    return DiscountDTO(
      type: discount.type,
      value: discount.value,
    );
  }
  
  @override
  List<Object?> get props => [type, value];
}

/// Discount Type Enum
enum DiscountType { percentage, fixed }
