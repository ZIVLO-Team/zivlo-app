import 'package:hive/hive.dart';
import '../../domain/value_objects/discount.dart';

part 'discount_hive_model.g.dart';

/// Hive Data Model for Discount
/// Stores discount type and value
@HiveType(typeId: 3)
class DiscountHiveModel extends HiveObject {
  @HiveField(0)
  late int typeId;  // 0 = percentage, 1 = fixed
  
  @HiveField(1)
  late double value;
  
  DiscountHiveModel();
  
  /// Creates model from domain entity
  factory DiscountHiveModel.fromEntity(Discount discount) {
    final model = DiscountHiveModel()
      ..typeId = discount.type.index
      ..value = discount.value;
    
    return model;
  }
  
  /// Converts model to domain entity
  Discount toEntity() {
    final type = DiscountType.values[typeId];
    
    switch (type) {
      case DiscountType.percentage:
        return Discount.percentage(value);
      case DiscountType.fixed:
        return Discount.fixed(value);
    }
  }
  
  @override
  String toString() {
    return 'DiscountHiveModel(type: ${DiscountType.values[typeId]}, value: $value)';
  }
}
