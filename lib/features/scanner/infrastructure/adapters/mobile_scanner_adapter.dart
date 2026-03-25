import 'package:fpdart/fpdart.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'dart:async';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/value_objects/barcode_format.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/ports/scanner_port.dart';

/// Mobile Scanner Adapter
/// Implementation of IScannerPort using the mobile_scanner package v5.1.1
/// Handles camera operations, barcode detection, and flash control
class MobileScannerAdapter implements IScannerPort {
  final ms.MobileScannerController _controller;
  final _scanResultsController =
      StreamController<Either<Failure, ScanResult>>.broadcast();

  /// Creates a new MobileScannerAdapter
  ///
  /// Optionally accepts a [controller] for testing purposes.
  /// If not provided, a default MobileScannerController is created.
  MobileScannerAdapter({ms.MobileScannerController? controller})
      : _controller = controller ?? ms.MobileScannerController();

  @override
  Either<Failure, Unit> startScanning() {
    try {
      // Start the camera with barcode callback
      _controller.start();

      // Listen to barcode events using onDetect callback (v5.x API)
      _controller.addListener(() {
        final barcodes = _controller.barcodes;
        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first;
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
      });

      return right(unit);
    } on ms.MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to start scanner: ${e.toString()}',
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
    } on ms.MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to stop scanner: ${e.toString()}',
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
      // Check if torch is available before toggling (v5.x API)
      if (!_controller.torchEnabled) {
        return Left(ScannerFailure(
          message: 'Device does not have a flash',
        ));
      }

      // Use setTorchState instead of toggleFlashlight (v5.x API)
      _controller.setTorchState(enabled ? ms.TorchMode.on : ms.TorchMode.off);
      return right(unit);
    } on ms.MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to toggle flash: ${e.toString()}',
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
      final hasTorch = _controller.torchEnabled;
      return Right(hasTorch);
    } on ms.MobileScannerException catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to check flash availability: ${e.toString()}',
        exception: e,
      ));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Failed to check flash availability: ${e.toString()}',
        exception: e as Exception,
      ));
    }
  }

  /// Maps ms.BarcodeFormat to our BarcodeFormat enum
  BarcodeFormat _mapBarcodeFormat(ms.BarcodeFormat format) {
    switch (format) {
      case ms.BarcodeFormat.ean13:
        return BarcodeFormat.ean13;
      case ms.BarcodeFormat.ean8:
        return BarcodeFormat.ean8;
      case ms.BarcodeFormat.qrCode:
        return BarcodeFormat.qrCode;
      case ms.BarcodeFormat.code128:
        return BarcodeFormat.code128;
      case ms.BarcodeFormat.code39:
        return BarcodeFormat.code39;
      case ms.BarcodeFormat.upcA:
        return BarcodeFormat.upcA;
      case ms.BarcodeFormat.upcE:
        return BarcodeFormat.upcA; // Treat UPC-E as UPC-A
      case ms.BarcodeFormat.codabar:
      case ms.BarcodeFormat.itf:
      case ms.BarcodeFormat.dataMatrix:
      case ms.BarcodeFormat.aztec:
      case ms.BarcodeFormat.pdf417:
      case ms.BarcodeFormat.unknown:
      default:
        return BarcodeFormat.unknown;
    }
  }
}
