import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/receipt.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

/// Print Button Widget
/// 
/// A floating action button or regular button that triggers receipt printing
/// 
/// Features:
/// - Shows different states: enabled, disabled (no printer), printing
/// - Displays loading indicator when printing
/// - Shows error if printer not connected
/// 
/// Usage:
/// ```dart
/// PrintButton(receipt: receipt)
/// 
/// // Or as FAB
/// PrintButton.fab(receipt: receipt)
/// ```
class PrintButton extends StatelessWidget {
  final Receipt receipt;
  final bool isFab;

  const PrintButton({
    super.key,
    required this.receipt,
    this.isFab = false,
  });

  /// Factory constructor for FAB variant
  factory PrintButton.fab({required Receipt receipt}) {
    return PrintButton(receipt: receipt, isFab: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrinterBloc, PrinterState>(
      builder: (context, state) {
        final isPrinting = state is PrinterPrinting;
        final isConnected = state is PrinterConnectedState;
        final isDisabled = !isConnected && !isPrinting;

        if (isFab) {
          return _buildFab(context, isPrinting, isConnected, isDisabled);
        }

        return _buildRegularButton(context, isPrinting, isConnected, isDisabled);
      },
    );
  }

  /// Builds FAB variant
  Widget _buildFab(
    BuildContext context,
    bool isPrinting,
    bool isConnected,
    bool isDisabled,
  ) {
    return FloatingActionButton.extended(
      onPressed: isDisabled
          ? null
          : () {
              if (!isConnected) {
                _showNoPrinterSnackbar(context);
              } else {
                context.read<PrinterBloc>().add(PrintReceiptRequested(receipt));
              }
            },
      backgroundColor: isDisabled
          ? AppColors.colorOnSurfaceMuted
          : AppColors.colorAccent,
      icon: isPrinting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.print),
      label: Text(isPrinting ? 'Imprimiendo...' : 'Imprimir'),
    );
  }

  /// Builds regular button variant
  Widget _buildRegularButton(
    BuildContext context,
    bool isPrinting,
    bool isConnected,
    bool isDisabled,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isDisabled
            ? null
            : () {
                if (!isConnected) {
                  _showNoPrinterSnackbar(context);
                } else {
                  context.read<PrinterBloc>().add(PrintReceiptRequested(receipt));
                }
              },
        icon: isPrinting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.print, size: 20),
        label: Text(
          isPrinting ? 'Imprimiendo...' : 'Imprimir recibo',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.colorOnSurfaceMuted
              : AppColors.colorAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing24,
            vertical: AppSpacing.spacing12,
          ),
        ),
      ),
    );
  }

  /// Shows snackbar when no printer is connected
  void _showNoPrinterSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.print_disabled, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay impresora conectada. Conecta una impresora primero.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.colorError,
        action: SnackBarAction(
          label: 'Conectar',
          textColor: Colors.white,
          onPressed: () {
            // Dispatch discover event to open printer selector
            // This would typically be handled by navigating to printer selector
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Print Status Widget
/// 
/// Shows the current printer connection status
/// Useful for displaying in app bars or status areas
class PrintStatusWidget extends StatelessWidget {
  const PrintStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrinterBloc, PrinterState>(
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
              Text(
                'Conectado',
                style: TextStyle(
                  color: AppColors.colorSuccess,
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
            Text(
              'Sin conectar',
              style: TextStyle(
                color: AppColors.colorOnSurfaceMuted,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}
