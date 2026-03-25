import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain - Port
import 'package:zivlo/features/scanner/domain/ports/scanner_port.dart';

// Infrastructure - Adapters
import 'package:zivlo/features/scanner/infrastructure/adapters/mobile_scanner_adapter.dart';

// Application - Use Cases
import 'package:zivlo/features/scanner/application/usecases/start_scanning.dart';
import 'package:zivlo/features/scanner/application/usecases/stop_scanning.dart';
import 'package:zivlo/features/scanner/application/usecases/lookup_product_by_barcode.dart';
import 'package:zivlo/features/scanner/application/usecases/handle_scan_result.dart';

// Catalog - Repository (needed for product lookup)
import 'package:zivlo/features/catalog/domain/repositories/product_repository.dart';
import 'package:zivlo/features/catalog/infrastructure/repositories/hive_product_repository.dart';

// Presentation - BLoC
import 'package:zivlo/features/scanner/presentation/bloc/scanner_bloc.dart';

/// Initialize scanner feature dependencies
/// Uses the global service locator from lib/injection_container.dart
void initializeDependencies() {
  // Register Product Repository (LazySingleton - single instance)
  // This is needed for product lookup during scanning
  sl.registerLazySingleton<IProductRepository>(
    () => HiveProductRepository(sl()),
  );

  // Register Scanner Port (Factory - new instance per use)
  sl.registerFactory<IScannerPort>(
    () => MobileScannerAdapter(),
  );

  // Register Use Cases (LazySingleton - stateless)
  sl.registerLazySingleton(() => StartScanning(sl()));
  sl.registerLazySingleton(() => StopScanning(sl()));
  sl.registerLazySingleton(() => LookupProductByBarcode(sl()));
  sl.registerLazySingleton(() => HandleScanResult(sl()));

  // Register BLoC (Factory - new instance per widget)
  sl.registerFactory(() => ScannerBloc(
        startScanning: sl(),
        stopScanning: sl(),
        handleScanResult: sl(),
        scannerPort: sl(),
      ));
}

/// Get BLoC providers for this feature
List<BlocProvider> getBlocProviders() {
  return [
    BlocProvider<ScannerBloc>(create: (_) => sl<ScannerBloc>()),
  ];
}
