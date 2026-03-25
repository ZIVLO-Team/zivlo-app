import 'package:equatable/equatable.dart';

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
class CreateProduct extends CatalogEvent {
  final ProductDTO product;
  
  const CreateProduct(this.product);
  
  @override
  List<Object?> get props => [product];
}

/// Event: Update existing product
class UpdateProduct extends CatalogEvent {
  final ProductDTO product;
  
  const UpdateProduct(this.product);
  
  @override
  List<Object?> get props => [product];
}

/// Event: Delete product
class DeleteProduct extends CatalogEvent {
  final String productId;
  
  const DeleteProduct(this.productId);
  
  @override
  List<Object?> get props => [productId];
}

/// Event: Search products
class SearchProducts extends CatalogEvent {
  final String query;
  
  const SearchProducts(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// Event: Clear search results
class ClearSearch extends CatalogEvent {
  @override
  List<Object?> get props => [];
}
