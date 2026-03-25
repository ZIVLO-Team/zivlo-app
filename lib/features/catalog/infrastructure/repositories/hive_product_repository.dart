import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_hive_model.dart';

/// Hive implementation of IProductRepository
/// Handles all local database operations for products
class HiveProductRepository implements IProductRepository {
  final Box<ProductHiveModel> _box;
  final Uuid _uuid;

  HiveProductRepository(this._box, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<Product>>> getAll() async {
    try {
      final products = _box.values
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first

      return Right(products);
    } catch (e) {
      return Left(CartOperationFailure(
        'get_all_products',
        message: 'Failed to get products from database',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, Product?>> getById(String id) async {
    try {
      final model = _box.get(id);

      if (model == null) {
        return Right(null);
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(CartOperationFailure(
        'get_product_by_id',
        message: 'Failed to get product by ID',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, Product?>> getByBarcode(String barcode) async {
    try {
      // Search by barcode in all products
      final products = _box.values.where((model) {
        return model.barcode != null &&
            model.barcode!.trim().toLowerCase() == barcode.trim().toLowerCase();
      });

      if (products.isEmpty) {
        return Right(null);
      }

      return Right(products.first.toEntity());
    } catch (e) {
      return Left(CartOperationFailure(
        'get_product_by_barcode',
        message: 'Failed to get product by barcode',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, Product>> create(Product product) async {
    try {
      // Generate unique ID if not provided
      final id = product.id.isNotEmpty ? product.id : _uuid.v4();

      final model = ProductHiveModel.fromEntity(product.copyWith(id: id));

      await _box.put(id, model);

      return Right(model.toEntity());
    } catch (e) {
      return Left(CartOperationFailure(
        'create_product',
        message: 'Failed to create product',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, Product>> update(Product product) async {
    try {
      // Check if product exists
      final existing = _box.get(product.id);

      if (existing == null) {
        return Left(ProductNotFound(product.id));
      }

      // Update product
      final model = ProductHiveModel.fromEntity(product);
      await _box.put(product.id, model);

      return Right(model.toEntity());
    } catch (e) {
      return Left(CartOperationFailure(
        'update_product',
        message: 'Failed to update product',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    try {
      // Check if product exists
      final existing = _box.get(id);

      if (existing == null) {
        return Left(ProductNotFound(id));
      }

      await _box.delete(id);

      return right(unit);
    } catch (e) {
      return Left(CartOperationFailure(
        'delete_product',
        message: 'Failed to delete product',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> search(String query) async {
    try {
      final queryLower = query.trim().toLowerCase();

      final products = _box.values.where((model) {
        final nameMatch = model.name.toLowerCase().contains(queryLower);
        final barcodeMatch = model.barcode != null &&
            model.barcode!.toLowerCase().contains(queryLower);
        final categoryMatch = model.category != null &&
            model.category!.toLowerCase().contains(queryLower);

        return nameMatch || barcodeMatch || categoryMatch;
      }).map((model) => model.toEntity()).toList();

      return Right(products);
    } catch (e) {
      return Left(CartOperationFailure(
        'search_products',
        message: 'Failed to search products',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getByCategory(String category) async {
    try {
      final categories = _box.values
          .map((model) => model.category)
          .where((category) => category != null && category.trim().isNotEmpty)
          .map((category) => category!.trim())
          .toSet()
          .toList()
        ..sort();

      return Right(categories);
    } catch (e) {
      return Left(CartOperationFailure(
        'get_all_categories',
        message: 'Failed to get categories',
        exception: e as Exception,
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    return getByCategory('');
  }
}
