import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../domain/value_objects/payment_method.dart';
import '../widgets/payment_method_selector.dart';

/// Payment Success Page
/// Displays confirmation after successful payment
/// 
/// Shows:
/// - Success animation (check icon)
/// - Total paid
/// - Payment method
/// - Change amount (if applicable)
/// - Actions: Print receipt, View receipt, New sale
class PaymentSuccessPage extends StatefulWidget {
  final String saleId;
  final double totalPaid;
  final PaymentMethod paymentMethod;
  final double? change;

  const PaymentSuccessPage({
    super.key,
    required this.saleId,
    required this.totalPaid,
    required this.paymentMethod,
    this.change,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                  tooltip: 'Cerrar',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.colorSurface,
                    foregroundColor: AppColors.colorOnSurface,
                  ),
                ),
              ),

              const Spacer(),

              // Success animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.colorSuccess.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.colorSuccess,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 64,
                      color: AppColors.colorSuccess,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // Success message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  '¡Pago Exitoso!',
                  style: AppTypography.textTheme.headlineLarge?.copyWith(
                    color: AppColors.colorOnSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.spacing8),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'La transacción se completó correctamente',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.colorOnSurfaceMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // Total paid card
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.spacing24),
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
                    border: Border.all(
                      color: AppColors.colorAccent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Pagado',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.colorOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        '\$${widget.totalPaid.toStringAsFixed(2)}',
                        style: AppTypography.textTheme.displayMedium?.copyWith(
                          color: AppColors.colorAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.spacing24),

              // Payment method badge
              FadeTransition(
                opacity: _fadeAnimation,
                child: PaymentMethodBadge(method: widget.paymentMethod),
              ),

              // Change amount (if applicable)
              if (widget.change != null && widget.change! > 0) ...[
                const SizedBox(height: AppSpacing.spacing16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing16,
                      vertical: AppSpacing.spacing12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.colorChange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                      border: Border.all(
                        color: AppColors.colorChange,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: AppColors.colorChange,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.spacing8),
                        Text(
                          'Cambio: \$${widget.change!.toStringAsFixed(2)}',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.colorChange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Print receipt button
                    FilledButton.icon(
                      onPressed: () {
                        // TODO: Navigate to printer or trigger print
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Imprimiendo recibo...'),
                            backgroundColor: AppColors.colorInfo,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: Text(
                        'Imprimir Recibo',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.colorPrimary,
                        foregroundColor: AppColors.colorOnSurface,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spacing12),

                    // View receipt button
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to receipt details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Viendo recibo...'),
                            backgroundColor: AppColors.colorInfo,
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: Text(
                        'Ver Recibo',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.colorOnSurface,
                        side: const BorderSide(
                          color: AppColors.colorSurfaceVariant,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spacing24),

                    // New sale link
                    TextButton(
                      onPressed: () {
                        // Navigate to home/scanner to start new sale
                        context.go('/');
                      },
                      child: Text(
                        'Iniciar Nueva Venta',
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.colorAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
