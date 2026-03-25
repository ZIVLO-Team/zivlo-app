import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Domain - Repository
import '../../domain/repositories/cart_repository.dart';

// Infrastructure - Repository
import '../../infrastructure/repositories/hive_cart_repository.dart';

// Application - Use Cases
import '../../application/usecases/add_to_cart.dart';
import '../../application/usecases/remove_from_cart.dart';
import '../../application/usecases/update_cart_item_quantity.dart';
import '../../application/usecases/apply_discount.dart';
import '../../application/usecases/clear_cart.dart';
import '../../application/usecases/get_cart.dart';

// Presentation - BLoC
import '../../presentation/bloc/cart_bloc.dart';

// Hive Models
import '../../infrastructure/models/cart_hive_model.dart';
import '../../infrastructure/models/cart_item_hive_model.dart';
import '../../infrastructure/models/discount_hive_model.dart';
import '../../infrastructure/models/product_snapshot_hive_model.dart';

extern GetIt sl;

/// Initialize cart feature dependencies
void initializeDependencies() {
  // Register Hive Box
  final cartBox = Hive.box<CartHiveModel>('cart');
  sl.registerLazySingleton<Box<CartHiveModel>>('cartBox', () => cartBox);
  
  // Register Repository (LazySingleton - single instance)
  sl.registerLazySingleton<ICartRepository>(
    () => HiveCartRepository(sl('cartBox')),
  );
  
  // Register Use Cases (LazySingleton - stateless)
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => UndoRemoveItem(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantity(sl()));
  sl.registerLazySingleton(() => ApplyDiscount(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));
  
  // Register BLoC (Factory - new instance per widget)
  sl.registerFactory(() => CartBloc(
        getCart: sl(),
        addToCart: sl(),
        removeFromCart: sl(),
        undoRemoveItem: sl(),
        updateItemQuantity: sl(),
        applyDiscount: sl(),
        clearCart: sl(),
      ));
}

/// Get BLoC providers for this feature
List<BlocProvider> getBlocProviders() {
  return [
    BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
  ];
}
