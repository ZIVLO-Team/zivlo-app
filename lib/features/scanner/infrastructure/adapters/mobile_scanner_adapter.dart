import 'package:fpdart/fpdart.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/value_objects/barcode_format.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/ports/scanner_port.dart';

/// Mobile Scanner Adapter
/// Implementation of IScannerPort using the mobile_scanner package
/// Handles camera operations, barcode detection, and flash control
class MobileScannerAdapter implements IScannerPort {
  final MobileScannerController _controller;
  final _scanResultsController =
      StreamController<Either<Failure, ScanResult>>.broadcast();

  /// Creates a new MobileScannerAdapter
  /// 
  /// Optionally accepts a [controller] for testing purposes.
  /// If not provided, a default MobileScannerController is created.
  MobileScannerAdapter({MobileScannerController? controller})
      : _controller = controller ?? MobileScannerController();

  @override
  Either<Failure, Unit> startScanning() {
    try {
      // Start the camera
      _controller.start();

      // Listen to barcode events
      _controller.events.listen((event) {
        if (event.barcodes.isNotEmpty) {
          final barcode = event.barcodes.first;
          final rawValue = barcode.rawValue;
          
          // Skip empty barcodes
          if (rawValue == null || rawValue.isEmpty) {
            return;
          }

          final scanResult = ScanResult(
            barcode: rawValue,
            format: _mapBarcodeFormat(barcode.format),
            product: null, // Product is looked up in the use case
            scannedAt: DateTime.now(),
          );
          _scanResultsController.add(Right(scanResult));
        }

        // Handle scanner errors
        if (event.error != null) {
          _scanResultsController.add(Left(
            ScannerFailure(
              message: 'Scanner error: ${event.error}',
              exception: Exception(event.error),
            ),
          ));
        }
      });

      return right(unit);
    } on MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to start scanner: ${e.message}',
        exception: e,
      ));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to start scanner: ${e.toString()}',
        exception: e as Exception,
      ));
    }
  }

  @override
  Either<Failure, Unit> stopScanning() {
    try {
      // Stop the camera
      _controller.stop();
      
      // Close the stream controller
      if (!_scanResultsController.isClosed) {
        _scanResultsController.close();
      }

      return right(unit);
    } on MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to stop scanner: ${e.message}',
        exception: e,
      ));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to stop scanner: ${e.toString()}',
        exception: e as Exception,
      ));
    }
  }

  @override
  Stream<Either<Failure, ScanResult>> get scanResults => _scanResultsController.stream;

  @override
  Either<Failure, Unit> toggleFlash(bool enabled) {
    try {
      // Check if torch is available before toggling
      if (!_controller.hasTorch) {
        return Left(ScannerFailure(
          message: 'Device does not have a flash',
        ));
      }

      _controller.toggleFlashlight(on: enabled);
      return right(unit);
    } on MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to toggle flash: ${e.message}',
        exception: e,
      ));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to toggle flash: ${e.toString()}',
        exception: e as Exception,
      ));
    }
  }

  @override
  Either<Failure, bool> isFlashAvailable() {
    try {
      final hasTorch = _controller.hasTorch;
      return Right(hasTorch);
    } on MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to check flash availability: ${e.message}',
        exception: e,
      ));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to check flash availability: ${e.toString()}',
        exception: e as Exception,
      ));
    }
  }

  /// Maps MobileScannerBarcodeType to our BarcodeFormat enum
  BarcodeFormat _mapBarcodeFormat(MobileScannerBarcodeType format) {
    switch (format) {
      case MobileScannerBarcodeType.ean13:
        return BarcodeFormat.ean13;
      case MobileScannerBarcodeType.ean8:
        return BarcodeFormat.ean8;
      case MobileScannerBarcodeType.qrCode:
        return BarcodeFormat.qrCode;
      case MobileScannerBarcodeType.code128:
        return BarcodeFormat.code128;
      case MobileScannerBarcodeType.code39:
        return BarcodeFormat.code39;
      case MobileScannerBarcodeType.upcA:
        return BarcodeFormat.upcA;
      case MobileScannerBarcodeType.upcE:
        return BarcodeFormat.upcA; // Treat UPC-E as UPC-A
      case MobileScannerBarcodeType.codabar:
      case MobileScannerBarcodeType.itf:
      case MobileScannerBarcodeType.dataMatrix:
      case MobileScannerBarcodeType.aztec:
      case MobileScannerBarcodeType.pdf417:
      case MobileScannerBarcodeType.unknown:
      default:
        return BarcodeFormat.unknown;
    }
  }
}
