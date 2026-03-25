import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/domain/value_objects/barcode_format.dart';
import '../../domain/entities/scan_result.dart';

/// Hive Data Model for ScanResult
/// This is a DTO for Hive storage, separate from domain entity
/// 
/// Note: The [product] field is NOT stored in Hive.
/// It is resolved at runtime from the product catalog when needed.
@HiveType(typeId: 5)
class ScanResultHiveModel extends HiveObject {
  /// The raw barcode value
  @HiveField(0)
  late String barcode;

  /// The barcode format stored as an integer (enum index)
  @HiveField(1)
  late int formatCode;

  /// The timestamp when the scan occurred
  @HiveField(2)
  late DateTime scannedAt;

  ScanResultHiveModel();

  /// Creates model from domain entity
  /// 
  /// Note: The product field is intentionally not stored
  factory ScanResultHiveModel.fromEntity(ScanResult result) {
    final model = ScanResultHiveModel()
      ..barcode = result.barcode
      ..formatCode = result.format.index
      ..scannedAt = result.scannedAt;

    return model;
  }

  /// Converts model to domain entity
  /// 
  /// Note: The product field is set to null and must be resolved
  /// separately by looking up the barcode in the product catalog
  ScanResult toEntity() {
    return ScanResult(
      barcode: barcode,
      format: BarcodeFormat.values[formatCode],
      product: null, // Product is resolved at runtime from catalog
      scannedAt: scannedAt,
    );
  }

  @override
  String toString() {
    return 'ScanResultHiveModel(barcode: $barcode, format: ${BarcodeFormat.values[formatCode]}.name, scannedAt: $scannedAt)';
  }
}

/// Manual TypeAdapter for ScanResultHiveModel (without hive_generator)
/// This adapter handles serialization/deserialization for Hive storage
class ScanResultHiveModelAdapter extends TypeAdapter<ScanResultHiveModel> {
  @override
  final int typeId = 5;

  @override
  ScanResultHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResultHiveModel()
      ..barcode = fields[0] as String
      ..formatCode = fields[1] as int
      ..scannedAt = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ScanResultHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.formatCode)
      ..writeByte(2)
      ..write(obj.scannedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
