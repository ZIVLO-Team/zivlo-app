import 'package:flutter/material.dart';

import 'package:zivlo/core/theme/app_theme.dart';
import 'package:zivlo/features/checkout/domain/value_objects/payment_method.dart';
/// Payment Method Selector Widget
/// Displays tabs for selecting payment method (Cash/Card/Mixed)
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
      ),
      child: Row(
        children: [
          _buildMethodTab(
            method: PaymentMethod.cash,
            icon: Icons.payments,
            label: 'Efectivo',
          ),
          _buildDivider(),
          _buildMethodTab(
            method: PaymentMethod.card,
            icon: Icons.credit_card,
            label: 'Tarjeta',
          ),
          _buildDivider(),
          _buildMethodTab(
            method: PaymentMethod.mixed,
            icon: Icons.account_balance_wallet,
            label: 'Mixto',
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTab({
    required PaymentMethod method,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedMethod == method;

    return Expanded(
      child: InkWell(
        onTap: () => onMethodSelected(method),
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.spacing12,
            horizontal: AppSpacing.spacing8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? AppColors.colorAccent 
                    : AppColors.colorOnSurfaceMuted,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: isSelected 
                      ? AppColors.colorAccent 
                      : AppColors.colorOnSurfaceMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.colorSurfaceVariant,
    );
  }
}

/// Payment method badge for displaying in receipts/confirmations
class PaymentMethodBadge extends StatelessWidget {
  final PaymentMethod method;
  final double size;

  const PaymentMethodBadge({
    super.key,
    required this.method,
    this.size = 32,
  });

  IconData get _icon {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mixed:
        return Icons.account_balance_wallet;
    }
  }

  String get _label {
    switch (method) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.mixed:
        return 'Mixto';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing6,
      ),
      decoration: BoxDecoration(
        color: AppColors.colorPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        border: Border.all(
          color: AppColors.colorAccent,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            color: AppColors.colorAccent,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.spacing8),
          Text(
            _label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.colorAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
