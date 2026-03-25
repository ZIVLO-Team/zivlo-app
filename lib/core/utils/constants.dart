/// Application-wide constants

class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'Zivlo';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Cobra en segundos. Sin internet. Sin complicaciones.';
  
  // Hive Box Names
  static const String productsBox = 'products';
  static const String salesBox = 'sales';
  static const String settingsBox = 'settings';
  
  // Default Values
  static const int defaultPageSize = 20;
  static const int maxCartItems = 100;
  static const double maxDiscountPercent = 100.0;
  
  // Timeout durations
  static const Duration printerConnectionTimeout = Duration(seconds: 10);
  static const Duration printerPrintTimeout = Duration(seconds: 15);
  static const Duration scannerTimeout = Duration(seconds: 30);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double fabElevation = 6.0;
  
  // Receipt Constants
  static const int receiptWidth58mm = 384;  // dots
  static const int receiptWidth80mm = 576;  // dots
  static const String defaultReceiptHeader = 'GRACIAS POR SU COMPRA';
}
