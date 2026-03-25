import 'package:equatable/equatable.dart';

/// Receipt Data Transfer Object
/// Used to transfer receipt data between layers
/// Simpler than the domain entity, used for input/output operations
class ReceiptDto extends Equatable {
  /// Business name
  final String businessName;

  /// Business tax ID (RUC/NIT)
  final String? businessTaxId;

  /// Business address
  final String? businessAddress;

  /// Receipt header message
  final String? receiptHeader;

  /// Receipt footer message
  final String? receiptFooter;

  /// Items as simple maps
  final List<ReceiptItemDto> items;

  /// Subtotal
  final double subtotal;

  /// Discount
  final double discount;

  /// Total
  final double total;

  /// Payment method name
  final String paymentMethod;

  /// Change amount
  final double? change;

  /// Receipt number
  final String receiptNumber;

  /// Creation timestamp
  final DateTime createdAt;

  const ReceiptDto({
    required this.businessName,
    this.businessTaxId,
    this.businessAddress,
    this.receiptHeader,
    this.receiptFooter,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.change,
    required this.receiptNumber,
    required this.createdAt,
  });

  /// Creates a ReceiptDto from a map (for Hive/deserialization)
  factory ReceiptDto.fromMap(Map<String, dynamic> map) {
    final itemsMap = map['items'] as List<dynamic>? ?? [];
    final items = itemsMap
        .map((item) => ReceiptItemDto.fromMap(item as Map<String, dynamic>))
        .toList();

    return ReceiptDto(
      businessName: map['businessName'] as String,
      businessTaxId: map['businessTaxId'] as String?,
      businessAddress: map['businessAddress'] as String?,
      receiptHeader: map['receiptHeader'] as String?,
      receiptFooter: map['receiptFooter'] as String?,
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] as String,
      change: (map['change'] as num?)?.toDouble(),
      receiptNumber: map['receiptNumber'] as String,
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
    );
  }

  /// Converts ReceiptDto to a map (for Hive/serialization)
  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'businessTaxId': businessTaxId,
      'businessAddress': businessAddress,
      'receiptHeader': receiptHeader,
      'receiptFooter': receiptFooter,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'change': change,
      'receiptNumber': receiptNumber,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        businessName,
        businessTaxId,
        businessAddress,
        receiptHeader,
        receiptFooter,
        items,
        subtotal,
        discount,
        total,
        paymentMethod,
        change,
        receiptNumber,
        createdAt,
      ];
}

/// Receipt Item DTO
/// Simplified version of ReceiptItem for data transfer
class ReceiptItemDto extends Equatable {
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const ReceiptItemDto({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Creates a ReceiptItemDto from a map
  factory ReceiptItemDto.fromMap(Map<String, dynamic> map) {
    return ReceiptItemDto(
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts ReceiptItemDto to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [name, quantity, unitPrice, subtotal];
}
