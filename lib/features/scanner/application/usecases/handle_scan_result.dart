import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/scan_result.dart';
import 'lookup_product_by_barcode.dart';

/// Use Case: Handle Scan Result
/// Facade use case that handles a scanned barcode by looking up the product
///
/// This use case provides a cleaner interface for the BLoC by delegating
/// to the LookupProductByBarcode use case.
class HandleScanResult {
  final LookupProductByBarcode lookupProduct;

  const HandleScanResult(this.lookupProduct);

  Future<Either<Failure, ScanResult>> execute(String barcode) async {
    // Delegate to lookup product use case
    return await lookupProduct.execute(barcode);
  }
}
