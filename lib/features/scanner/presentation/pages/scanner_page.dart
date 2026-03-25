import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../catalog/infrastructure/models/product_hive_model.dart';
import '../../../catalog/infrastructure/repositories/hive_product_repository.dart';
import '../../domain/ports/scanner_port.dart';
import '../../infrastructure/adapters/mobile_scanner_adapter.dart';
import '../../application/usecases/start_scanning.dart';
import '../../application/usecases/stop_scanning.dart';
import '../../application/usecases/handle_scan_result.dart';
import '../../application/usecases/lookup_product_by_barcode.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_result_bottom_sheet.dart';
import '../widgets/product_not_found_dialog.dart';

/// Scanner Page
/// Full-screen barcode scanning page with camera view
///
/// Features:
/// - Full-screen camera preview
/// - Scanner overlay with guide area
/// - Close button (top-left)
/// - Flash toggle button (bottom-left)
/// - Product found bottom sheet
/// - Product not found dialog
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final ScannerBloc _scannerBloc;
  late final MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();

    // Create the MobileScannerAdapter (infrastructure)
    final scannerAdapter = MobileScannerAdapter();

    // Create product repository for lookup
    // Get the products box from Hive (must be initialized in main.dart)
    final productBox = Hive.box<ProductHiveModel>('products');
    final productRepository = HiveProductRepository(productBox);

    // Create use cases
    final startScanning = StartScanning(scannerAdapter);
    final stopScanning = StopScanning(scannerAdapter);
    final lookupProduct = LookupProductByBarcode(productRepository);
    final handleScanResult = HandleScanResult(lookupProduct);

    // Create BLoC with dependencies
    _scannerBloc = ScannerBloc(
      startScanning: startScanning,
      stopScanning: stopScanning,
      handleScanResult: handleScanResult,
      scannerPort: scannerAdapter,
    );

    // Create camera controller for preview
    _cameraController = MobileScannerController();

    // Dispatch ScannerStarted event
    _scannerBloc.add(const ScannerStarted());
  }

  @override
  void dispose() {
    // Stop scanning and dispose BLoC
    _scannerBloc.add(const ScannerStopped());
    _scannerBloc.close();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scannerBloc,
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: Stack(
          children: [
            // Camera preview (full-screen)
            Positioned.fill(
              child: MobileScanner(
                controller: _cameraController,
                onDetect: (capture) {
                  // Barcode detection is handled by the BLoC
                  // through the scannerPort.scanResults stream
                },
                errorBuilder: (context, error) {
                  return _buildErrorWidget(error);
                },
              ),
            ),

            // Scanner overlay with guide area
            const ScannerOverlay(),

            // Close button (top-left)
            Positioned(
              top: AppSpacing.spacing16,
              left: AppSpacing.spacing16,
              child: SafeArea(
                child: IconButton(
                  onPressed: () {
                    _scannerBloc.add(const ScannerStopped());
                    context.pop();
                  },
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.colorSurface.withOpacity(0.8),
                    foregroundColor: AppColors.colorOnSurface,
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ),
            ),

            // Flash toggle button (bottom-left)
            Positioned(
              bottom: AppSpacing.spacing24,
              left: AppSpacing.spacing24,
              child: SafeArea(
                child: BlocBuilder<ScannerBloc, ScannerState>(
                  builder: (context, state) {
                    final isFlashOn = state is ScannerFlashEnabled;

                    return IconButton(
                      onPressed: () {
                        _scannerBloc.add(FlashToggled(!isFlashOn));
                      },
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.colorSurface.withOpacity(0.8),
                        foregroundColor: AppColors.colorOnSurface,
                        minimumSize: const Size(56, 56),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BlocListener for handling state changes
  Widget _buildScannerListener() {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerProductFound) {
          // Show product found bottom sheet
          _showProductFoundBottomSheet(state.result);
        } else if (state is ScannerProductNotFound) {
          // Show product not found dialog
          _showProductNotFoundDialog(state.barcode);
        } else if (state is ScannerErrorState) {
          // Show error snackbar
          _showErrorSnackbar(state.message);
        }
      },
      child: const SizedBox.shrink(),
    );
  }

  /// Show product found bottom sheet
  void _showProductFoundBottomSheet(ScanResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ScanResultBottomSheet(
          result: result,
          onContinueScanning: () {
            Navigator.pop(context);
            // Resume scanning is automatic
          },
        );
      },
    );
  }

  /// Show product not found dialog
  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) {
        return ProductNotFoundDialog(barcode: barcode);
      },
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.colorError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        ),
      ),
    );
  }

  /// Build error widget for camera errors
  Widget _buildErrorWidget(MobileScannerException error) {
    return Container(
      color: AppColors.colorBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_off,
              size: 64,
              color: AppColors.colorError,
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Text(
              'Error de cámara',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.colorOnSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              error.message ?? 'No se pudo acceder a la cámara',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.colorOnSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacing24),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
