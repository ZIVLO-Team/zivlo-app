import 'package:equatable/equatable.dart';
import 'package:zivlo/lib/features/catalog/application/dtos/product_dto.dart';

/// Catalog Event - Base class
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load all products
class LoadAllProducts extends CatalogEvent {
  @override
  List<Object?> get props => [];
}

/// Event: Load product by barcode
class LoadProductByBarcode extends CatalogEvent {
  final String barcode;

  const LoadProductByBarcode(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

/// Event: Create new product
class CreateProductEvent extends CatalogEvent {
  final ProductDTO product;

  const CreateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event: Update existing product
class UpdateProductEvent extends CatalogEvent {
  final ProductDTO product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event: Delete product
class DeleteProductEvent extends CatalogEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event: Search products
class SearchProductsEvent extends CatalogEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event: Clear search results
class ClearSearch extends CatalogEvent {
  @override
  List<Object?> get props => [];
}
