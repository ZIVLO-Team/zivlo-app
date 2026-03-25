import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/printer_device.dart';

/// Printer Device Hive Model
/// Hive-compatible model for storing printer device information
/// 
/// This model is used to persist:
/// - Default printer settings
/// - Recently connected printers
/// - Printer preferences
@HiveType(typeId: 20) // Next available type ID
class PrinterDeviceHiveModel extends HiveObject {
  @HiveField(0)
  String address;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isConnected;

  @HiveField(3)
  bool isDefault;

  PrinterDeviceHiveModel({
    required this.address,
    required this.name,
    this.isConnected = false,
    this.isDefault = false,
  });

  /// Creates a Hive model from domain entity
  factory PrinterDeviceHiveModel.fromEntity(PrinterDevice entity) {
    return PrinterDeviceHiveModel(
      address: entity.address,
      name: entity.name,
      isConnected: entity.isConnected,
      isDefault: entity.isDefault,
    );
  }

  /// Converts Hive model to domain entity
  PrinterDevice toEntity() {
    return PrinterDevice(
      address: address,
      name: name,
      isConnected: isConnected,
      isDefault: isDefault,
    );
  }

  /// Creates a copy with updated fields
  PrinterDeviceHiveModel copyWith({
    String? address,
    String? name,
    bool? isConnected,
    bool? isDefault,
  }) {
    return PrinterDeviceHiveModel(
      address: address ?? this.address,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// Hive Adapter for PrinterDeviceHiveModel
class PrinterDeviceHiveModelAdapter extends TypeAdapter<PrinterDeviceHiveModel> {
  @override
  final int typeId = 20;

  @override
  PrinterDeviceHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }

    return PrinterDeviceHiveModel(
      address: fields[0] as String,
      name: fields[1] as String,
      isConnected: fields[2] as bool? ?? false,
      isDefault: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, PrinterDeviceHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isConnected)
      ..writeByte(3)
      ..write(obj.isDefault);
  }
}
