import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Features
import '../features/catalog/injection_container.dart' as catalog;

// Hive Models - Catalog
import '../features/catalog/infrastructure/models/product_hive_model.dart';

/// Global service locator
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initializeDependencies() async {
  // Initialize Hive
  await _initializeHive();
  
  // Initialize feature-specific dependencies
  catalog.initializeDependencies();
}

/// Initialize Hive boxes and register adapters manually
/// Note: We don't use hive_generator/build_runner to avoid dependency conflicts
Future<void> _initializeHive() async {
  await Hive.initFlutter();
  
  // Register adapters manually (without hive_generator)
  Hive.registerAdapter(ProductHiveModelAdapter());
  
  // Open boxes
  await Hive.openBox<ProductHiveModel>('products');
}

/// Inject BLoCs into the widget tree
/// Use this in MultiBlocProvider
List<BlocProvider> getBlocProviders() {
  return [
    ...catalog.getBlocProviders(),
  ];
}
