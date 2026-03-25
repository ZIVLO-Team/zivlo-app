import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../entities/product.dart';

/// Use Case: Get Product by Barcode
/// Retrieves a product from the repository using its barcode
class GetProductByBarcode {
  final IProductRepository repository;
  
  const GetProductByBarcode(this.repository);
  
  Future<Either<Failure, Product?>> execute(String barcode) async {
    // Validate barcode is not empty
    if (barcode.trim().isEmpty) {
      return Left(const ProductNotFound('empty barcode'));
    }
    
    // Call repository
    return await repository.getByBarcode(barcode);
  }
}

/// Use Case: Get All Products
/// Retrieves all products from the repository
class GetAllProducts {
  final IProductRepository repository;
  
  const GetAllProducts(this.repository);
  
  Future<Either<Failure, List<Product>>> execute() async {
    return await repository.getAll();
  }
}

/// Use Case: Create Product
/// Creates a new product in the repository
class CreateProduct {
  final IProductRepository repository;
  
  const CreateProduct(this.repository);
  
  Future<Either<Failure, Product>> execute(Product product) async {
    // Validate product
    if (!product.isValid) {
      return Left(const CartOperationFailure('create_product', message: 'Invalid product data'));
    }
    
    // Check if barcode already exists (if provided)
    if (product.barcode != null && product.barcode!.trim().isNotEmpty) {
      final existing = await repository.getByBarcode(product.barcode!);
      
      return existing.fold(
        (failure) => Left(failure),
        (productFound) {
          if (productFound != null) {
            return Left(const ProductNotFound('barcode already exists'));
          }
          return Right(product);
        },
      );
    }
    
    // Create product
    return await repository.create(product);
  }
}

/// Use Case: Update Product
/// Updates an existing product in the repository
class UpdateProduct {
  final IProductRepository repository;
  
  const UpdateProduct(this.repository);
  
  Future<Either<Failure, Product>> execute(Product product) async {
    // Validate product
    if (!product.isValid) {
      return Left(const CartOperationFailure('update_product', message: 'Invalid product data'));
    }
    
    // Check if product exists
    final existing = await repository.getById(product.id);
    
    return existing.fold(
      (failure) => Left(failure),
      (productFound) {
        if (productFound == null) {
          return Left(ProductNotFound(product.id));
        }
        return Right(product);
      },
    );
  }
}

/// Use Case: Delete Product
/// Deletes a product from the repository by ID
class DeleteProduct {
  final IProductRepository repository;
  
  const DeleteProduct(this.repository);
  
  Future<Either<Failure, Unit>> execute(String id) async {
    // Validate ID is not empty
    if (id.trim().isEmpty) {
      return Left(const ProductNotFound('empty id'));
    }
    
    // Check if product exists
    final existing = await repository.getById(id);
    
    return existing.fold(
      (failure) => Left(failure),
      (productFound) {
        if (productFound == null) {
          return Left(ProductNotFound(id));
        }
        return Right(unit);
      },
    );
  }
}

/// Use Case: Search Products
/// Searches products by name or barcode
class SearchProducts {
  final IProductRepository repository;
  
  const SearchProducts(this.repository);
  
  Future<Either<Failure, List<Product>>> execute(String query) async {
    // Validate query is not empty
    if (query.trim().isEmpty) {
      return Right([]);  // Return empty list for empty query
    }
    
    // Search
    return await repository.search(query);
  }
}
