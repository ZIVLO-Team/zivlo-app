/// Core exceptions for the application
/// Note: Exceptions should only be used in infrastructure and presentation layers
/// Domain layer uses Failure objects with Either pattern

/// Exception thrown when data is not found
class NotFoundException implements Exception {
  final String message;
  final String? identifier;
  
  const NotFoundException(this.message, {this.identifier});
  
  @override
  String toString() => 'NotFoundException: $message (identifier: $identifier)';
}

/// Exception thrown when local database operations fail
class LocalDatabaseException implements Exception {
  final String message;
  final String? operation;
  
  const LocalDatabaseException(this.message, {this.operation});
  
  @override
  String toString() => 'LocalDatabaseException: $message (operation: $operation)';
}

/// Exception thrown when Bluetooth operations fail
class BluetoothException implements Exception {
  final String message;
  final String? deviceAddress;
  
  const BluetoothException(this.message, {this.deviceAddress});
  
  @override
  String toString() => 'BluetoothException: $message (device: $deviceAddress)';
}

/// Exception thrown when camera/scanner operations fail
class ScannerException implements Exception {
  final String message;
  final String? errorCode;
  
  const ScannerException(this.message, {this.errorCode});
  
  @override
  String toString() => 'ScannerException: $message (code: $errorCode)';
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final String field;
  final String message;
  
  const ValidationException(this.field, this.message);
  
  @override
  String toString() => 'ValidationException: $field - $message';
}
