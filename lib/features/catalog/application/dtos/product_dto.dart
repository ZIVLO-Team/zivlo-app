import 'package:equatable/equatable.dart';
import 'package:zivlo/features/catalog/domain/entities/product.dart';

/// Product DTO (Data Transfer Object)
/// Used for transferring data between layers
class ProductDTO extends Equatable {
  final String? id;
  final String name;
  final double price;
  final String? barcode;
  final String? category;
  final int stock;

  const ProductDTO({
    this.id,
    required this.name,
    required this.price,
    this.barcode,
    this.category,
    required this.stock,
  });

  /// Converts DTO to Entity
  /// Requires ID and createdAt to be set
  Product toEntity(String id, DateTime createdAt) {
    return Product(
      id: id,
      name: name,
      price: price,
      barcode: barcode,
      category: category,
      stock: stock,
      createdAt: createdAt,
    );
  }

  /// Creates DTO from Entity
  factory ProductDTO.fromEntity(Product product) {
    return ProductDTO(
      id: product.id,
      name: product.name,
      price: product.price,
      barcode: product.barcode,
      category: product.category,
      stock: product.stock,
    );
  }

  @override
  List<Object?> get props => [id, name, price, barcode, category, stock];
}
