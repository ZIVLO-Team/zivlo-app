import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

/// Product Repository Port (Interface)
/// Defines what the domain layer needs from the infrastructure layer
/// Implementation is done in infrastructure layer (e.g., HiveProductRepository)
abstract class IProductRepository {
  /// Returns all products
  Future<Either<Failure, List<Product>>> getAll();
  
  /// Returns a product by its ID
  Future<Either<Failure, Product?>> getById(String id);
  
  /// Returns a product by its barcode
  Future<Either<Failure, Product?>> getByBarcode(String barcode);
  
  /// Creates a new product
  Future<Either<Failure, Product>> create(Product product);
  
  /// Updates an existing product
  Future<Either<Failure, Product>> update(Product product);
  
  /// Deletes a product by ID
  Future<Either<Failure, Unit>> deleteById(String id);
  
  /// Searches products by name or barcode
  Future<Either<Failure, List<Product>>> search(String query);
  
  /// Returns products by category
  Future<Either<Failure, List<Product>>> getByCategory(String category);
  
  /// Returns all categories
  Future<Either<Failure, List<String>>> getAllCategories();
}
