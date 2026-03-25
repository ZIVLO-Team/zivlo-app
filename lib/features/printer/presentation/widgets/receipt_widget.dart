import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/receipt.dart';

/// Receipt Widget
/// Displays a visual preview of the receipt exactly as it will print
/// 
/// Features:
/// - White paper-like card on dark background
/// - Space Mono font for all content (monospace for thermal printer simulation)
/// - Proper formatting for 58mm thermal paper (32 chars per line)
/// - Centered layout with proper padding
/// - Shows all receipt sections: header, items, totals, footer
class ReceiptWidget extends StatelessWidget {
  final Receipt receipt;

  const ReceiptWidget({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          _buildHeader(),
          
          const SizedBox(height: 12),
          
          // Date and ticket number
          _buildMetaInfo(),
          
          const SizedBox(height: 8),
          
          // Items header
          _buildItemsHeader(),
          
          const Divider(height: 1),
          
          // Items list
          ...receipt.items.map((item) => _buildItemRow(item)),
          
          const Divider(height: 1),
          
          // Totals section
          _buildTotals(),
          
          // Payment info
          _buildPaymentInfo(),
          
          const SizedBox(height: 12),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  /// Builds the receipt header with business info
  Widget _buildHeader() {
    return Column(
      children: [
        // Top separator
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '================================',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Business name
        Text(
          receipt.businessName,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        if (receipt.businessTaxId != null) ...[
          const SizedBox(height: 4),
          Text(
            receipt.businessTaxId!,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
        
        if (receipt.businessAddress != null) ...[
          const SizedBox(height: 4),
          Text(
            receipt.businessAddress!,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        // Custom header if present
        if (receipt.receiptHeader != null && receipt.receiptHeader!.isNotEmpty) ...[
          Text(
            receipt.receiptHeader!,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Bottom separator
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '================================',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds date and ticket number row
  Widget _buildMetaInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ticket #: ${receipt.receiptNumber}',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          Text(
            receipt.formattedDate,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the items table header
  Widget _buildItemsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'QTY',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ITEM',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'SUBTOTAL',
              textAlign: TextAlign.right,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single item row
  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}x',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _truncateName(item.name),
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.formattedSubtotal,
              textAlign: TextAlign.right,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the totals section
  Widget _buildTotals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Subtotal
          _buildTotalRow(
            label: 'Subtotal:',
            value: receipt.formattedSubtotal,
          ),
          
          // Discount (if applicable)
          if (receipt.hasDiscount) ...[
            const SizedBox(height: 4),
            _buildTotalRow(
              label: 'Discount:',
              value: receipt.formattedDiscount,
              valueColor: AppColors.colorSuccess,
            ),
          ],
          
          const SizedBox(height: 8),
          
          // Double separator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '================================',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Total
          _buildTotalRow(
            label: 'TOTAL:',
            value: receipt.formattedTotal,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  /// Builds a single total row
  Widget _buildTotalRow({
    required String label,
    required String value,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.colorTotal,
          ),
        ),
      ],
    );
  }

  /// Builds payment information section
  Widget _buildPaymentInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment:',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              Text(
                receipt.paymentMethod,
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          if (receipt.hasChange) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change:',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: AppColors.colorChange,
                  ),
                ),
                Text(
                  receipt.formattedChange,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: AppColors.colorChange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the footer section
  Widget _buildFooter() {
    return Column(
      children: [
        // Bottom separator
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '================================',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Custom footer
        if (receipt.hasFooter) ...[
          Text(
            receipt.receiptFooter!,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
        ],
        
        // Thank you message
        Text(
          'Thank you!',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Bottom separator
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '================================',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  /// Truncates item name to fit thermal paper width
  String _truncateName(String name) {
    const maxLength = 18;
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength - 2)}..';
  }
}
