import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/usecases/get_checkout_summary.dart';

/// Cash Payment Section Widget
/// Displays cash input field and change calculator
class CashPaymentSection extends StatelessWidget {
  final CheckoutSummaryData summary;
  final double? cashAmount;
  final double? change;
  final bool isValid;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onConfirmPayment;

  const CashPaymentSection({
    super.key,
    required this.summary,
    this.cashAmount,
    this.change,
    this.isValid = false,
    required this.onAmountChanged,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cash input field
        _buildCashInput(),

        const SizedBox(height: AppSpacing.spacing16),

        // Quick amount buttons
        _buildQuickAmountButtons(),

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

  Widget _buildCashInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto en Efectivo',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.colorAccent,
              fontWeight: FontWeight.bold,
            ),
            hintText: '0.00',
            hintStyle: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
            ),
            filled: true,
            fillColor: AppColors.colorSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorSurfaceVariant,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing16,
            ),
          ),
          onChanged: onAmountChanged,
        ),
        if (!isValid && cashAmount != null) ...[
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            'Monto insuficiente. Faltan \$${(summary.total - (cashAmount ?? 0)).toStringAsFixed(2)}',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.colorError,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickAmountButtons() {
    final total = summary.total;
    final amounts = [
      total, // Exact amount
      (total / 2).ceilToDouble(), // Half
      total * 1.5, // 1.5x
      (total / 100).ceilToDouble() * 100, // Round to nearest 100
    ].where((a) => a > 0).toList();

    return Wrap(
      spacing: AppSpacing.spacing8,
      runSpacing: AppSpacing.spacing8,
      children: amounts.map((amount) {
        return ActionChip(
          label: Text(
            '\$${amount.toStringAsFixed(0)}',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.colorOnSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.colorSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            side: const BorderSide(
              color: AppColors.colorSurfaceVariant,
              width: 1,
            ),
          ),
          onPressed: () {
            onAmountChanged(amount.toString());
          },
        );
      }).toList(),
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
                'Cambio a devolver',
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
    final isEnabled = isValid && (cashAmount ?? 0) > 0;

    return FilledButton.icon(
      onPressed: isEnabled ? onConfirmPayment : null,
      icon: const Icon(Icons.check_circle_outline),
      label: Text(
        'Confirmar Pago en Efectivo',
        style: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.colorSuccess : AppColors.colorSurfaceVariant,
        foregroundColor: isEnabled ? Colors.black : AppColors.colorOnSurfaceMuted,
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
