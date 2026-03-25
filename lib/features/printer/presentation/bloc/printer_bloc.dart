import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import 'package:zivlo/core/error/failures.dart';
import 'package:zivlo/features/printer/domain/entities/printer_device.dart';
import 'package:zivlo/features/printer/domain/ports/printer_port.dart';
import 'package:zivlo/features/printer/application/usecases/discover_printers.dart';
import 'package:zivlo/features/printer/application/usecases/connect_printer.dart';
import 'package:zivlo/features/printer/application/usecases/disconnect_printer.dart';
import 'package:zivlo/features/printer/application/usecases/print_receipt.dart';
import 'package:zivlo/features/printer/infrastructure/repositories/hive_printer_repository.dart';
import 'printer_event.dart';
import 'printer_state.dart';

/// Printer BLoC - Business Logic Component
/// Handles all printer-related business logic
///
/// Manages the printer state machine:
/// - PrinterInitial -> PrinterDiscovering -> PrintersDiscoveredState
/// - PrintersDiscoveredState -> PrinterConnecting -> PrinterConnectedState
/// - PrinterConnectedState -> PrinterPrinting -> PrinterPrintSuccess
/// - Any state -> PrinterErrorState (on error)
/// - Any state -> PrinterDisconnected (on disconnect)
class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  // Use cases
  final DiscoverPrinters discoverPrinters;
  final ConnectPrinter connectPrinter;
  final DisconnectPrinter disconnectPrinter;
  final PrintReceipt printReceipt;

  // Repository for storing printer settings
  final HivePrinterRepository printerRepository;

  // Port for listening to connection status
  final IPrinterPort printerPort;

  // Stream subscription for connection status
  StreamSubscription<Either<Failure, bool>>? _connectionSubscription;

  // Currently selected printer address
  String? _selectedPrinterAddress;

  PrinterBloc({
    required this.discoverPrinters,
    required this.connectPrinter,
    required this.disconnectPrinter,
    required this.printReceipt,
    required this.printerRepository,
    required this.printerPort,
  }) : super(const PrinterInitial()) {
    on<PrinterDiscoverStarted>(_onDiscoverStarted);
    on<PrintersDiscovered>(_onPrintersDiscovered);
    on<PrinterConnectRequested>(_onConnectRequested);
    on<PrinterConnected>(_onPrinterConnected);
    on<PrinterDisconnectRequested>(_onDisconnectRequested);
    on<PrintReceiptRequested>(_onPrintReceiptRequested);
    on<PrintSuccess>(_onPrintSuccess);
    on<PrinterError>(_onPrinterError);
    on<SetDefaultPrinterRequested>(_onSetDefaultPrinterRequested);
    on<PrinterConnectionStatusChanged>(_onConnectionStatusChanged);

    // Subscribe to connection status changes
    _subscribeToConnectionStatus();

    // Load default printer on initialization
    _loadDefaultPrinter();
  }

  /// Subscribe to connection status changes from the port
  void _subscribeToConnectionStatus() {
    _connectionSubscription = printerPort.connectionStatus.listen((result) {
      result.fold(
        (failure) => add(PrinterError(failure.message)),
        (isConnected) => add(PrinterConnectionStatusChanged(isConnected)),
      );
    });
  }

  /// Load default printer from repository on startup
  Future<void> _loadDefaultPrinter() async {
    final defaultPrinter = await printerRepository.getDefaultPrinter();
    if (defaultPrinter != null && defaultPrinter.isConnected) {
      add(PrinterConnected(defaultPrinter));
    }
  }

  /// Handler: Start discovering printers
  Future<void> _onDiscoverStarted(
    PrinterDiscoverStarted event,
    Emitter<PrinterState> emit,
  ) async {
    emit(const PrinterDiscovering());

    final result = await discoverPrinters.execute();

    result.fold(
      (failure) {
        emit(PrinterErrorState(failure.message));
        add(PrinterError(failure.message));
      },
      (printers) => add(PrintersDiscovered(printers)),
    );
  }

  /// Handler: Printers discovered
  Future<void> _onPrintersDiscovered(
    PrintersDiscovered event,
    Emitter<PrinterState> emit,
  ) async {
    // If we have a connected printer, show connected state
    if (state is PrinterConnectedState) {
      emit(PrintersDiscoveredState(event.printers));
    } else {
      // Check if any printer is marked as default/connected
      final connectedPrinter = event.printers.firstWhere(
        (p) => p.isConnected || p.isDefault,
        orElse: () => const PrinterDevice(
          address: '',
          name: '',
          isConnected: false,
          isDefault: false,
        ),
      );

      if (connectedPrinter.address.isNotEmpty) {
        emit(PrinterConnectedState(connectedPrinter));
      } else {
        emit(PrintersDiscoveredState(event.printers));
      }
    }
  }

  /// Handler: Connect to printer requested
  Future<void> _onConnectRequested(
    PrinterConnectRequested event,
    Emitter<PrinterState> emit,
  ) async {
    _selectedPrinterAddress = event.address;
    emit(PrinterConnecting(event.address));

    final result = await connectPrinter.execute(event.address);

    result.fold(
      (failure) {
        emit(PrinterErrorState(failure.message));
        add(PrinterError(failure.message));
      },
      (_) {
        // Connection successful - the PrinterConnected event will be
        // triggered by the connection status stream
      },
    );
  }

  /// Handler: Printer connected
  Future<void> _onPrinterConnected(
    PrinterConnected event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterConnectedState(event.device));

    // Save to recent printers
    await printerRepository.addRecentPrinter(event.device);

    // Update connection status in repository
    await printerRepository.updatePrinterConnectionStatus(
      event.device.address,
      true,
    );
  }

  /// Handler: Disconnect requested
  Future<void> _onDisconnectRequested(
    PrinterDisconnectRequested event,
    Emitter<PrinterState> emit,
  ) async {
    final result = await disconnectPrinter.execute();

    result.fold(
      (failure) {
        emit(PrinterErrorState(failure.message));
        add(PrinterError(failure.message));
      },
      (_) async {
        // Update repository
        if (_selectedPrinterAddress != null) {
          await printerRepository.updatePrinterConnectionStatus(
            _selectedPrinterAddress!,
            false,
          );
        }
        emit(const PrinterDisconnected());
      },
    );
  }

  /// Handler: Print receipt requested
  Future<void> _onPrintReceiptRequested(
    PrintReceiptRequested event,
    Emitter<PrinterState> emit,
  ) async {
    emit(const PrinterPrinting());

    final result = await printReceipt.execute(event.receipt);

    result.fold(
      (failure) {
        emit(PrinterErrorState(failure.message));
        add(PrinterError(failure.message));
      },
      (_) => add(const PrintSuccess()),
    );
  }

  /// Handler: Print success
  Future<void> _onPrintSuccess(
    PrintSuccess event,
    Emitter<PrinterState> emit,
  ) async {
    emit(const PrinterPrintSuccess());

    // Auto-reset to connected state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (state is PrinterPrintSuccess) {
        // Return to connected state
        // Don't emit if BLoC is closed
      }
    });
  }

  /// Handler: Printer error
  Future<void> _onPrinterError(
    PrinterError event,
    Emitter<PrinterState> emit,
  ) async {
    // Don't change state if we're in a stable state
    // Just emit error for UI to show snackbar
    if (state is! PrinterErrorState) {
      // Keep current state, error is shown via UI feedback
    }
  }

  /// Handler: Set default printer
  Future<void> _onSetDefaultPrinterRequested(
    SetDefaultPrinterRequested event,
    Emitter<PrinterState> emit,
  ) async {
    // Find the printer in current state
    if (state is PrintersDiscoveredState) {
      final printers = (state as PrintersDiscoveredState).printers;
      final printer = printers.firstWhere(
        (p) => p.address == event.address,
        orElse: () => const PrinterDevice(address: '', name: ''),
      );

      if (printer.address.isNotEmpty) {
        await printerRepository.saveDefaultPrinter(printer);
      }
    }
  }

  /// Handler: Connection status changed
  Future<void> _onConnectionStatusChanged(
    PrinterConnectionStatusChanged event,
    Emitter<PrinterState> emit,
  ) async {
    if (!event.isConnected) {
      emit(const PrinterDisconnected());
    }
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}
