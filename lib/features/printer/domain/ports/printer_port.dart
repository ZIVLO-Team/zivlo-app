import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/printer_device.dart';
import '../entities/receipt.dart';

/// Printer Port (Interface)
/// Defines what the domain layer needs from the infrastructure layer
/// Implementation is done in infrastructure layer (e.g., BluetoothPrinterAdapter)
///
/// This port abstracts the Bluetooth printer hardware operations,
/// allowing the domain layer to remain platform-agnostic.
abstract class IPrinterPort {
  /// Discovers available Bluetooth printers
  /// Returns a list of [PrinterDevice] on success
  /// Returns a [Failure] if discovery fails (e.g., Bluetooth disabled, permission denied)
  Future<Either<Failure, List<PrinterDevice>>> discoverPrinters();

  /// Connects to a specific printer by MAC address
  /// [address] - MAC address of the printer to connect to
  /// Returns [Unit.value] on success
  /// Returns a [Failure] if connection fails
  Future<Either<Failure, Unit>> connect(String address);

  /// Disconnects from the currently connected printer
  /// Returns [Unit.value] on success
  /// Returns a [Failure] if disconnection fails
  Future<Either<Failure, Unit>> disconnect();

  /// Prints a receipt to the connected printer
  /// [receipt] - The receipt entity to print
  /// Returns [Unit.value] on success
  /// Returns a [Failure] if printing fails (e.g., not connected, printer error)
  Future<Either<Failure, Unit>> printReceipt(Receipt receipt);

  /// Checks if the printer is currently connected
  /// Returns [true] if connected, [false] otherwise
  /// Returns a [Failure] if the check cannot be performed
  Future<Either<Failure, bool>> isConnected();

  /// Stream of connection status changes
  /// Emits [true] when connected, [false] when disconnected
  /// Emits a [Failure] if a connection error occurs
  Stream<Either<Failure, bool>> get connectionStatus;
}
