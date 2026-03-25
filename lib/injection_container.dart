import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Features
import 'package:zivlo/features/catalog/injection_container.dart' as catalog;
import 'package:zivlo/features/scanner/injection_container.dart' as scanner;
import 'package:zivlo/features/checkout/injection_container.dart' as checkout;
import 'package:zivlo/features/printer/injection_container.dart' as printer;

// Hive Models - Catalog
import 'package:zivlo/features/catalog/infrastructure/models/product_hive_model.dart';

// Hive Models - Scanner
import 'package:zivlo/features/scanner/infrastructure/models/scan_result_hive_model.dart';

// Hive Models - Checkout
import 'package:zivlo/features/checkout/infrastructure/models/sale_hive_model.dart';
import 'package:zivlo/features/checkout/infrastructure/models/sale_item_hive_model.dart';

// Hive Models - Printer
import 'package:zivlo/features/printer/infrastructure/models/printer_device_hive_model.dart';

/// Global service locator
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initializeDependencies() async {
  // Initialize Hive
  await _initializeHive();

  // Initialize feature-specific dependencies
  catalog.initializeDependencies();
  scanner.initializeDependencies();
  checkout.initializeDependencies();
  printer.initializeDependencies();
}

/// Initialize Hive boxes and register adapters manually
/// Note: We don't use hive_generator/build_runner to avoid dependency conflicts
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register adapters manually (without hive_generator)
  Hive.registerAdapter(ProductHiveModelAdapter());
  Hive.registerAdapter(ScanResultHiveModelAdapter());
  Hive.registerAdapter(SaleItemHiveModelAdapter());
  Hive.registerAdapter(SaleHiveModelAdapter());
  Hive.registerAdapter(PrinterDeviceHiveModelAdapter());

  // Open boxes
  await Hive.openBox<ProductHiveModel>('products');
  await Hive.openBox<ScanResultHiveModel>('scan_results');
  await Hive.openBox<SaleHiveModel>('sales');
  await Hive.openBox<PrinterDeviceHiveModel>('printer_settings');
}

/// Inject BLoCs into the widget tree
/// Use this in MultiBlocProvider
List<BlocProvider> getBlocProviders() {
  return [
    ...catalog.getBlocProviders(),
    ...scanner.getBlocProviders(),
    ...checkout.getBlocProviders(),
    ...printer.getBlocProviders(),
  ];
}
