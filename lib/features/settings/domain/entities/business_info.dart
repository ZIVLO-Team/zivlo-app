import 'package:equatable/equatable.dart';

/// Business Information Entity
/// Contains all configurable business data for receipts and settings
///
/// This entity is used across features:
/// - Printer: for receipt header/footer
/// - Settings: for business configuration
/// - Catalog: for business name display
class BusinessInfo extends Equatable {
  /// Business name (required)
  final String name;

  /// Business tax ID - RUC/NIT (optional)
  final String? taxId;

  /// Business address (optional)
  final String? address;

  /// Custom receipt header message (optional)
  final String? receiptHeader;

  /// Custom receipt footer message (optional)
  final String? receiptFooter;

  /// Currency symbol (default: $)
  final String currencySymbol;

  /// Default paper width for receipts (58 or 80 mm)
  final int defaultPaperWidthMm;

  const BusinessInfo({
    required this.name,
    this.taxId,
    this.address,
    this.receiptHeader,
    this.receiptFooter,
    this.currencySymbol = '\$',
    this.defaultPaperWidthMm = 58,
  });

  /// Returns true if tax ID is configured
  bool get hasTaxId => taxId != null && taxId!.isNotEmpty;

  /// Returns true if address is configured
  bool get hasAddress => address != null && address!.isNotEmpty;

  /// Returns true if custom receipt header is set
  bool get hasReceiptHeader => receiptHeader != null && receiptHeader!.isNotEmpty;

  /// Returns true if custom receipt footer is set
  bool get hasReceiptFooter => receiptFooter != null && receiptFooter!.isNotEmpty;

  /// Creates a copy of this BusinessInfo with updated fields
  BusinessInfo copyWith({
    String? name,
    String? taxId,
    String? address,
    String? receiptHeader,
    String? receiptFooter,
    String? currencySymbol,
    int? defaultPaperWidthMm,
  }) {
    return BusinessInfo(
      name: name ?? this.name,
      taxId: taxId ?? this.taxId,
      address: address ?? this.address,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultPaperWidthMm: defaultPaperWidthMm ?? this.defaultPaperWidthMm,
    );
  }

  @override
  List<Object?> get props => [
        name,
        taxId,
        address,
        receiptHeader,
        receiptFooter,
        currencySymbol,
        defaultPaperWidthMm,
      ];

  @override
  String toString() {
    return 'BusinessInfo(name: $name, taxId: $taxId, currency: $currencySymbol)';
  }
}
