import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/printer_device.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

/// Printer Selector Bottom Sheet
/// 
/// A modal bottom sheet that allows users to:
/// - Discover available Bluetooth printers
/// - Select and connect to a printer
/// - Set a printer as default
/// - Disconnect from current printer
/// 
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => const PrinterSelectorSheet(),
/// );
/// ```
class PrinterSelectorSheet extends StatelessWidget {
  const PrinterSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrinterBloc, PrinterState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.colorSurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.radiusLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.colorOnSurfaceMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Header
              _buildHeader(context),
              
              const SizedBox(height: 16),
              
              // Content based on state
              _buildContent(context, state),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Builds the header with title and refresh button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Conectar impresora',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.colorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.colorAccent,
            onPressed: () {
              context.read<PrinterBloc>().add(const PrinterDiscoverStarted());
            },
            tooltip: 'Buscar impresoras',
          ),
        ],
      ),
    );
  }

  /// Builds content based on current state
  Widget _buildContent(BuildContext context, PrinterState state) {
    if (state is PrinterDiscovering) {
      return _buildDiscoveringState();
    }

    if (state is PrintersDiscoveredState) {
      return _buildPrintersList(context, state.printers);
    }

    if (state is PrinterConnectedState) {
      return _buildConnectedState(context, state.device);
    }

    if (state is PrinterErrorState) {
      return _buildErrorState(context, state.message);
    }

    // Default: show discover button
    return _buildInitialState(context);
  }

  /// Builds discovering state
  Widget _buildDiscoveringState() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.padding32),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppColors.colorAccent,
          ),
          SizedBox(height: AppSpacing.spacing16),
          Text(
            'Buscando impresoras...',
            style: TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds printers list
  Widget _buildPrintersList(BuildContext context, List<PrinterDevice> printers) {
    if (printers.isEmpty) {
      return _buildNoPrintersFound();
    }

    return Column(
      children: [
        ...printers.map((printer) => _buildPrinterTile(context, printer)),
        const SizedBox(height: AppSpacing.spacing8),
      ],
    );
  }

  /// Builds a single printer tile
  Widget _buildPrinterTile(BuildContext context, PrinterDevice printer) {
    final bloc = context.read<PrinterBloc>();

    return ListTile(
      leading: Icon(
        Icons.print,
        color: printer.isConnected || printer.isDefault
            ? AppColors.colorSuccess
            : AppColors.colorOnSurfaceMuted,
        size: 28,
      ),
      title: Text(
        printer.name,
        style: const TextStyle(
          color: AppColors.colorOnSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        printer.address,
        style: const TextStyle(
          color: AppColors.colorOnSurfaceMuted,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (printer.isDefault) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.colorAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Predeterminada',
                style: TextStyle(
                  color: AppColors.colorAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (printer.isConnected)
            const Icon(
              Icons.check_circle,
              color: AppColors.colorSuccess,
              size: 20,
            )
          else
            IconButton(
              icon: const Icon(Icons.bluetooth_connected),
              color: AppColors.colorAccent,
              onPressed: () {
                bloc.add(PrinterConnectRequested(printer.address));
              },
            ),
        ],
      ),
      onTap: () {
        if (!printer.isConnected) {
          bloc.add(PrinterConnectRequested(printer.address));
        } else {
          // Show dialog to set as default
          _showSetDefaultDialog(context, printer);
        }
      },
    );
  }

  /// Builds connected state
  Widget _buildConnectedState(BuildContext context, PrinterDevice device) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.padding16),
      child: Column(
        children: [
          Icon(
            Icons.print,
            size: 48,
            color: AppColors.colorSuccess,
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Text(
            'Conectado a',
            style: TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing4),
          Text(
            device.name,
            style: const TextStyle(
              color: AppColors.colorOnSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing4),
          Text(
            device.address,
            style: const TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PrinterBloc>().add(const PrinterDisconnectRequested());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Desconectar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorSurfaceVariant,
              foregroundColor: AppColors.colorOnSurface,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing24,
                vertical: AppSpacing.spacing12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.padding32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.colorError,
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.colorOnSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          ElevatedButton(
            onPressed: () {
              context.read<PrinterBloc>().add(const PrinterDiscoverStarted());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Builds initial state (no printers discovered yet)
  Widget _buildInitialState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.padding32),
      child: Column(
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 48,
            color: AppColors.colorOnSurfaceMuted,
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            'Busca impresoras disponibles',
            style: TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PrinterBloc>().add(const PrinterDiscoverStarted());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Buscar impresoras'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds no printers found state
  Widget _buildNoPrintersFound() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.padding32),
      child: Column(
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 48,
            color: AppColors.colorOnSurfaceMuted,
          ),
          SizedBox(height: AppSpacing.spacing16),
          Text(
            'No se encontraron impresoras',
            style: TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.spacing8),
          Text(
            'Asegúrate de que Bluetooth esté activado\ny las impresoras estén encendidas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.colorOnSurfaceMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows dialog to set printer as default
  void _showSetDefaultDialog(BuildContext context, PrinterDevice printer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorSurface,
        title: const Text(
          'Establecer como predeterminada',
          style: TextStyle(color: AppColors.colorOnSurface),
        ),
        content: Text(
          '¿Quieres establecer "${printer.name}" como tu impresora predeterminada?',
          style: const TextStyle(color: AppColors.colorOnSurfaceMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PrinterBloc>().add(
                    SetDefaultPrinterRequested(printer.address),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${printer.name} establecida como predeterminada'),
                  backgroundColor: AppColors.colorSuccess,
                ),
              );
            },
            child: const Text('Establecer'),
          ),
        ],
      ),
    );
  }
}
