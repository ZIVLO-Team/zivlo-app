import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/value_objects/barcode_format.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../../domain/entities/scan_result.dart';

/// Use Case: Lookup Product by Barcode
/// Looks up a product in the catalog by its barcode
/// and returns a ScanResult entity
///
/// If a product is found, ScanResult.product will contain the product
/// If no product is found, ScanResult.product will be null (not treated as an error)
class LookupProductByBarcode {
  final IProductRepository productRepository;

  const LookupProductByBarcode(this.productRepository);

  Future<Either<Failure, ScanResult>> execute(String barcode) async {
    // Validate barcode is not empty
    if (barcode.trim().isEmpty) {
      return Left(const ProductNotFound('empty barcode'));
    }

    // Lookup product in repository
    final result = await productRepository.getByBarcode(barcode);

    return result.fold(
      (failure) => Left(failure),
      (product) {
        // Return ScanResult with product (may be null)
        // Product not found is NOT an error - it's a valid state
        return Right(ScanResult(
          barcode: barcode,
          format: BarcodeFormat.unknown, // Format will be detected by infrastructure
          product: product,
          scannedAt: DateTime.now(),
        ));
      },
    );
  }
}
