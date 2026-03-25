import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Features
import '../features/catalog/injection_container.dart' as catalog;
import '../features/cart/injection_container.dart' as cart;

// Hive Models - Catalog
import '../features/catalog/infrastructure/models/product_hive_model.dart';

// Hive Models - Cart
import '../features/cart/infrastructure/models/cart_hive_model.dart';
import '../features/cart/infrastructure/models/cart_item_hive_model.dart';
import '../features/cart/infrastructure/models/discount_hive_model.dart';
import '../features/cart/infrastructure/models/product_snapshot_hive_model.dart';

/// Global service locator
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initializeDependencies() async {
  // Initialize Hive
  await _initializeHive();
  
  // Initialize feature-specific dependencies
  catalog.initializeDependencies();
  cart.initializeDependencies();
}

/// Initialize Hive boxes
Future<void> _initializeHive() async {
  await Hive.initFlutter();
  
  // Register adapters - Catalog
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductHiveModelAdapter());
  }
  
  // Register adapters - Cart
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CartHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CartItemHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(DiscountHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(ProductSnapshotHiveModelAdapter());
  }
  
  // Open boxes
  await Hive.openBox<ProductHiveModel>('products');
  await Hive.openBox<CartHiveModel>('cart');
}

/// Inject BLoCs into the widget tree
/// Use this in MultiBlocProvider
List<BlocProvider> getBlocProviders() {
  return [
    ...catalog.getBlocProviders(),
    ...cart.getBlocProviders(),
  ];
}
