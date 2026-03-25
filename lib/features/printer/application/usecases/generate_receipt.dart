import 'package:fpdart/fpdart.dart';
import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/printer/domain/entities/receipt.dart';
import 'package:zivlo/features/printer/domain/entities/receipt_item.dart';
import 'package:zivlo/features/checkout/domain/entities/sale.dart';
import 'package:zivlo/features/settings/domain/entities/business_info.dart';
/// Use Case: Generate Receipt
///
/// Generates a Receipt entity from a Sale and business information
/// This use case transforms domain entities into print-ready receipt format
///
/// This use case handles:
/// - Extracting business information
/// - Converting sale items to receipt items
/// - Formatting payment method names
/// - Creating receipt with proper metadata
class GenerateReceipt {
  const GenerateReceipt();

  /// Executes receipt generation
  ///
  /// [sale] - The completed sale entity
  /// [businessInfo] - Business configuration for header/footer
  ///
  /// Returns [Receipt] on success
  /// Returns [Failure] if required data is missing
  Either<Failure, Receipt> execute(Sale sale, BusinessInfo businessInfo) {
    try {
      // Convert sale items to receipt items
      final receiptItems = sale.items.map((saleItem) {
        return ReceiptItem(
          name: saleItem.productName,
          quantity: saleItem.quantity,
          unitPrice: saleItem.unitPrice,
          subtotal: saleItem.subtotal,
        );
      }).toList();

      // Format payment method name for display
      final paymentMethodDisplay = _formatPaymentMethod(sale.paymentMethod.name);

      // Generate receipt number from sale ID (last 6 chars for brevity)
      final receiptNumber = sale.id.length > 6
          ? sale.id.substring(sale.id.length - 6).toUpperCase()
          : sale.id.toUpperCase();

      // Create receipt entity
      final receipt = Receipt(
        businessName: businessInfo.name,
        businessTaxId: businessInfo.taxId,
        businessAddress: businessInfo.address,
        receiptHeader: businessInfo.receiptHeader,
        receiptFooter: businessInfo.receiptFooter,
        items: receiptItems,
        subtotal: sale.subtotal,
        discount: sale.discount,
        total: sale.total,
        paymentMethod: paymentMethodDisplay,
        change: sale.change,
        receiptNumber: receiptNumber,
        createdAt: sale.createdAt,
      );

      return Right(receipt);
    } catch (e) {
      return Left(ReceiptGenerationFailure(
        message: 'Failed to generate receipt: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  /// Formats payment method enum name to display string
  String _formatPaymentMethod(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'mixed':
        return 'Mixto';
      default:
        return methodName.capitalize();
    }
  }
}

/// Failure for receipt generation errors
class ReceiptGenerationFailure extends Failure {
  const ReceiptGenerationFailure({String? message, Exception? exception})
      : super(message: message ?? 'Failed to generate receipt', exception: exception);
}

/// Failure for printer operation errors
class PrinterOperationFailure extends Failure {
  final String operation;

  const PrinterOperationFailure({
    required this.operation,
    String? message,
    Exception? exception,
  }) : super(message: message ?? 'Printer operation failed: $operation', exception: exception);

  @override
  List<Object?> get props => [operation, message, exception];
}
