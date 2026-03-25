import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Domain - Repositories (Ports)
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/repositories/cart_repository.dart';

// Infrastructure - Repositories (Implementations)
import '../../infrastructure/repositories/hive_checkout_repository.dart';
import '../../infrastructure/repositories/in_memory_cart_repository.dart';

// Infrastructure - Hive Models
import '../../infrastructure/models/sale_hive_model.dart';
import '../../infrastructure/models/sale_item_hive_model.dart';

// Application - Use Cases
import '../../application/usecases/process_payment.dart';
import '../../application/usecases/calculate_change.dart';
import '../../application/usecases/validate_payment.dart';
import '../../application/usecases/get_checkout_summary.dart';

// Presentation - BLoC
import '../../presentation/bloc/checkout_bloc.dart';

/// Initialize checkout feature dependencies
/// Uses the global service locator from lib/injection_container.dart
void initializeDependencies() {
  // Register Cart Repository (Singleton - single instance for app lifetime)
  // Using in-memory implementation for now
  sl.registerLazySingleton<ICartRepository>(
    () => InMemoryCartRepository(uuid: sl()),
  );

  // Register Checkout Repository (LazySingleton - single instance)
  sl.registerLazySingleton<ICheckoutRepository>(
    () => HiveCheckoutRepository()..initialize(),
  );

  // Register UUID generator (LazySingleton)
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Register Use Cases (LazySingleton - stateless)
  sl.registerLazySingleton(() => GetCheckoutSummary(sl()));
  sl.registerLazySingleton(() => ProcessPayment(
        checkoutRepository: sl(),
        cartRepository: sl(),
        uuid: sl(),
      ));
  sl.registerLazySingleton(() => CalculateChange());
  sl.registerLazySingleton(() => ValidatePayment());

  // Register BLoC (Factory - new instance per widget)
  sl.registerFactory(() => CheckoutBloc(
        getCheckoutSummary: sl(),
        processPayment: sl(),
        calculateChange: sl(),
        validatePayment: sl(),
      ));
}

/// Get BLoC providers for this feature
List<BlocProvider> getBlocProviders() {
  return [
    BlocProvider<CheckoutBloc>(create: (_) => sl<CheckoutBloc>()),
  ];
}
