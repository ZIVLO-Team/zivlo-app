import 'package:equatable/equatable.dart';
import 'receipt_item.dart';

/// Receipt Entity
/// Represents the complete receipt data to be printed
/// Contains all information needed for thermal printing
///
/// This entity is created from a Sale and business configuration
class Receipt extends Equatable {
  /// Business name
  final String businessName;

  /// Business tax ID (RUC/NIT)
  final String? businessTaxId;

  /// Business address
  final String? businessAddress;

  /// Custom receipt header (optional)
  final String? receiptHeader;

  /// Custom receipt footer (optional)
  final String? receiptFooter;

  /// List of items in the receipt
  final List<ReceiptItem> items;

  /// Subtotal before discount
  final double subtotal;

  /// Discount applied
  final double discount;

  /// Final total
  final double total;

  /// Payment method used
  final String paymentMethod;

  /// Change returned (for cash/mixed payments)
  final double? change;

  /// Receipt/ticket number
  final String receiptNumber;

  /// Creation timestamp
  final DateTime createdAt;

  const Receipt({
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

  /// Returns formatted date for display (DD/MM/YYYY HH:mm)
  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  /// Returns formatted subtotal for display
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  /// Returns formatted discount for display
  String get formattedDiscount {
    if (discount <= 0) return '\$0.00';
    return '-\$${discount.toStringAsFixed(2)}';
  }

  /// Returns formatted total for display
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  /// Returns formatted change for display
  String get formattedChange {
    if (change == null) return '\$0.00';
    return '\$${change!.toStringAsFixed(2)}';
  }

  /// Returns true if there's a discount applied
  bool get hasDiscount => discount > 0;

  /// Returns true if there's change to return
  bool get hasChange => change != null && change! > 0;

  /// Returns true if there's a custom footer
  bool get hasFooter => receiptFooter != null && receiptFooter!.isNotEmpty;

  /// Creates a copy of this Receipt with updated fields
  Receipt copyWith({
    String? businessName,
    String? businessTaxId,
    String? businessAddress,
    String? receiptHeader,
    String? receiptFooter,
    List<ReceiptItem>? items,
    double? subtotal,
    double? discount,
    double? total,
    String? paymentMethod,
    double? change,
    String? receiptNumber,
    DateTime? createdAt,
  }) {
    return Receipt(
      businessName: businessName ?? this.businessName,
      businessTaxId: businessTaxId ?? this.businessTaxId,
      businessAddress: businessAddress ?? this.businessAddress,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      change: change ?? this.change,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      createdAt: createdAt ?? this.createdAt,
    );
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

  @override
  String toString() {
    return 'Receipt(businessName: $businessName, total: $total, '
        'receiptNumber: $receiptNumber, createdAt: $createdAt)';
  }
}
