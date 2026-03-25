import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:zivlo/core/theme/app_theme.dart';
/// Product Not Found Dialog
/// Displays when a scanned barcode is not in the catalog
/// Offers options to cancel or create a new product
class ProductNotFoundDialog extends StatelessWidget {
  /// The barcode that was not found
  final String barcode;

  const ProductNotFoundDialog({
    super.key,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
      ),
      icon: const Icon(
        Icons.qr_code_scanner_outlined,
        size: 48,
        color: AppColors.colorWarning,
      ),
      title: Text(
        'Código no registrado',
        style: AppTypography.textTheme.headlineLarge?.copyWith(
          color: AppColors.colorOnSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'El código de barras [$barcode] no está en el catálogo',
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.colorOnSurfaceMuted,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.colorOnSurfaceMuted,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Create product button
        ElevatedButton(
          onPressed: () {
            _navigateToCreateProduct(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.colorAccent,
            foregroundColor: AppColors.colorOnSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing24,
              vertical: AppSpacing.spacing12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
            ),
          ),
          child: const Text(
            'Crear producto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: AppSpacing.spacing12,
    );
  }

  void _navigateToCreateProduct(BuildContext context) {
    // Close the dialog
    Navigator.pop(context);

    // Navigate to create product page with barcode
    // Using go_router for navigation
    context.push('/catalog/new?barcode=$barcode');
  }
}
