import 'package:fpdart/fpdart.dart';
import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/checkout/domain/entities/sale.dart';

/// Checkout Repository Port (Interface)
/// Defines what the domain layer needs from the infrastructure layer
/// for sale/checkout operations
abstract class ICheckoutRepository {
  /// Creates a new sale record
  /// Returns the created sale on success
  Future<Either<Failure, Sale>> createSale(Sale sale);

  /// Returns a sale by its ID
  Future<Either<Failure, Sale?>> getSaleById(String id);

  /// Returns all sales
  /// Optionally filtered by date range
  Future<Either<Failure, List<Sale>>> getAllSales({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Returns sales for today
  Future<Either<Failure, List<Sale>>> getTodaysSales();

  /// Returns the total number of sales
  Future<Either<Failure, int>> getSalesCount();

  /// Returns total revenue (sum of all sales)
  Future<Either<Failure, double>> getTotalRevenue();

  /// Returns total revenue for today
  Future<Either<Failure, double>> getTodaysRevenue();

  /// Deletes a sale by ID (for corrections/voids)
  /// Use with caution - should only be used for legitimate corrections
  Future<Either<Failure, Unit>> deleteSale(String id);

  /// Returns sales by payment method
  Future<Either<Failure, List<Sale>>> getSalesByPaymentMethod(String paymentMethod);
}
