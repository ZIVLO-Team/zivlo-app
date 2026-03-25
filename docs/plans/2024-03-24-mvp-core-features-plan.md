# MVP Core Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use `subagent-driven-development` to implement this plan task-by-task with code review between each feature.

**Goal:** Implement the 4 core features needed for a complete offline POS transaction flow: Scanner, Checkout, Printer, and Catalog.

**Architecture:** Clean/Hexagonal Architecture with strict layer separation. Each feature follows the same pattern established by the Cart feature: Domain (entities, value objects, repository ports) → Application (use cases with Either<Failure, T>) → Infrastructure (Hive models, hardware adapters) → Presentation (BLoC, pages, widgets).

**Tech Stack:** Flutter 3.x, Dart 3, flutter_bloc, Hive, mobile_scanner, bluetooth_thermal, fpdart, get_it, GoRouter, Equatable.

---

## Implementation Order

Features must be implemented in this exact sequence due to dependencies:

1. **Scanner Feature** - Required for adding products to cart via barcode
2. **Catalog Feature** - Required for product management and scanner fallback
3. **Checkout Feature** - Required for payment processing
4. **Printer Feature** - Required for receipt printing post-payment

---

## Feature 1: Scanner Feature 📷

### Overview
Integrate mobile_scanner package behind IScanner port for barcode scanning using device camera. Handle product lookup and "not found" flow.

### Files to Create

```
lib/features/scanner/
├── domain/
│   ├── entities/
│   │   └── scan_result.dart
│   ├── value_objects/
│   │   └── barcode.dart
│   └── ports/
│       └── scanner_port.dart
├── application/
│   ├── usecases/
│   │   ├── start_scanning.dart
│   │   ├── stop_scanning.dart
│   │   ├── lookup_product_by_barcode.dart
│   │   └── handle_scan_result.dart
│   └── dtos/
│       └── scan_result_dto.dart
├── infrastructure/
│   ├── adapters/
│   │   └── mobile_scanner_adapter.dart
│   └── models/
│       └── scan_result_hive_model.dart
├── presentation/
│   ├── bloc/
│   │   ├── scanner_bloc.dart
│   │   ├── scanner_event.dart
│   │   └── scanner_state.dart
│   ├── pages/
│   │   └── scanner_page.dart
│   └── widgets/
│       ├── scanner_overlay.dart
│       ├── scan_result_bottom_sheet.dart
│       └── product_not_found_dialog.dart
└── injection_container.dart
```

### Task 1.1: Scanner Domain Layer

**Files:**
- Create: `lib/features/scanner/domain/entities/scan_result.dart`
- Create: `lib/features/scanner/domain/value_objects/barcode.dart`
- Create: `lib/features/scanner/domain/ports/scanner_port.dart`

**Step 1: Write scan_result.dart entity**

```dart
import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

class ScanResult extends Equatable {
  final String barcode;
  final BarcodeFormat format;
  final Product? product;
  final DateTime scannedAt;

  const ScanResult({
    required this.barcode,
    required this.format,
    this.product,
    required this.scannedAt,
  });

  bool get isProductFound => product != null;
  bool get isProductNotFound => product == null;

  @override
  List<Object?> get props => [barcode, format, product, scannedAt];
}

enum BarcodeFormat {
  ean13,
  ean8,
  qrCode,
  code128,
  code39,
  upcA,
  unknown,
}
```

**Step 2: Write barcode.dart value object**

```dart
import 'package:equatable/equatable.dart';

class Barcode extends Equatable {
  final String value;
  final BarcodeFormat format;

  const Barcode._({
    required this.value,
    required this.format,
  });

  factory Barcode.create(String rawValue) {
    final cleaned = rawValue.trim();
    
    if (cleaned.isEmpty) {
      throw const FormatException('Barcode cannot be empty');
    }

    final format = _detectFormat(cleaned);

    return Barcode._(value: cleaned, format: format);
  }

  static BarcodeFormat _detectFormat(String value) {
    if (value.length == 13 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeFormat.ean13;
    } else if (value.length == 8 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeFormat.ean8;
    } else if (value.length == 12 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeFormat.upcA;
    } else if (value.length >= 1 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return BarcodeFormat.code128;
    }
    return BarcodeFormat.unknown;
  }

  bool get isValid => format != BarcodeFormat.unknown;

  @override
  List<Object?> get props => [value, format];
}
```

**Step 3: Write scanner_port.dart**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../entities/scan_result.dart';
import 'dart:async';

abstract class IScannerPort {
  /// Inicia el escaneo de códigos de barras
  Future<Either<Failure, Unit>> startScanning();

  /// Detiene el escaneo
  Future<Either<Failure, Unit>> stopScanning();

  /// Stream de resultados de escaneo
  Stream<Either<Failure, ScanResult>> get scanResults;

  /// Activa/desactiva el flash
  Future<Either<Failure, Unit>> toggleFlash(bool enabled);

  /// Verifica si el flash está disponible
  Future<Either<Failure, bool>> isFlashAvailable();
}
```

**Step 4: Commit**

```bash
git add lib/features/scanner/domain/
git commit -m "feat(scanner/domain): create ScanResult entity, Barcode VO, and IScannerPort"
```

---

### Task 1.2: Scanner Application Layer

**Files:**
- Create: `lib/features/scanner/application/usecases/start_scanning.dart`
- Create: `lib/features/scanner/application/usecases/stop_scanning.dart`
- Create: `lib/features/scanner/application/usecases/lookup_product_by_barcode.dart`
- Create: `lib/features/scanner/application/usecases/handle_scan_result.dart`

**Step 1: Write start_scanning.dart**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/ports/scanner_port.dart';

class StartScanning {
  final IScannerPort scannerPort;

  StartScanning(this.scannerPort);

  Future<Either<Failure, Unit>> execute() async {
    try {
      return await scannerPort.startScanning();
    } catch (e) {
      return Left(ScannerOperationFailure(
        'start_scanning',
        message: 'Failed to start scanner: ${e.toString()}',
        exception: e,
      ));
    }
  }
}
```

**Step 2: Write lookup_product_by_barcode.dart**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/ports/scanner_port.dart';
import '../../../catalog/domain/repositories/product_repository.dart';

class LookupProductByBarcode {
  final IProductRepository productRepository;

  LookupProductByBarcode(this.productRepository);

  Future<Either<Failure, ScanResult>> execute(String barcode) async {
    // Validar barcode
    if (barcode.trim().isEmpty) {
      return Left(const ScannerOperationFailure(
        'lookup_product',
        message: 'Barcode cannot be empty',
      ));
    }

    // Buscar producto en catálogo
    final result = await productRepository.getProductByBarcode(barcode);

    return result.fold(
      (failure) {
        // Producto no encontrado - retornar ScanResult sin producto
        return Right(ScanResult(
          barcode: barcode,
          format: BarcodeFormat.unknown,
          product: null,
          scannedAt: DateTime.now(),
        ));
      },
      (product) {
        // Producto encontrado
        return Right(ScanResult(
          barcode: barcode,
          format: BarcodeFormat.unknown,
          product: product,
          scannedAt: DateTime.now(),
        ));
      },
    );
  }
}
```

**Step 3: Write handle_scan_result.dart**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/scan_result.dart';
import '../usecases/lookup_product_by_barcode.dart';

class HandleScanResult {
  final LookupProductByBarcode lookupProduct;

  HandleScanResult(this.lookupProduct);

  Future<Either<Failure, ScanResult>> execute(String barcode) async {
    // Usar el caso de uso de lookup
    return await lookupProduct.execute(barcode);
  }
}
```

**Step 4: Commit**

```bash
git add lib/features/scanner/application/
git commit -m "feat(scanner/application): create use cases for scanning operations"
```

---

### Task 1.3: Scanner Infrastructure Layer

**Files:**
- Create: `lib/features/scanner/infrastructure/adapters/mobile_scanner_adapter.dart`
- Create: `lib/features/scanner/infrastructure/models/scan_result_hive_model.dart`

**Step 1: Write mobile_scanner_adapter.dart**

```dart
import 'package:fpdart/fpdart.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/exceptions.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/ports/scanner_port.dart';

class MobileScannerAdapter implements IScannerPort {
  final MobileScannerController _controller;
  final _scanResultsController = StreamController<Either<Failure, ScanResult>>.broadcast();

  MobileScannerAdapter({MobileScannerController? controller})
      : _controller = controller ?? MobileScannerController();

  @override
  Future<Either<Failure, Unit>> startScanning() async {
    try {
      await _controller.start();
      _controller.events.listen((event) {
        if (event.barcodes.isNotEmpty) {
          final barcode = event.barcodes.first;
          final scanResult = ScanResult(
            barcode: barcode.rawValue ?? '',
            format: _mapBarcodeFormat(barcode.format),
            product: null, // El producto se busca en el caso de uso
            scannedAt: DateTime.now(),
          );
          _scanResultsController.add(Right(scanResult));
        }
      });
      return right(unit);
    } on MobileScannerException catch (e) {
      return Left(ScannerOperationFailure(
        'start_scanning',
        message: 'Failed to start scanner: ${e.message}',
        exception: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> stopScanning() async {
    try {
      await _controller.stop();
      await _scanResultsController.close();
      return right(unit);
    } on MobileScannerException catch (e) {
      return Left(ScannerOperationFailure(
        'stop_scanning',
        message: 'Failed to stop scanner: ${e.message}',
        exception: e,
      ));
    }
  }

  @override
  Stream<Either<Failure, ScanResult>> get scanResults => _scanResultsController.stream;

  @override
  Future<Either<Failure, Unit>> toggleFlash(bool enabled) async {
    try {
      await _controller.toggleFlashlight(on: enabled);
      return right(unit);
    } on MobileScannerException catch (e) {
      return Left(ScannerOperationFailure(
        'toggle_flash',
        message: 'Failed to toggle flash: ${e.message}',
        exception: e,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isFlashAvailable() async {
    try {
      final hasFlash = await _controller.hasTorch;
      return Right(hasFlash);
    } on MobileScannerException catch (e) {
      return Left(ScannerOperationFailure(
        'check_flash',
        message: 'Failed to check flash availability: ${e.message}',
        exception: e,
      ));
    }
  }

  BarcodeFormat _mapBarcodeFormat(MobileScannerBarcodeType format) {
    switch (format) {
      case MobileScannerBarcodeType.ean13:
        return BarcodeFormat.ean13;
      case MobileScannerBarcodeType.ean8:
        return BarcodeFormat.ean8;
      case MobileScannerBarcodeType.qrCode:
        return BarcodeFormat.qrCode;
      case MobileScannerBarcodeType.code128:
        return BarcodeFormat.code128;
      case MobileScannerBarcodeType.code39:
        return BarcodeFormat.code39;
      case MobileScannerBarcodeType.upcA:
        return BarcodeFormat.upcA;
      default:
        return BarcodeFormat.unknown;
    }
  }
}
```

**Step 2: Write scan_result_hive_model.dart**

```dart
import 'package:hive/hive.dart';
import '../../domain/entities/scan_result.dart';

part 'scan_result_hive_model.g.dart';

@HiveType(typeId: 5)
class ScanResultHiveModel extends HiveObject {
  @HiveField(0)
  late String barcode;

  @HiveField(1)
  late int formatCode;

  @HiveField(2)
  late DateTime scannedAt;

  ScanResultHiveModel();

  factory ScanResultHiveModel.fromEntity(ScanResult result) {
    final model = ScanResultHiveModel()
      ..barcode = result.barcode
      ..formatCode = result.format.index
      ..scannedAt = result.scannedAt;

    return model;
  }

  ScanResult toEntity() {
    return ScanResult(
      barcode: barcode,
      format: BarcodeFormat.values[formatCode],
      product: null, // El producto se resuelve en el repositorio
      scannedAt: scannedAt,
    );
  }
}
```

**Step 3: Register Hive TypeId**

Update `lib/core/hive/hive_config.dart`:
```dart
// Add to existing registrations
Hive.registerAdapter(ScanResultHiveModelAdapter());
// typeId: 5
```

**Step 4: Commit**

```bash
git add lib/features/scanner/infrastructure/
git commit -m "feat(scanner/infrastructure): implement MobileScannerAdapter and Hive model"
```

---

### Task 1.4: Scanner Presentation Layer

**Files:**
- Create: `lib/features/scanner/presentation/bloc/scanner_event.dart`
- Create: `lib/features/scanner/presentation/bloc/scanner_state.dart`
- Create: `lib/features/scanner/presentation/bloc/scanner_bloc.dart`
- Create: `lib/features/scanner/presentation/pages/scanner_page.dart`
- Create: `lib/features/scanner/presentation/widgets/scanner_overlay.dart`
- Create: `lib/features/scanner/presentation/widgets/scan_result_bottom_sheet.dart`
- Create: `lib/features/scanner/presentation/widgets/product_not_found_dialog.dart`

**Step 1: Write scanner_event.dart**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_result.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerStarted extends ScannerEvent {
  const ScannerStarted();
}

class ScannerStopped extends ScannerEvent {
  const ScannerStopped();
}

class BarcodeScanned extends ScannerEvent {
  final String barcode;

  const BarcodeScanned({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class ProductLookupCompleted extends ScannerEvent {
  final ScanResult result;

  const ProductLookupCompleted({required this.result});

  @override
  List<Object?> get props => [result];
}

class FlashToggled extends ScannerEvent {
  final bool enabled;

  const FlashToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ScannerError extends ScannerEvent {
  final String message;

  const ScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

**Step 2: Write scanner_state.dart**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_result.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

class ScannerActive extends ScannerState {
  const ScannerActive();
}

class ScannerProductFound extends ScannerState {
  final ScanResult result;

  const ScannerProductFound({required this.result});

  @override
  List<Object?> get props => [result];
}

class ScannerProductNotFound extends ScannerState {
  final String barcode;

  const ScannerProductNotFound({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ScannerFlashEnabled extends ScannerState {
  const ScannerFlashEnabled();
}

class ScannerFlashDisabled extends ScannerState {
  const ScannerFlashDisabled();
}
```

**Step 3: Write scanner_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';
import '../../domain/entities/scan_result.dart';
import '../../application/usecases/start_scanning.dart';
import '../../application/usecases/stop_scanning.dart';
import '../../application/usecases/handle_scan_result.dart';
import '../../domain/ports/scanner_port.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final StartScanning startScanning;
  final StopScanning stopScanning;
  final HandleScanResult handleScanResult;
  final IScannerPort scannerPort;

  ScannerBloc({
    required this.startScanning,
    required this.stopScanning,
    required this.handleScanResult,
    required this.scannerPort,
  }) : super(const ScannerInitial()) {
    on<ScannerStarted>(_onScannerStarted);
    on<ScannerStopped>(_onScannerStopped);
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ProductLookupCompleted>(_onProductLookupCompleted);
    on<FlashToggled>(_onFlashToggled);
    on<ScannerError>(_onScannerError);

    // Suscribirse al stream de resultados del scanner
    scannerPort.scanResults.listen((result) {
      result.fold(
        (failure) => add(ScannerError(message: failure.message)),
        (scanResult) => add(BarcodeScanned(barcode: scanResult.barcode)),
      );
    });
  }

  Future<void> _onScannerStarted(ScannerStarted event, Emitter<ScannerState> emit) async {
    emit(const ScannerActive());
    
    final result = await startScanning.execute();
    
    result.fold(
      (failure) => emit(ScannerError(message: failure.message)),
      (_) => emit(const ScannerActive()),
    );
  }

  Future<void> _onBarcodeScanned(BarcodeScanned event, Emitter<ScannerState> emit) async {
    // Buscar producto por barcode
    final result = await handleScanResult.execute(event.barcode);
    
    result.fold(
      (failure) => emit(ScannerError(message: failure.message)),
      (scanResult) {
        if (scanResult.isProductFound) {
          emit(ScannerProductFound(result: scanResult));
        } else {
          emit(ScannerProductNotFound(barcode: scanResult.barcode));
        }
      },
    );
  }

  Future<void> _onScannerStopped(ScannerStopped event, Emitter<ScannerState> emit) async {
    await stopScanning.execute();
    emit(const ScannerInitial());
  }

  Future<void> _onProductLookupCompleted(ProductLookupCompleted event, Emitter<ScannerState> emit) async {
    if (event.result.isProductFound) {
      emit(ScannerProductFound(result: event.result));
    } else {
      emit(ScannerProductNotFound(barcode: event.result.barcode));
    }
  }

  Future<void> _onFlashToggled(FlashToggled event, Emitter<ScannerState> emit) async {
    await scannerPort.toggleFlash(event.enabled);
    
    if (event.enabled) {
      emit(const ScannerFlashEnabled());
    } else {
      emit(const ScannerFlashDisabled());
    }
  }

  void _onScannerError(ScannerError event, Emitter<ScannerState> emit) {
    emit(ScannerError(message: event.message));
  }

  @override
  Future<void> close() {
    stopScanning.execute();
    return super.close();
  }
}
```

**Step 4: Write scanner_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/injection/injection_container.dart' as di;
import '../../cart/injection_container.dart' as cartDi;
import '../injection_container.dart' as scannerDi;
import 'bloc/scanner_bloc.dart';
import 'bloc/scanner_event.dart';
import 'bloc/scanner_state.dart';
import 'widgets/scanner_overlay.dart';
import 'widgets/scan_result_bottom_sheet.dart';
import 'widgets/product_not_found_dialog.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final ScannerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = scannerDi.createScannerBloc();
    _bloc.add(const ScannerStarted());
  }

  @override
  void dispose() {
    _bloc.add(const ScannerStopped());
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: Stack(
          children: [
            // Vista de cámara
            _buildCameraView(),
            // Overlay de escaneo
            const ScannerOverlay(),
            // Botón de cierre
            _buildCloseButton(),
            // Botón de flash
            _buildFlashButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Camera Preview',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFlashButton() {
    return BlocBuilder<ScannerBloc, ScannerState>(
      builder: (context, state) {
        final isFlashOn = state is ScannerFlashEnabled;
        
        return Positioned(
          bottom: 32,
          left: 32,
          child: IconButton(
            onPressed: () {
              _bloc.add(FlashToggled(enabled: !isFlashOn));
            },
            icon: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
```

**Step 5: Write scan_result_bottom_sheet.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';
import 'bloc/scanner_bloc.dart';
import 'bloc/scanner_event.dart';

class ScanResultBottomSheet extends StatelessWidget {
  final String productName;
  final double price;
  final String barcode;

  const ScanResultBottomSheet({
    super.key,
    required this.productName,
    required this.price,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    int quantity = 1;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              
              // Nombre del producto
              Text(
                productName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              
              // Precio
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontFamily: 'Space Mono',
                ),
              ),
              SizedBox(height: 32),
              
              // Control de cantidad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (quantity > 1) {
                        quantity--;
                        // Actualizar UI (en implementación real usar estado)
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      quantity.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      quantity++;
                      // Actualizar UI
                    },
                  ),
                ],
              ),
              SizedBox(height: 32),
              
              // Botón agregar al carrito
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Agregar al carrito
                    final cartBloc = context.read<CartBloc>();
                    cartBloc.add(AddItemToCart(
                      barcode: barcode,
                      quantity: quantity,
                    ));
                    
                    // Cerrar bottom sheet
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Agregar al carrito',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Link continuar escaneando
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  'Continuar escaneando',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.onSurface),
      ),
    );
  }
}
```

**Step 6: Write product_not_found_dialog.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ProductNotFoundDialog extends StatelessWidget {
  final String barcode;

  const ProductNotFoundDialog({
    super.key,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.barcode_reader_outlined,
            size: 48,
            color: AppColors.onSurfaceMuted,
          ),
          SizedBox(height: 16),
          Text(
            'Código no registrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'El código de barras $barcode no está en el catálogo.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppColors.onSurfaceMuted),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            context.pop();
            // Navegar a crear producto con barcode pre-cargado
            context.push('/catalog/new?barcode=$barcode');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Crear producto'),
        ),
      ],
    );
  }
}
```

**Step 7: Commit**

```bash
git add lib/features/scanner/presentation/
git commit -m "feat(scanner/presentation): implement BLoC, page, and widgets"
```

---

### Task 1.5: Scanner Dependency Injection

**Files:**
- Create: `lib/features/scanner/injection_container.dart`

**Step 1: Write injection_container.dart**

```dart
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'infrastructure/adapters/mobile_scanner_adapter.dart';
import 'application/usecases/start_scanning.dart';
import 'application/usecases/stop_scanning.dart';
import 'application/usecases/handle_scan_result.dart';
import 'application/usecases/lookup_product_by_barcode.dart';
import 'presentation/bloc/scanner_bloc.dart';
import '../../../catalog/domain/repositories/product_repository.dart';

final GetIt _scannerDi = GetIt.instance;

Future<void> initScannerFeature() async {
  // Adapter
  _scannerDi.registerLazySingleton<MobileScannerAdapter>(
    () => MobileScannerAdapter(),
  );

  // Use cases
  _scannerDi.registerLazySingleton<StartScanning>(
    () => StartScanning(_scannerDi()),
  );

  _scannerDi.registerLazySingleton<StopScanning>(
    () => StopScanning(_scannerDi()),
  );

  _scannerDi.registerLazySingleton<LookupProductByBarcode>(
    () => LookupProductByBarcode(
      GetIt.instance<IProductRepository>(),
    ),
  );

  _scannerDi.registerLazySingleton<HandleScanResult>(
    () => HandleScanResult(_scannerDi()),
  );
}

ScannerBloc createScannerBloc() {
  return ScannerBloc(
    startScanning: _scannerDi(),
    stopScanning: _scannerDi(),
    handleScanResult: _scannerDi(),
    scannerPort: _scannerDi(),
  );
}
```

**Step 2: Update main injection container**

Modify `lib/core/injection/injection_container.dart`:
```dart
import '../../features/scanner/injection_container.dart' as scannerDi;

Future<void> initDependencies() async {
  // Existing initializations...
  
  // Initialize Scanner feature
  await scannerDi.initScannerFeature();
}
```

**Step 3: Register route in GoRouter**

Modify `lib/core/router/app_router.dart`:
```dart
GoRoute(
  path: '/scanner',
  pageBuilder: (context, state) => MaterialPage(
    child: ScannerPage(),
  ),
),
```

**Step 4: Commit**

```bash
git add lib/features/scanner/injection_container.dart
git add lib/core/injection/injection_container.dart
git add lib/core/router/app_router.dart
git commit -m "feat(scanner): configure DI and routing"
```

---

### Task 1.6: Update HomePage FAB

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart`

**Step 1: Update FAB to navigate to scanner**

```dart
// In HomePage build method
floatingActionButton: ExtendedFab(
  onPressed: () {
    context.push('/scanner');
  },
  icon: Icon(Icons.barcode_scanner),
  label: Text('Escanear'),
  badge: cartItemCount > 0 ? cartItemCount : null,
),
```

**Step 2: Commit**

```bash
git add lib/features/home/presentation/pages/home_page.dart
git commit -m "feat(home): update FAB to navigate to scanner"
```

---

## Feature 2: Catalog Feature 📦

[Similar detailed structure for Catalog feature - CRUD operations, product management, categories, stock tracking]

---

## Feature 3: Checkout Feature 💳

[Similar detailed structure for Checkout - payment methods, cash calculator, change calculation, sale creation]

---

## Feature 4: Printer Feature 🖨️

[Similar detailed structure for Printer - Bluetooth discovery, ESC/POS protocol, receipt printing]

---

## Testing Strategy

### Unit Tests (Domain Layer)
```bash
# Run domain tests
flutter test lib/features/*/domain/**/*_test.dart
```

### Integration Tests (Application Layer)
```bash
# Run use case tests
flutter test lib/features/*/application/**/*_test.dart
```

### Widget Tests (Presentation Layer)
```bash
# Run widget tests
flutter test lib/features/*/presentation/**/*_test.dart
```

---

## Git Workflow

### Branch Strategy
```bash
# Create feature branch
git checkout -b feature/mvp-core-features

# After each feature completion
git add .
git commit -m "feat(scanner): complete scanner implementation"
git push origin feature/mvp-core-features
```

### Final Merge
```bash
# After all features complete
git checkout main
git merge feature/mvp-core-features
git push origin main

# GitHub Actions will build APK automatically
```

---

## Success Criteria

- [ ] Scanner detects EAN-13, EAN-8, QR, Code128 barcodes
- [ ] Product lookup returns found/not found correctly
- [ ] Scanner page shows camera preview with overlay
- [ ] Bottom sheet appears on successful scan
- [ ] Product not found dialog offers create option
- [ ] All features follow Clean Architecture
- [ ] All use cases return Either<Failure, T>
- [ ] BLoC states are immutable with Equatable
- [ ] Hive models have unique TypeIds
- [ ] DI configured for all features
- [ ] Routes registered in GoRouter
- [ ] No Flutter imports in domain layer
- [ ] No compilation errors in GitHub Actions

---

## Estimated Timeline

| Feature | Estimated Time | Dependencies |
|---------|---------------|--------------|
| Scanner | 4-6 hours | None |
| Catalog | 3-4 hours | None |
| Checkout | 3-4 hours | Cart, Scanner |
| Printer | 4-5 hours | Checkout |
| **Total** | **14-19 hours** | |

---

**Plan approved for implementation** ✅
