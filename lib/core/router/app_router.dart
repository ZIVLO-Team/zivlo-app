import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Features - Home
import '../../features/home/presentation/pages/home_page.dart';

// Features - Scanner
import '../../features/scanner/presentation/pages/scanner_page.dart';

/// App Router Configuration
/// 
/// Uses GoRouter for declarative routing with type-safe navigation
/// 
/// Routes:
/// - `/` - Home page
/// - `/scanner` - Barcode scanner page
final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: (String message) => false,
    routes: [
      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Scanner route
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        pageBuilder: (context, state) => MaterialPage(
          child: ScannerPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.path}" does not exist',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
