import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/printer_device.dart';
import '../models/printer_device_hive_model.dart';

/// Hive Printer Repository
/// Stores printer settings and preferences in Hive
/// 
/// This repository handles:
/// - Default printer storage
/// - Recently connected printers list
/// - Printer configuration persistence
class HivePrinterRepository {
  static const String _boxName = 'printer_settings';
  static const String _defaultPrinterKey = 'default_printer';
  static const String _recentPrintersKey = 'recent_printers';

  Box<PrinterDeviceHiveModel>? _box;

  /// Initializes the Hive box
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<PrinterDeviceHiveModel>(_boxName);
    } catch (e) {
      print('Failed to initialize printer settings box: $e');
      rethrow;
    }
  }

  /// Saves a printer as the default printer
  Future<bool> saveDefaultPrinter(PrinterDevice printer) async {
    try {
      await _box?.put(_defaultPrinterKey, PrinterDeviceHiveModel.fromEntity(printer));
      return true;
    } catch (e) {
      print('Failed to save default printer: $e');
      return false;
    }
  }

  /// Gets the default printer
  Future<PrinterDevice?> getDefaultPrinter() async {
    try {
      final model = _box?.get(_defaultPrinterKey) as PrinterDeviceHiveModel?;
      return model?.toEntity();
    } catch (e) {
      print('Failed to get default printer: $e');
      return null;
    }
  }

  /// Removes the default printer setting
  Future<bool> clearDefaultPrinter() async {
    try {
      await _box?.delete(_defaultPrinterKey);
      return true;
    } catch (e) {
      print('Failed to clear default printer: $e');
      return false;
    }
  }

  /// Adds a printer to the recently connected list
  Future<bool> addRecentPrinter(PrinterDevice printer) async {
    try {
      final recent = await getRecentPrinters();
      
      // Remove if already exists
      recent.removeWhere((p) => p.address == printer.address);
      
      // Add to front
      recent.insert(0, printer.copyWith(isConnected: false));
      
      // Keep only last 5
      if (recent.length > 5) {
        recent.removeRange(5, recent.length);
      }

      // Save to Hive
      final models = recent.map((p) => PrinterDeviceHiveModel.fromEntity(p)).toList();
      await _box?.put(_recentPrintersKey, models);
      
      return true;
    } catch (e) {
      print('Failed to add recent printer: $e');
      return false;
    }
  }

  /// Gets the list of recently connected printers
  Future<List<PrinterDevice>> getRecentPrinters() async {
    try {
      final models = _box?.get(_recentPrintersKey) as List<dynamic>?;
      if (models == null) return [];

      return models
          .whereType<PrinterDeviceHiveModel>()
          .map((m) => m.toEntity())
          .toList();
    } catch (e) {
      print('Failed to get recent printers: $e');
      return [];
    }
  }

  /// Clears the recent printers list
  Future<bool> clearRecentPrinters() async {
    try {
      await _box?.delete(_recentPrintersKey);
      return true;
    } catch (e) {
      print('Failed to clear recent printers: $e');
      return false;
    }
  }

  /// Updates the connection status of a printer
  Future<bool> updatePrinterConnectionStatus(String address, bool isConnected) async {
    try {
      // Update default printer if matches
      final defaultPrinter = await getDefaultPrinter();
      if (defaultPrinter?.address == address) {
        await saveDefaultPrinter(defaultPrinter!.copyWith(isConnected: isConnected));
      }

      // Update recent printers
      final recent = await getRecentPrinters();
      final index = recent.indexWhere((p) => p.address == address);
      if (index != -1) {
        recent[index] = recent[index].copyWith(isConnected: isConnected);
        final models = recent.map((p) => PrinterDeviceHiveModel.fromEntity(p)).toList();
        await _box?.put(_recentPrintersKey, models);
      }

      return true;
    } catch (e) {
      print('Failed to update printer connection status: $e');
      return false;
    }
  }

  /// Closes the Hive box
  Future<void> close() async {
    try {
      await _box?.close();
    } catch (e) {
      print('Failed to close printer settings box: $e');
    }
  }
}
