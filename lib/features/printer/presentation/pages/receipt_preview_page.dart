import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zivlo/features/printer/domain/entities/receipt_item.dart';
import 'package:zivlo/features/printer/presentation/bloc/printer_bloc.dart';
import 'package:zivlo/features/printer/presentation/bloc/printer_event.dart';
import 'package:zivlo/features/printer/presentation/bloc/printer_state.dart';
import 'package:zivlo/features/printer/presentation/widgets/receipt_widget.dart';
import 'package:zivlo/features/printer/presentation/widgets/print_button.dart';
import 'package:zivlo/features/printer/presentation/widgets/printer_selector_sheet.dart';
import 'package:zivlo/core/theme/app_theme.dart';
import 'package:zivlo/features/checkout/domain/entities/sale.dart';
import 'package:zivlo/features/printer/application/usecases/generate_receipt.dart';
import 'package:zivlo/features/printer/domain/entities/receipt.dart';

/// Receipt Preview Page
/// 
/// Displays a visual preview of the receipt exactly as it will print
/// 
/// Features:
/// - Dark background with white receipt card centered
/// - Space Mono font for all content (thermal printer simulation)
/// - Shows exactly how print will look (WYSIWYG)
/// - "Imprimir" floating button
/// - "Compartir" button (placeholder for future)
/// - Printer connection status indicator
/// 
/// Usage:
/// ```dart
/// GoRouterConfig.routes:
/// GoRoute(
///   path: '/receipt-preview',
///   builder: (context, state) => ReceiptPreviewPage(
///     sale: state.extra as Sale,
///   ),
/// )
/// ```
class ReceiptPreviewPage extends StatelessWidget {
  final Sale sale;

  const ReceiptPreviewPage({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    // Generate receipt from sale
    // In a real app, this would come from a use case or BLoC
    final receipt = _generateReceiptFromSale(sale);

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: _buildAppBar(context),
      body: _buildBody(context, receipt),
      floatingActionButton: PrintButton.fab(receipt: receipt),
    );
  }

  /// Generates a receipt from sale (simplified for demo)
  /// In production, use GenerateReceipt use case with BusinessInfo
  Receipt _generateReceiptFromSale(Sale sale) {
    // TODO: Use GenerateReceipt use case with actual BusinessInfo from settings
    return Receipt(
      businessName: 'Mi Negocio',
      businessTaxId: 'RUC: 12345678901',
      businessAddress: 'Calle Principal 123',
      receiptHeader: '¡Gracias por tu compra!',
      receiptFooter: 'Vuelva pronto',
      items: sale.items.map((item) {
        return ReceiptItem(
          name: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          subtotal: item.subtotal,
        );
      }).toList(),
      subtotal: sale.subtotal,
      discount: sale.discount,
      total: sale.total,
      paymentMethod: _formatPaymentMethod(sale.paymentMethod.name),
      change: sale.change,
      receiptNumber: sale.id.length > 6
          ? sale.id.substring(sale.id.length - 6).toUpperCase()
          : sale.id.toUpperCase(),
      createdAt: sale.createdAt,
    );
  }

  /// Formats payment method name
  String _formatPaymentMethod(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'mixed':
        return 'Mixto';
      default:
        return methodName;
    }
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.colorSurface,
      foregroundColor: AppColors.colorOnSurface,
      elevation: 0,
      title: const Text(
        'Vista previa del recibo',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Printer status indicator
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: BlocBuilder<PrinterBloc, PrinterState>(
              builder: (context, state) {
                if (state is PrinterConnectedState) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.colorSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Conectado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.colorOnSurfaceMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Sin conectar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.colorOnSurfaceMuted,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the page body
  Widget _buildBody(BuildContext context, Receipt receipt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Receipt widget
          ReceiptWidget(receipt: receipt),
          
          const SizedBox(height: AppSpacing.spacing24),
          
          // Action buttons
          _buildActionButtons(context, receipt),
          
          const SizedBox(height: AppSpacing.spacing32),
        ],
      ),
    );
  }

  /// Builds action buttons below receipt
  Widget _buildActionButtons(BuildContext context, Receipt receipt) {
    return Column(
      children: [
        // Print button
        PrintButton(receipt: receipt),
        
        const SizedBox(height: AppSpacing.spacing12),
        
        // Share button (placeholder)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de compartir próximamente'),
                  backgroundColor: AppColors.colorInfo,
                ),
              );
            },
            icon: const Icon(Icons.share, size: 20),
            label: const Text(
              'Compartir',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.colorOnSurface,
              side: const BorderSide(color: AppColors.colorSurfaceVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.spacing12),
        
        // Change printer link
        TextButton.icon(
          onPressed: () {
            _showPrinterSelector(context);
          },
          icon: const Icon(Icons.bluetooth, size: 18),
          label: const Text('Cambiar impresora'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.colorAccent,
          ),
        ),
      ],
    );
  }

  /// Shows printer selector bottom sheet
  void _showPrinterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrinterSelectorSheet(),
    );
  }
}
