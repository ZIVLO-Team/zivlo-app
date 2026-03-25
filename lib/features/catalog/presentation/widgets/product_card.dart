import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';

/// Product Card Widget
///
/// Square card for grid display of products
///
/// Features:
/// - Card cuadrada con placeholder de imagen (icono inventory_2)
/// - Chip de categoría en esquina superior izquierda
/// - Nombre del producto (titleMedium, max 2 líneas con ellipsis)
/// - Precio (Space Mono, titleLarge, colorAccent)
/// - Badge de stock: verde (hay stock), amarillo (< 5), rojo (0)
/// - onTap navega a ProductFormPage para editar
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder with category chip
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Image placeholder
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.colorSurfaceVariant.withOpacity(0.3),
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusSmall),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppColors.colorOnSurfaceMuted,
                      ),
                    ),

                    // Category chip (top-left)
                    if (product.category != null &&
                        product.category!.trim().isNotEmpty)
                      Positioned(
                        top: AppSpacing.spacing8,
                        left: AppSpacing.spacing8,
                        child: Chip(
                          label: Text(
                            product.category!,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.colorOnSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          backgroundColor:
                              AppColors.colorPrimary.withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spacing8,
                            vertical: AppSpacing.spacing2,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spacing12),

              // Product name
              Expanded(
                flex: 2,
                child: Text(
                  product.name,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.colorOnSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: AppSpacing.spacing8),

              // Price and stock badge
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price
                    Expanded(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.colorAccent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Stock badge
                    _buildStockBadge(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    Color badgeColor;
    String stockText;

    if (product.stock == 0) {
      badgeColor = AppColors.colorError;
      stockText = 'Sin stock';
    } else if (product.stock < 5) {
      badgeColor = AppColors.colorWarning;
      stockText = 'Pocos (${product.stock})';
    } else {
      badgeColor = AppColors.colorSuccess;
      stockText = 'En stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
        border: Border.all(
          color: badgeColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing4),
          Text(
            stockText,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
