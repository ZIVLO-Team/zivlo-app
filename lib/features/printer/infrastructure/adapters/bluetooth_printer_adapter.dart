import 'package:fpdart/fpdart.dart';
import 'dart:async';
import 'dart:math';

import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/printer/domain/entities/printer_device.dart';
import 'package:zivlo/features/printer/domain/entities/receipt.dart';
import 'package:zivlo/features/printer/domain/ports/printer_port.dart';
/// Mock Bluetooth Printer Adapter
/// 
/// MOCK IMPLEMENTATION - For development and testing
/// 
/// This is a placeholder adapter that simulates Bluetooth printer behavior
/// without requiring actual hardware or Bluetooth permissions.
/// 
/// TODO: Replace with real implementation using one of these packages:
/// - bluetooth_print: ^4.1.0 (Recommended - well maintained)
/// - esc_pos_bluetooth: ^0.4.0
/// - pos_universal_printer
/// 
/// Real implementation should:
/// - Use Flutter Bluetooth Serial or bluetooth_print package
/// - Handle Bluetooth permissions (Android 12+ requires BLUETOOTH_CONNECT, BLUETOOTH_SCAN)
/// - Implement ESC/POS command set for thermal printers
/// - Support 58mm and 80mm paper widths
/// - Handle connection state changes
/// - Implement proper error handling for Bluetooth operations
class MockBluetoothPrinterAdapter implements IPrinterPort {
  PrinterDevice? _connectedDevice;
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _random = Random();

  /// List of mock printers for testing
  static final List<PrinterDevice> _mockPrinters = [
    const PrinterDevice(
      address: '00:11:22:33:44:55',
      name: 'Thermal Printer X1',
      isConnected: false,
      isDefault: true,
    ),
    const PrinterDevice(
      address: 'AA:BB:CC:DD:EE:FF',
      name: 'Bluetooth Printer Pro',
      isConnected: false,
      isDefault: false,
    ),
    const PrinterDevice(
      address: '11:22:33:44:55:66',
      name: 'Portable Printer 58mm',
      isConnected: false,
      isDefault: false,
    ),
  ];

  @override
  Future<Either<Failure, List<PrinterDevice>>> discoverPrinters() async {
    try {
      // Simulate Bluetooth discovery delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate discovery failure (10% chance)
      if (_random.nextDouble() < 0.1) {
        return Left(const PrinterConnectionFailure(
          message: 'Bluetooth is disabled or permission denied',
        ));
      }

      // Return mock printers
      return Right(List.from(_mockPrinters));
    } catch (e) {
      return Left(PrinterConnectionFailure(
        message: 'Failed to discover printers: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> connect(String address) async {
    try {
      // Simulate connection delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Simulate connection failure (20% chance)
      if (_random.nextDouble() < 0.2) {
        return Left(PrinterConnectionFailure(
          deviceAddress: address,
          message: 'Failed to connect - device unavailable',
        ));
      }

      // Find the printer
      final printer = _mockPrinters.firstWhere(
        (p) => p.address == address,
        orElse: () => const PrinterDevice(
          address: 'UNKNOWN',
          name: 'Unknown Printer',
        ),
      );

      // Update connected device
      _connectedDevice = printer.copyWith(isConnected: true);

      // Emit connection status
      _connectionStatusController.add(true);

      print('[MOCK PRINTER] Connected to: ${printer.name} ($address)');
      return right(unit);
    } catch (e) {
      return Left(PrinterConnectionFailure(
        deviceAddress: address,
        message: 'Connection error: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> disconnect() async {
    try {
      if (_connectedDevice == null) {
        print('[MOCK PRINTER] No device connected');
        return right(unit); // Already disconnected
      }

      final deviceName = _connectedDevice!.name;

      // Simulate disconnection delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update connected device
      _connectedDevice = _connectedDevice?.copyWith(isConnected: false);
      _connectedDevice = null;

      // Emit connection status
      _connectionStatusController.add(false);

      print('[MOCK PRINTER] Disconnected from: $deviceName');
      return right(unit);
    } catch (e) {
      return Left(PrinterConnectionFailure(
        message: 'Failed to disconnect: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> printReceipt(Receipt receipt) async {
    try {
      if (_connectedDevice == null) {
        return Left(const PrinterPrintFailure(
          message: 'No printer connected',
        ));
      }

      // Simulate printing delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate print failure (10% chance)
      if (_random.nextDouble() < 0.1) {
        return Left(const PrinterPrintFailure(
          message: 'Printer out of paper or hardware error',
        ));
      }

      // Generate mock receipt text (ESC/POS format simulation)
      final receiptText = _generateReceiptText(receipt);
      
      print('[MOCK PRINTER] Printing receipt:');
      print(receiptText);
      print('[MOCK PRINTER] Print complete!');

      return right(unit);
    } catch (e) {
      return Left(PrinterPrintFailure(
        message: 'Print error: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isConnected() async {
    try {
      final connected = _connectedDevice?.isConnected ?? false;
      print('[MOCK PRINTER] Connection status: ${connected ? "Connected" : "Disconnected"}');
      return Right(connected);
    } catch (e) {
      return Left(PrinterConnectionFailure(
        message: 'Failed to check connection: ${e.toString()}',
        exception: e as Exception?,
      ));
    }
  }

  @override
  Stream<Either<Failure, bool>> get connectionStatus {
    return _connectionStatusController.stream.map((status) => Right(status));
  }

  /// Generates formatted receipt text (simulating ESC/POS commands)
  String _generateReceiptText(Receipt receipt) {
    final buffer = StringBuffer();
    const lineLength = 32; // 58mm paper

    // Header separators
    buffer.writeln('=' * lineLength);
    
    // Business name (centered)
    final namePadding = (lineLength - receipt.businessName.length) ~/ 2;
    buffer.writeln(' ' * namePadding + receipt.businessName);
    
    // Tax ID
    if (receipt.businessTaxId != null) {
      final taxPadding = (lineLength - receipt.businessTaxId!.length) ~/ 2;
      buffer.writeln(' ' * taxPadding + receipt.businessTaxId!);
    }
    
    // Address
    if (receipt.businessAddress != null) {
      final addrPadding = (lineLength - receipt.businessAddress!.length) ~/ 2;
      buffer.writeln(' ' * addrPadding + receipt.businessAddress!);
    }
    
    buffer.writeln('=' * lineLength);
    buffer.writeln('Date: ${receipt.formattedDate}');
    buffer.writeln('Ticket #: ${receipt.receiptNumber}');
    buffer.writeln('-' * lineLength);
    buffer.writeln('QTY  ITEM            SUBTOTAL');
    buffer.writeln('-' * lineLength);

    // Items
    for (final item in receipt.items) {
      final itemLine = '${item.quantity}x   ${_truncate(item.name, 15)}  ${item.formattedSubtotal}';
      buffer.writeln(itemLine);
    }

    buffer.writeln('-' * lineLength);
    buffer.writeln('Subtotal:          ${receipt.formattedSubtotal}');
    
    if (receipt.hasDiscount) {
      buffer.writeln('Discount:          ${receipt.formattedDiscount}');
    }
    
    buffer.writeln('-' * lineLength);
    buffer.writeln('TOTAL:             ${receipt.formattedTotal}');
    buffer.writeln('Payment: ${receipt.paymentMethod}');
    
    if (receipt.hasChange) {
      buffer.writeln('Change:            ${receipt.formattedChange}');
    }
    
    buffer.writeln('=' * lineLength);
    
    // Footer
    if (receipt.hasFooter) {
      final footerPadding = (lineLength - receipt.receiptFooter!.length) ~/ 2;
      buffer.writeln(' ' * footerPadding + receipt.receiptFooter!);
    }
    
    buffer.writeln('       Thank you!');
    buffer.writeln('=' * lineLength);
    buffer.writeln(); // Feed lines

    return buffer.toString();
  }

  /// Truncates text to max length
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 2) + '..';
  }

  /// Cleanup resources
  void dispose() {
    _connectionStatusController.close();
  }
}
