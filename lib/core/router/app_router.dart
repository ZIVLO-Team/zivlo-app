import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Features - Home
import 'package:zivlo/features/home/presentation/pages/home_page.dart';
// Features - Scanner
import 'package:zivlo/features/scanner/presentation/pages/scanner_page.dart';
// Features - Checkout
import 'package:zivlo/features/checkout/presentation/pages/checkout_page.dart';
import 'package:zivlo/features/checkout/presentation/pages/payment_success_page.dart';
import 'package:zivlo/features/checkout/domain/value_objects/payment_method.dart';
/// App Router Configuration
///
/// Uses GoRouter for declarative routing with type-safe navigation
///
/// Routes:
/// - `/` - Home page
/// - `/scanner` - Barcode scanner page
/// - `/checkout` - Checkout/payment page
/// - `/checkout/success` - Payment success confirmation
final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
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

      // Checkout route
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        pageBuilder: (context, state) => const MaterialPage(
          child: CheckoutPage(),
        ),
      ),

      // Payment success route
      GoRoute(
        path: '/checkout/success',
        name: 'checkout-success',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            child: PaymentSuccessPage(
              saleId: args?['saleId'] as String? ?? '',
              totalPaid: args?['totalPaid'] as double? ?? 0.0,
              paymentMethod: args?['paymentMethod'] as PaymentMethod? ?? PaymentMethod.cash,
              change: args?['change'] as double?,
            ),
          );
        },
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
