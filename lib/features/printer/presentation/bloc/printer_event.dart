import 'package:equatable/equatable.dart';
import '../../domain/entities/printer_device.dart';
import '../../domain/entities/receipt.dart';

/// Printer Event - Base class
/// All printer events extend this class
abstract class PrinterEvent extends Equatable {
  const PrinterEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Start discovering printers
/// Dispatched when user opens printer selector or taps refresh
class PrinterDiscoverStarted extends PrinterEvent {
  const PrinterDiscoverStarted();

  @override
  List<Object?> get props => [];
}

/// Event: Printers discovered successfully
/// Contains the list of discovered printer devices
class PrintersDiscovered extends PrinterEvent {
  final List<PrinterDevice> printers;

  const PrintersDiscovered(this.printers);

  @override
  List<Object?> get props => [printers];
}

/// Event: Connect to a specific printer
/// Contains the MAC address of the printer to connect to
class PrinterConnectRequested extends PrinterEvent {
  final String address;

  const PrinterConnectRequested(this.address);

  @override
  List<Object?> get props => [address];
}

/// Event: Connection successful
/// Contains the connected printer device
class PrinterConnected extends PrinterEvent {
  final PrinterDevice device;

  const PrinterConnected(this.device);

  @override
  List<Object?> get props => [device];
}

/// Event: Disconnect from current printer
/// Dispatched when user wants to disconnect
class PrinterDisconnectRequested extends PrinterEvent {
  const PrinterDisconnectRequested();

  @override
  List<Object?> get props => [];
}

/// Event: Print receipt requested
/// Contains the receipt to print
class PrintReceiptRequested extends PrinterEvent {
  final Receipt receipt;

  const PrintReceiptRequested(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

/// Event: Print successful
/// Dispatched when receipt printing completes
class PrintSuccess extends PrinterEvent {
  const PrintSuccess();

  @override
  List<Object?> get props => [];
}

/// Event: Printer error occurred
/// Contains the error message
class PrinterError extends PrinterEvent {
  final String message;

  const PrinterError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event: Set printer as default
/// Contains the printer address to set as default
class SetDefaultPrinterRequested extends PrinterEvent {
  final String address;

  const SetDefaultPrinterRequested(this.address);

  @override
  List<Object?> get props => [address];
}

/// Event: Connection status changed
/// Emitted when connection status changes from the port
class PrinterConnectionStatusChanged extends PrinterEvent {
  final bool isConnected;

  const PrinterConnectionStatusChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}
