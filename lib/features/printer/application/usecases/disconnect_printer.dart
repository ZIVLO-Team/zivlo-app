import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/ports/printer_port.dart';

/// Use Case: Disconnect Printer
///
/// Disconnects from the currently connected Bluetooth printer
/// Handles graceful disconnection and state cleanup
///
/// This use case handles:
/// - Closing printer connection
/// - Cleaning up resources
/// - Updating connection state
class DisconnectPrinter {
  final IPrinterPort printerPort;

  const DisconnectPrinter(this.printerPort);

  /// Executes printer disconnection
  ///
  /// Returns [Unit.value] on successful disconnection
  /// Returns [Failure] if disconnection fails
  Future<Either<Failure, Unit>> execute() async {
    try {
      return await printerPort.disconnect();
    } catch (e) {
      return Left(PrinterOperationFailure(
        operation: 'disconnect',
        message: 'Failed to disconnect printer: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }
}
