import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/scan_result.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';

/// Scan Result Bottom Sheet
/// Displays product information when a product is found
/// Allows quantity adjustment and adding to cart
class ScanResultBottomSheet extends StatelessWidget {
  /// The scan result containing product information
  final ScanResult result;

  /// Callback when user wants to continue scanning
  final VoidCallback onContinueScanning;

  const ScanResultBottomSheet({
    super.key,
    required this.result,
    required this.onContinueScanning,
  });

  @override
  Widget build(BuildContext context) {
    final product = result.product;

    if (product == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.colorSurface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.radiusLarge),
              topRight: Radius.circular(AppRadius.radiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.spacing12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.colorOnSurfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.spacing24),
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.colorOnSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.spacing16),

                    // Price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTypography.textTheme.displayMedium?.copyWith(
                        color: AppColors.colorAccent,
                        fontFamily: GoogleFonts.spaceMono().fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.spacing32),

                    // Quantity controls
                    _QuantityControls(
                      result: result,
                    ),

                    const SizedBox(height: AppSpacing.spacing32),

                    // Add to cart button
                    ElevatedButton(
                      onPressed: () {
                        _addToCart(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorAccent,
                        foregroundColor: AppColors.colorOnSurface,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
                        ),
                      ),
                      child: const Text(
                        'Agregar al carrito',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spacing16),

                    // Continue scanning link
                    TextButton(
                      onPressed: onContinueScanning,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.colorOnSurfaceMuted,
                      ),
                      child: const Text(
                        'Continuar escaneando',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addToCart(BuildContext context) {
    final product = result.product;
    if (product == null) return;

    // Dispatch AddToCartRequested event to ScannerBloc
    // The ScannerBloc can coordinate with CartBloc or emit a state
    // that triggers navigation to cart
    context.read<ScannerBloc>().add(AddToCartRequested(
      result: result,
      quantity: 1,
    ));

    // Close the bottom sheet
    Navigator.pop(context);

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: AppColors.colorSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        ),
      ),
    );
  }
}

/// Quantity Controls Widget
/// Allows users to adjust the quantity before adding to cart
class _QuantityControls extends StatefulWidget {
  final ScanResult result;

  const _QuantityControls({required this.result});

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decrease button
        IconButton(
          onPressed: _decrement,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.colorSurfaceVariant,
            foregroundColor: AppColors.colorOnSurface,
            minimumSize: const Size(48, 48),
          ),
        ),

        // Quantity number
        SizedBox(
          width: 64,
          child: Text(
            _quantity.toString(),
            style: AppTypography.textTheme.headlineLarge?.copyWith(
              color: AppColors.colorOnSurface,
              fontFamily: GoogleFonts.spaceMono().fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Increase button
        IconButton(
          onPressed: _increment,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.colorSurfaceVariant,
            foregroundColor: AppColors.colorOnSurface,
            minimumSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }
}
