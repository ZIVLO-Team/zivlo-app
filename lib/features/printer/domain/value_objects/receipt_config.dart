import 'package:equatable/equatable.dart';

/// Receipt Print Configuration
/// Defines how the receipt should be printed
/// Includes paper size, alignment, and formatting options
class ReceiptConfig extends Equatable {
  /// Paper width in millimeters (58mm or 80mm)
  final int paperWidthMm;

  /// Characters per line based on paper width
  /// 58mm ≈ 32 chars, 80mm ≈ 48 chars
  final int charactersPerLine;

  /// Whether to center-align the header
  final bool centerHeader;

  /// Whether to include separator lines
  final bool includeSeparators;

  /// Whether to include custom footer
  final bool includeFooter;

  const ReceiptConfig({
    this.paperWidthMm = 58,
    this.charactersPerLine = 32,
    this.centerHeader = true,
    this.includeSeparators = true,
    this.includeFooter = true,
  });

  /// Factory constructor for 58mm paper (most common for portable printers)
  factory ReceiptConfig.paper58mm() {
    return const ReceiptConfig(
      paperWidthMm: 58,
      charactersPerLine: 32,
    );
  }

  /// Factory constructor for 80mm paper (desktop printers)
  factory ReceiptConfig.paper80mm() {
    return const ReceiptConfig(
      paperWidthMm: 80,
      charactersPerLine: 48,
    );
  }

  /// Returns the separator line based on characters per line
  String get separatorLine => '-' * charactersPerLine;

  /// Returns the double separator line
  String get doubleSeparator => '=' * charactersPerLine;

  /// Centers text within the character limit
  String centerText(String text) {
    if (!centerHeader) return text;
    final padding = (charactersPerLine - text.length) ~/ 2;
    if (padding <= 0) return text;
    return ' ' * padding + text;
  }

  /// Truncates text to fit within character limit
  String truncateText(String text) {
    if (text.length <= charactersPerLine) return text;
    return text.substring(0, charactersPerLine - 3) + '...';
  }

  @override
  List<Object?> get props => [
        paperWidthMm,
        charactersPerLine,
        centerHeader,
        includeSeparators,
        includeFooter,
      ];

  @override
  String toString() {
    return 'ReceiptConfig(paperWidth: ${paperWidthMm}mm, '
        'charsPerLine: $charactersPerLine)';
  }
}
