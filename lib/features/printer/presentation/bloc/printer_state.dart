import 'package:equatable/equatable.dart';
import 'package:zivlo/features/printer/domain/entities/printer_device.dart';
/// Printer State - Base class
/// All printer states extend this class
abstract class PrinterState extends Equatable {
  const PrinterState();

  @override
  List<Object?> get props => [];
}

/// Initial state
/// Before any printer operations
class PrinterInitial extends PrinterState {
  const PrinterInitial();

  @override
  List<Object?> get props => [];
}

/// Discovery state
/// Currently scanning for Bluetooth printers
class PrinterDiscovering extends PrinterState {
  const PrinterDiscovering();

  @override
  List<Object?> get props => [];
}

/// Discovered state
/// Has a list of available printers
class PrintersDiscoveredState extends PrinterState {
  final List<PrinterDevice> printers;

  const PrintersDiscoveredState(this.printers);

  @override
  List<Object?> get props => [printers];
}

/// Connecting state
/// Attempting to connect to a printer
class PrinterConnecting extends PrinterState {
  final String printerAddress;

  const PrinterConnecting(this.printerAddress);

  @override
  List<Object?> get props => [printerAddress];
}

/// Connected state
/// Successfully connected to a printer
class PrinterConnectedState extends PrinterState {
  final PrinterDevice device;

  const PrinterConnectedState(this.device);

  @override
  List<Object?> get props => [device];
}

/// Printing state
/// Currently printing a receipt
class PrinterPrinting extends PrinterState {
  const PrinterPrinting();

  @override
  List<Object?> get props => [];
}

/// Print success state
/// Receipt printed successfully
class PrinterPrintSuccess extends PrinterState {
  const PrinterPrintSuccess();

  @override
  List<Object?> get props => [];
}

/// Disconnected state
/// Not connected to any printer
class PrinterDisconnected extends PrinterState {
  const PrinterDisconnected();

  @override
  List<Object?> get props => [];
}

/// Error state
/// An error occurred during printer operations
class PrinterErrorState extends PrinterState {
  final String message;

  const PrinterErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
