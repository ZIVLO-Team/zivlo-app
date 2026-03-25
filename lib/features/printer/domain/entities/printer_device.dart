import 'package:equatable/equatable.dart';

/// Printer Device Entity
/// Represents a Bluetooth thermal printer device
/// Contains device information needed for connection and display
class PrinterDevice extends Equatable {
  /// MAC address of the printer (unique identifier)
  final String address;

  /// Human-readable name of the printer
  final String name;

  /// Whether the printer is currently connected
  final bool isConnected;

  /// Whether this is the default printer for automatic connection
  final bool isDefault;

  const PrinterDevice({
    required this.address,
    required this.name,
    this.isConnected = false,
    this.isDefault = false,
  });

  /// Returns true if this printer is connected
  bool get connected => isConnected;

  /// Returns true if this printer is set as default
  bool get defaultPrinter => isDefault;

  /// Creates a copy of this PrinterDevice with updated fields
  PrinterDevice copyWith({
    String? address,
    String? name,
    bool? isConnected,
    bool? isDefault,
  }) {
    return PrinterDevice(
      address: address ?? this.address,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [address, name, isConnected, isDefault];

  @override
  String toString() {
    return 'PrinterDevice(name: $name, address: $address, '
        'connected: $isConnected, default: $isDefault)';
  }
}
