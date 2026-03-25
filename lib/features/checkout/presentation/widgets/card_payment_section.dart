import 'package:flutter/material.dart';

import 'package:zivlo/core/theme/app_theme.dart';
import 'package:zivlo/features/checkout/application/usecases/get_checkout_summary.dart';
/// Card Payment Section Widget
/// Displays card payment confirmation UI
class CardPaymentSection extends StatelessWidget {
  final CheckoutSummaryData summary;
  final VoidCallback onConfirmPayment;

  const CardPaymentSection({
    super.key,
    required this.summary,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card info
        _buildCardInfo(),

        const SizedBox(height: AppSpacing.spacing24),

        // Payment details
        _buildPaymentDetails(),

        const SizedBox(height: AppSpacing.spacing32),

        // Confirm button
        _buildConfirmButton(),

        const SizedBox(height: AppSpacing.spacing16),

        // Security notice
        _buildSecurityNotice(),
      ],
    );
  }

  Widget _buildCardInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.colorSurface,
            AppColors.colorSurfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.credit_card,
                color: AppColors.colorAccent,
                size: 32,
              ),
              Text(
                'Tarjeta de Débito/Crédito',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.colorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.contactless,
                color: AppColors.colorOnSurfaceMuted,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: AppColors.colorSuccess,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                'Terminal lista para procesar',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.colorSuccess,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.colorSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Monto a pagar',
            value: summary.formattedTotal,
            isTotal: true,
          ),
          const SizedBox(height: AppSpacing.spacing12),
          _buildDetailRow(
            label: 'Método',
            value: 'Tarjeta',
            valueWidget: Icon(
              Icons.credit_card,
              color: AppColors.colorAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isTotal = false,
    Widget? valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurfaceMuted,
          ),
        ),
        valueWidget ??
            Text(
              value,
              style: (isTotal 
                  ? AppTypography.textTheme.headlineSmall 
                  : AppTypography.textTheme.bodyMedium
              )?.copyWith(
                color: isTotal ? AppColors.colorTotal : AppColors.colorOnSurface,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return FilledButton.icon(
      onPressed: onConfirmPayment,
      icon: const Icon(Icons.payment),
      label: Text(
        'Procesar con Tarjeta',
        style: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.colorAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing24,
          vertical: AppSpacing.spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.security,
          color: AppColors.colorOnSurfaceMuted,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.spacing8),
        Text(
          'Pago seguro y encriptado',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.colorOnSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
