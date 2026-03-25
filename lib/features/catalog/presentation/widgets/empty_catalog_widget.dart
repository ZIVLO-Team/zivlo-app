import 'package:flutter/material.dart';

import 'package:zivlo/core/theme/app_theme.dart';
/// Empty Catalog Widget
///
/// Empty state widget displayed when there are no products
///
/// Features:
/// - Icono inventory_2 grande (48dp) en colorOnSurfaceMuted
/// - Texto: "No hay productos aún"
/// - Botón "Agregar primer producto"
/// - Centrado vertical y horizontalmente
class EmptyCatalogWidget extends StatelessWidget {
  final VoidCallback onAddProduct;

  const EmptyCatalogWidget({
    super.key,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.colorOnSurfaceMuted,
            ),
            const SizedBox(height: AppSpacing.spacing24),

            // Title
            Text(
              'No hay productos aún',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.colorOnSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacing8),

            // Subtitle
            Text(
              'Comienza agregando tu primer producto al catálogo',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.colorOnSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacing32),

            // Add product button
            ElevatedButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('Agregar primer producto'),
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
            ),
          ],
        ),
      ),
    );
  }
}
