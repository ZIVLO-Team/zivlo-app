import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/scanner/domain/entities/scan_result.dart';
import 'package:zivlo/features/scanner/domain/ports/scanner_port.dart';
import 'package:zivlo/features/scanner/application/usecases/start_scanning.dart';
import 'package:zivlo/features/scanner/application/usecases/stop_scanning.dart';
import 'package:zivlo/features/scanner/application/usecases/handle_scan_result.dart';
import 'package:zivlo/features/scanner/application/usecases/lookup_product_by_barcode.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

/// Scanner BLoC - Business Logic Component
/// Handles all scanner-related business logic
///
/// Manages the scanner state machine:
/// - ScannerInitial -> ScannerActive (on ScannerStarted)
/// - ScannerActive -> ScannerProductFound (on product found)
/// - ScannerActive -> ScannerProductNotFound (on product not found)
/// - ScannerActive -> ScannerErrorState (on error)
/// - Manages flash state (ScannerFlashEnabled/ScannerFlashDisabled)
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  // Use cases
  final StartScanning startScanning;
  final StopScanning stopScanning;
  final HandleScanResult handleScanResult;

  // Port for listening to scan results
  final IScannerPort scannerPort;

  // Stream subscription for scan results
  StreamSubscription<Either<Failure, ScanResult>>? _scanSubscription;

  // Current flash state
  bool _isFlashEnabled = false;

  ScannerBloc({
    required this.startScanning,
    required this.stopScanning,
    required this.handleScanResult,
    required this.scannerPort,
  }) : super(const ScannerInitial()) {
    on<ScannerStarted>(_onScannerStarted);
    on<ScannerStopped>(_onScannerStopped);
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ProductLookupCompleted>(_onProductLookupCompleted);
    on<FlashToggled>(_onFlashToggled);
    on<ScannerError>(_onScannerError);
    on<AddToCartRequested>(_onAddToCartRequested);

    // Subscribe to scan results stream in constructor
    _subscribeToScanResults();
  }

  /// Subscribe to the scanner port's scan results stream
  /// This listens for barcode scans from the infrastructure layer
  void _subscribeToScanResults() {
    _scanSubscription = scannerPort.scanResults.listen((result) {
      result.fold(
        (failure) => add(ScannerError(failure.message)),
        (scanResult) => add(BarcodeScanned(scanResult.barcode)),
      );
    });
  }

  /// Handler: Scanner started
  /// Starts the camera and transitions to ScannerActive state
  Future<void> _onScannerStarted(
    ScannerStarted event,
    Emitter<ScannerState> emit,
  ) async {
    final result = startScanning.execute();

    result.fold(
      (failure) => emit(const ScannerErrorState('Failed to start scanner')),
      (_) {
        emit(const ScannerActive());
      },
    );
  }

  /// Handler: Scanner stopped
  /// Stops the camera and cleans up resources
  Future<void> _onScannerStopped(
    ScannerStopped event,
    Emitter<ScannerState> emit,
  ) async {
    // Cancel the subscription
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    // Stop the scanner
    stopScanning.execute();

    // Reset flash state
    _isFlashEnabled = false;

    // Emit initial state
    emit(const ScannerInitial());
  }

  /// Handler: Barcode scanned
  /// Called when a barcode is detected
  /// Triggers product lookup via handleScanResult use case
  Future<void> _onBarcodeScanned(
    BarcodeScanned event,
    Emitter<ScannerState> emit,
  ) async {
    // Call handleScanResult use case to lookup product
    final result = await handleScanResult.execute(event.barcode);

    result.fold(
      (failure) => emit(ScannerErrorState(failure.message)),
      (scanResult) => add(ProductLookupCompleted(scanResult)),
    );
  }

  /// Handler: Product lookup completed
  /// Transitions to appropriate state based on whether product was found
  Future<void> _onProductLookupCompleted(
    ProductLookupCompleted event,
    Emitter<ScannerState> emit,
  ) async {
    if (event.result.isProductFound) {
      emit(ScannerProductFound(event.result));
    } else {
      emit(ScannerProductNotFound(event.result.barcode));
    }
  }

  /// Handler: Flash toggled
  /// Updates flash state and toggles the flash on the device
  Future<void> _onFlashToggled(
    FlashToggled event,
    Emitter<ScannerState> emit,
  ) async {
    final result = scannerPort.toggleFlash(event.enabled);

    result.fold(
      (failure) {
        // Keep the current state, just emit error message
        _isFlashEnabled = false;
      },
      (_) {
        _isFlashEnabled = event.enabled;
        if (event.enabled) {
          emit(const ScannerFlashEnabled());
        } else {
          emit(const ScannerFlashDisabled());
        }
      },
    );
  }

  /// Handler: Scanner error
  /// Transitions to error state with message
  Future<void> _onScannerError(
    ScannerError event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerErrorState(event.message));
  }

  /// Handler: Add to cart requested
  /// This event is dispatched when the user wants to add
  /// the scanned product to the cart. The actual cart addition
  /// logic is handled by the Cart BLoC.
  ///
  /// This handler can be extended to coordinate with Cart BLoC
  /// or emit a state that triggers navigation to cart.
  Future<void> _onAddToCartRequested(
    AddToCartRequested event,
    Emitter<ScannerState> emit,
  ) async {
    // The actual cart addition is handled by the Cart BLoC
    // This BLoC just acknowledges the request
    // The UI layer should listen for this and dispatch to Cart BLoC
  }

  @override
  Future<void> close() {
    // Clean up subscription when BLoC is closed
    _scanSubscription?.cancel();
    stopScanning.execute();
    return super.close();
  }
}
