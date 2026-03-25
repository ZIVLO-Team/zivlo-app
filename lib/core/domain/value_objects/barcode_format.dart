/// Barcode Format Enumeration
/// Represents common barcode formats used in retail and logistics
enum BarcodeFormat {
  /// EAN-13: 13 digits, used worldwide for retail products
  ean13,

  /// EAN-8: 8 digits, used for small products
  ean8,

  /// QR Code: 2D matrix barcode
  qrCode,

  /// Code 128: Alphanumeric, high density
  code128,

  /// Code 39: Alphanumeric, older standard
  code39,

  /// UPC-A: 12 digits, used in North America
  upcA,

  /// Unknown format
  unknown,
}
