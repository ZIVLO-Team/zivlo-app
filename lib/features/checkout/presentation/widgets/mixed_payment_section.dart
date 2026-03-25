import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zivlo/core/theme/app_theme.dart';
import 'package:zivlo/features/checkout/application/usecases/get_checkout_summary.dart' as checkout_dto;

/// Mixed Payment Section Widget
/// Displays combined cash + card payment UI
class MixedPaymentSection extends StatelessWidget {
  final checkout_dto.CheckoutSummary summary;
  final double? cashAmount;
  final double? cardAmount;
  final double remainingAmount;
  final double? change;
  final bool isValid;
  final ValueChanged<String> onCashAmountChanged;
  final ValueChanged<String> onCardAmountChanged;
  final VoidCallback onConfirmPayment;

  const MixedPaymentSection({
    super.key,
    required this.summary,
    this.cashAmount,
    this.cardAmount,
    this.remainingAmount = 0,
    this.change,
    this.isValid = false,
    required this.onCashAmountChanged,
    required this.onCardAmountChanged,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Payment split info
        _buildPaymentSplitInfo(),

        const SizedBox(height: AppSpacing.spacing16),

        // Cash section
        _buildCashSection(),

        const SizedBox(height: AppSpacing.spacing16),

        // Card section
        _buildCardSection(),

        if (change != null && change! > 0) ...[
          const SizedBox(height: AppSpacing.spacing16),

          // Change display
          _buildChangeDisplay(),
        ],

        const SizedBox(height: AppSpacing.spacing24),

        // Confirm button
        _buildConfirmButton(),
      ],
    );
  }

  Widget _buildPaymentSplitInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.colorInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        border: Border.all(
          color: AppColors.colorInfo,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.colorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                summary.formattedTotal,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.colorTotal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (remainingAmount > 0) ...[
            const SizedBox(height: AppSpacing.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Restante:',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.colorOnSurfaceMuted,
                  ),
                ),
                Text(
                  '\$${remainingAmount.toStringAsFixed(2)}',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.colorWarning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        border: Border.all(
          color: AppColors.colorSurfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments,
                color: AppColors.colorSuccess,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                'Pago en Efectivo',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.colorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.colorOnSurface,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.colorSuccess,
                fontWeight: FontWeight.bold,
              ),
              hintText: '0.00',
              hintStyle: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.colorOnSurfaceMuted,
              ),
              filled: true,
              fillColor: AppColors.colorSurfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing12,
                vertical: AppSpacing.spacing12,
              ),
            ),
            onChanged: onCashAmountChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    final cardAmountValue = cardAmount ?? 0;
    final isCardCoveringRemainder = cardAmountValue >= remainingAmount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        border: Border.all(
          color: isCardCoveringRemainder 
              ? AppColors.colorSuccess 
              : AppColors.colorSurfaceVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                color: AppColors.colorAccent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                'Pago con Tarjeta',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.colorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.colorOnSurface,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.colorAccent,
                fontWeight: FontWeight.bold,
              ),
              hintText: remainingAmount > 0 
                  ? 'Mínimo: \$${remainingAmount.toStringAsFixed(2)}'
                  : '0.00',
              hintStyle: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.colorOnSurfaceMuted,
              ),
              filled: true,
              fillColor: AppColors.colorSurfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing12,
                vertical: AppSpacing.spacing12,
              ),
            ),
            onChanged: onCardAmountChanged,
          ),
          if (remainingAmount > 0) ...[
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              'Mínimo requerido: \$${remainingAmount.toStringAsFixed(2)}',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: isCardCoveringRemainder 
                    ? AppColors.colorSuccess 
                    : AppColors.colorWarning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.colorSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        border: Border.all(
          color: AppColors.colorSuccess,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: AppColors.colorSuccess,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                'Cambio',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.colorSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '\$${change!.toStringAsFixed(2)}',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.colorSuccess,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return FilledButton.icon(
      onPressed: isValid ? onConfirmPayment : null,
      icon: const Icon(Icons.check_circle_outline),
      label: Text(
        'Confirmar Pago Mixto',
        style: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: isValid ? AppColors.colorAccent : AppColors.colorSurfaceVariant,
        foregroundColor: isValid ? Colors.white : AppColors.colorOnSurfaceMuted,
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
}
