import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../application/usecases/product_usecases.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

/// Catalog BLoC - Business Logic Component
/// Handles all catalog-related business logic
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetProductByBarcode getProductByBarcode;
  final GetAllProducts getAllProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;
  final SearchProducts searchProducts;
  
  CatalogBloc({
    required this.getAllProducts,
    required this.getProductByBarcode,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.searchProducts,
  }) : super(CatalogInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadProductByBarcode>(_onLoadProductByBarcode);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<ClearSearch>(_onClearSearch);
  }
  
  /// Handler: Load all products
  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());
    
    final result = await getAllProducts.execute();
    
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (products) {
        final categories = _extractCategories(products);
        emit(CatalogLoaded(
          products: products,
          filteredProducts: products,
          categories: categories,
        ));
      },
    );
  }
  
  /// Handler: Load product by barcode
  Future<void> _onLoadProductByBarcode(
    LoadProductByBarcode event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());
    
    final result = await getProductByBarcode.execute(event.barcode);
    
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (product) {
        if (product != null) {
          final currentState = state;
          if (currentState is CatalogLoaded) {
            final updatedProducts = [product, ...currentState.products];
            emit(currentState.copyWith(
              products: updatedProducts,
              filteredProducts: updatedProducts,
            ));
          }
        } else {
          emit(CatalogError('Product not found with barcode: ${event.barcode}'));
        }
      },
    );
  }
  
  /// Handler: Create product
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());
    
    final product = event.product.toEntity(
      _generateId(),
      DateTime.now(),
    );
    
    final result = await createProduct.execute(product);
    
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (createdProduct) {
        final currentState = state;
        if (currentState is CatalogLoaded) {
          final updatedProducts = [createdProduct, ...currentState.products];
          final categories = _extractCategories(updatedProducts);
          emit(CatalogLoaded(
            products: updatedProducts,
            filteredProducts: updatedProducts,
            categories: categories,
          ));
        }
        emit(ProductCreatedSuccess(createdProduct));
      },
    );
  }
  
  /// Handler: Update product
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());
    
    // Get existing product to preserve createdAt
    final existingResult = await getAllProducts.execute();
    
    Product? existingProduct;
    existingResult.fold(
      (_) => null,
      (products) {
        existingProduct = products.firstWhere(
          (p) => p.id == event.product.id,
          orElse: () => Product(
            id: '',
            name: '',
            price: 0,
            stock: 0,
            createdAt: DateTime.now(),
          ),
        );
      },
    );
    
    if (existingProduct == null || existingProduct!.id.isEmpty) {
      emit(CatalogError('Product not found'));
      return;
    }
    
    final product = event.product.toEntity(
      existingProduct!.id,
      existingProduct.createdAt,
    );
    
    final result = await updateProduct.execute(product);
    
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (updatedProduct) {
        final currentState = state;
        if (currentState is CatalogLoaded) {
          final updatedProducts = currentState.products
              .map((p) => p.id == updatedProduct.id ? updatedProduct : p)
              .toList();
          final categories = _extractCategories(updatedProducts);
          emit(CatalogLoaded(
            products: updatedProducts,
            filteredProducts: updatedProducts,
            categories: categories,
          ));
        }
        emit(ProductUpdatedSuccess(updatedProduct));
      },
    );
  }
  
  /// Handler: Delete product
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<CatalogState> emit,
  ) async {
    final result = await deleteProduct.execute(event.productId);
    
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (_) {
        final currentState = state;
        if (currentState is CatalogLoaded) {
          final updatedProducts = currentState.products
              .where((p) => p.id != event.productId)
              .toList();
          final categories = _extractCategories(updatedProducts);
          emit(CatalogLoaded(
            products: updatedProducts,
            filteredProducts: updatedProducts,
            categories: categories,
          ));
        }
        emit(ProductDeletedSuccess(event.productId));
      },
    );
  }
  
  /// Handler: Search products
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<CatalogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CatalogLoaded) return;
    
    if (event.query.trim().isEmpty) {
      emit(currentState.copyWith(filteredProducts: currentState.products));
      return;
    }
    
    final result = await searchProducts.execute(event.query);
    
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (products) {
        emit(currentState.copyWith(filteredProducts: products));
      },
    );
  }
  
  /// Handler: Clear search
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<CatalogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CatalogLoaded) return;
    
    emit(currentState.copyWith(filteredProducts: currentState.products));
  }
  
  /// Helper: Extract unique categories from products
  List<String> _extractCategories(List<Product> products) {
    return products
        .map((p) => p.category)
        .where((c) => c != null && c.trim().isNotEmpty)
        .map((c) => c!.trim())
        .toSet()
        .toList()
      ..sort();
  }
  
  /// Helper: Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
