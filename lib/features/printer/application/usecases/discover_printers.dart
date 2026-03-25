import 'package:fpdart/fpdart.dart';
import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/printer/domain/entities/printer_device.dart';
import 'package:zivlo/features/printer/domain/ports/printer_port.dart';
/// Use Case: Discover Printers
///
/// Scans for available Bluetooth thermal printers
/// Returns a list of discovered printer devices
///
/// This use case handles:
/// - Checking Bluetooth permissions
/// - Starting Bluetooth discovery
/// - Filtering printer devices from all Bluetooth devices
/// - Returning formatted printer device list
class DiscoverPrinters {
  final IPrinterPort printerPort;

  const DiscoverPrinters(this.printerPort);

  /// Executes printer discovery
  ///
  /// Returns [List<PrinterDevice>] on success
  /// Returns [Failure] if discovery fails (Bluetooth off, permission denied, etc.)
  Future<Either<Failure, List<PrinterDevice>>> execute() async {
    try {
      return await printerPort.discoverPrinters();
    } catch (e) {
      return Left(PrinterOperationFailure(
        operation: 'discover',
        message: 'Failed to discover printers: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }
}
