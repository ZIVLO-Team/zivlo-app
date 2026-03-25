import 'package:equatable/equatable.dart';

/// Base class for all domain failures
/// Used with fpdart's Either<Failure, T> pattern
abstract class Failure extends Equatable {
  final String message;
  final Exception? exception;

  const Failure({required this.message, this.exception});

  @override
  List<Object?> get props => [message, exception];
  
  @override
  String toString() => 'Failure(message: $message, exception: $exception)';
}

/// Failure when a product is not found by barcode or ID
class ProductNotFound extends Failure {
  final String identifier;
  
  const ProductNotFound(this.identifier) 
    : super(message: 'Product not found with identifier: $identifier');
  
  @override
  List<Object?> get props => [identifier, message];
}

/// Failure when cart operations fail
class CartOperationFailure extends Failure {
  final String operation;
  
  const CartOperationFailure(this.operation, {String? message, Exception? exception})
    : super(message: message ?? 'Cart operation failed: $operation', exception: exception);
  
  @override
  List<Object?> get props => [operation, message, exception];
}

/// Failure when printer connection fails
class PrinterConnectionFailure extends Failure {
  final String? deviceAddress;
  
  const PrinterConnectionFailure({this.deviceAddress, String? message, Exception? exception})
    : super(message: message ?? 'Failed to connect to printer: $deviceAddress', exception: exception);
  
  @override
  List<Object?> get props => [deviceAddress, message, exception];
}

/// Failure when printer printing fails
class PrinterPrintFailure extends Failure {
  const PrinterPrintFailure({String? message, Exception? exception})
    : super(message: message ?? 'Failed to print receipt', exception: exception);
}

/// Failure when printer operations fail
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

/// Failure when scanner fails
class ScannerFailure extends Failure {
  const ScannerFailure({String? message, Exception? exception})
    : super(message: message ?? 'Scanner error occurred', exception: exception);
}

/// Failure when sale creation fails
class SaleCreationFailure extends Failure {
  const SaleCreationFailure({String? message, Exception? exception})
    : super(message: message ?? 'Failed to create sale', exception: exception);
}

/// Failure when business config is not set
class BusinessConfigNotSet extends Failure {
  const BusinessConfigNotSet() : super(message: 'Business configuration is not set');
}

/// Generic failure for unknown errors
class UnknownFailure extends Failure {
  const UnknownFailure({String? message, Exception? exception})
    : super(message: message ?? 'An unknown error occurred', exception: exception);
}
