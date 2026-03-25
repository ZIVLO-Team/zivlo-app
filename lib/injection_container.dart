import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Features
import '../features/catalog/injection_container.dart' as catalog;

/// Global service locator
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initializeDependencies() async {
  // Initialize feature-specific dependencies
  await catalog.initializeDependencies();
}

/// Inject BLoCs into the widget tree
/// Use this in MultiBlocProvider
List<BlocProvider> getBlocProviders() {
  return [
    ...catalog.getBlocProviders(),
    // Add more feature blocs here as they are created
    // Example:
    // BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
    // BlocProvider<ScannerBloc>(create: (_) => sl<ScannerBloc>()),
  ];
}
