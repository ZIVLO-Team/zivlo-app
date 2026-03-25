import 'package:fpdart/fpdart.dart';
import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/printer/domain/ports/printer_port.dart';
/// Use Case: Connect Printer
///
/// Connects to a Bluetooth thermal printer by MAC address
/// Handles the connection process and updates connection state
///
/// This use case handles:
/// - Validating printer address
/// - Initiating Bluetooth connection
/// - Handling connection errors
/// - Updating connection state
class ConnectPrinter {
  final IPrinterPort printerPort;

  const ConnectPrinter(this.printerPort);

  /// Executes printer connection
  ///
  /// [address] - MAC address of the printer to connect to
  ///
  /// Returns [Unit.value] on successful connection
  /// Returns [Failure] if connection fails (invalid address, printer unavailable, etc.)
  Future<Either<Failure, Unit>> execute(String address) async {
    try {
      // Validate address format (basic MAC address validation)
      if (address.isEmpty) {
        return Left(const PrinterOperationFailure(
          operation: 'connect',
          message: 'Printer address cannot be empty',
        ));
      }

      return await printerPort.connect(address);
    } catch (e) {
      return Left(PrinterOperationFailure(
        operation: 'connect',
        message: 'Failed to connect to printer: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }
}
