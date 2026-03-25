import 'package:equatable/equatable.dart';
import 'package:zivlo/features/catalog/domain/entities/product.dart';
/// Catalog State - Base class
abstract class CatalogState extends Equatable {
  const CatalogState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class CatalogInitial extends CatalogState {
  @override
  List<Object?> get props => [];
}

/// Loading state
class CatalogLoading extends CatalogState {
  @override
  List<Object?> get props => [];
}

/// Loaded state with products
class CatalogLoaded extends CatalogState {
  final List<Product> products;
  final List<Product> filteredProducts;  // For search results
  final List<String> categories;
  
  const CatalogLoaded({
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
  });
  
  CatalogLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<String>? categories,
  }) {
    return CatalogLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
    );
  }
  
  @override
  List<Object?> get props => [products, filteredProducts, categories];
}

/// Error state
class CatalogError extends CatalogState {
  final String message;
  
  const CatalogError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Product created successfully
class ProductCreatedSuccess extends CatalogState {
  final Product product;
  
  const ProductCreatedSuccess(this.product);
  
  @override
  List<Object?> get props => [product];
}

/// Product updated successfully
class ProductUpdatedSuccess extends CatalogState {
  final Product product;
  
  const ProductUpdatedSuccess(this.product);
  
  @override
  List<Object?> get props => [product];
}

/// Product deleted successfully
class ProductDeletedSuccess extends CatalogState {
  final String productId;
  
  const ProductDeletedSuccess(this.productId);
  
  @override
  List<Object?> get props => [productId];
}
