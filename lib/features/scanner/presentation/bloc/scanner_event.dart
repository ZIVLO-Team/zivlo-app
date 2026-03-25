import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_result.dart';

/// Scanner Event - Base class
/// All scanner events extend this class
abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Event: User started scanning
/// Dispatched when the scanner page is initialized
/// and the camera should start
class ScannerStarted extends ScannerEvent {
  const ScannerStarted();

  @override
  List<Object?> get props => [];
}

/// Event: User stopped scanning
/// Dispatched when the user closes the scanner
/// or navigates away
class ScannerStopped extends ScannerEvent {
  const ScannerStopped();

  @override
  List<Object?> get props => [];
}

/// Event: Barcode detected
/// Dispatched when a barcode is scanned by the camera
/// Contains the raw barcode value
class BarcodeScanned extends ScannerEvent {
  final String barcode;

  const BarcodeScanned(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

/// Event: Product lookup completed
/// Dispatched by the BLoC after looking up the product
/// Contains the scan result with product info (or null if not found)
class ProductLookupCompleted extends ScannerEvent {
  final ScanResult result;

  const ProductLookupCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

/// Event: Flash toggled
/// Dispatched when the user toggles the flash
/// Contains the new flash state
class FlashToggled extends ScannerEvent {
  final bool enabled;

  const FlashToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event: Scanner error occurred
/// Dispatched when an error happens during scanning
/// Contains the error message
class ScannerError extends ScannerEvent {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event: Add to cart requested
/// Dispatched when the user wants to add the scanned
/// product to the cart
class AddToCartRequested extends ScannerEvent {
  final ScanResult result;
  final int quantity;

  const AddToCartRequested({
    required this.result,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [result, quantity];
}
