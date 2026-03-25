import 'package:flutter/material.dart';

import 'package:zivlo/core/theme/app_theme.dart';
import 'package:zivlo/features/checkout/application/usecases/get_checkout_summary.dart' as checkout_dto;

/// Checkout Summary Widget
/// Displays the order summary including items, subtotal, discount, and total
class CheckoutSummary extends StatelessWidget {
  final checkout_dto.CheckoutSummary summary;
  final bool expanded;

  const CheckoutSummary({
    super.key,
    required this.summary,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.colorPrimary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacing8),
                Text(
                  'Resumen del Pedido',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.colorOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacing16),

            // Items info
            _buildItemsInfo(),

            if (expanded) ...[
              const SizedBox(height: AppSpacing.spacing16),
              const Divider(color: AppColors.colorSurfaceVariant, height: 1),
              const SizedBox(height: AppSpacing.spacing16),

              // Subtotal
              _buildSummaryRow(
                label: 'Subtotal',
                value: summary.formattedSubtotal,
              ),

              const SizedBox(height: AppSpacing.spacing8),

              // Discount
              _buildSummaryRow(
                label: 'Descuento',
                value: summary.formattedDiscount,
                valueColor: summary.discount > 0
                    ? AppColors.colorSuccess
                    : AppColors.colorOnSurfaceMuted,
              ),

              const SizedBox(height: AppSpacing.spacing16),
              const Divider(color: AppColors.colorSurfaceVariant, height: 1),
              const SizedBox(height: AppSpacing.spacing16),

              // Total
              _buildSummaryRow(
                label: 'Total',
                value: summary.formattedTotal,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          summary.itemsSummary,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurfaceMuted,
          ),
        ),
        Chip(
          label: Text(
            '${summary.totalQuantity}',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.colorOnSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.colorPrimary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal 
              ? AppTypography.textTheme.titleMedium 
              : AppTypography.textTheme.bodyMedium
          )?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: (isTotal 
              ? AppTypography.textTheme.headlineSmall 
              : AppTypography.textTheme.bodyMedium
          )?.copyWith(
            color: valueColor ?? (isTotal ? AppColors.colorTotal : AppColors.colorOnSurface),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
