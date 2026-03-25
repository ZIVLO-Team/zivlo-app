import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zivlo/core/theme/app_theme.dart';
/// Product Form Fields
///
/// Reusable form field widgets for the product form page
///
/// Includes:
/// - ProductNameField: TextFormField for product name
/// - ProductPriceField: TextFormField for price with currency prefix
/// - ProductBarcodeField: TextFormField for barcode with scan button
/// - ProductCategoryField: Dropdown for category selection
/// - ProductStockField: TextFormField for stock (integer)

/// Product Name Field
///
/// TextFormField for product name
/// - Texto, requerido, max 60 chars
class ProductNameField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const ProductNameField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre del producto',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        TextFormField(
          controller: controller,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Ej: Agua Mineral 500ml',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
            ),
            prefixIcon: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.colorOnSurfaceMuted,
            ),
            filled: true,
            fillColor: AppColors.colorSurfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length > 60) {
              return 'Máximo 60 caracteres';
            }
            return null;
          },
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}

/// Product Price Field
///
/// TextFormField for price with currency prefix
/// - Numérico con decimales, requerido
class ProductPriceField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const ProductPriceField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Precio',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.colorAccent,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: GoogleFonts.spaceMono(
              fontSize: 16,
              color: AppColors.colorOnSurfaceMuted,
            ),
            prefixText: '\$ ',
            prefixStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: AppColors.colorSurfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El precio es requerido';
            }
            final price = double.tryParse(value);
            if (price == null) {
              return 'Ingresa un precio válido';
            }
            if (price < 0) {
              return 'El precio no puede ser negativo';
            }
            return null;
          },
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}

/// Product Barcode Field
///
/// TextFormField for barcode with scan button
/// - Texto, opcional, con botón de escanear
class ProductBarcodeField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onScan;
  final VoidCallback? onChanged;

  const ProductBarcodeField({
    super.key,
    required this.controller,
    required this.onScan,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código de barras (opcional)',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        TextFormField(
          controller: controller,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Ej: 7501234567890',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
            ),
            prefixIcon: const Icon(
              Icons.qr_code_scanner,
              color: AppColors.colorOnSurfaceMuted,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              color: AppColors.colorAccent,
              onPressed: onScan,
              tooltip: 'Escanear código de barras',
            ),
            filled: true,
            fillColor: AppColors.colorSurfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}

/// Product Category Field
///
/// Dropdown for category selection with option to add new category
/// - Dropdown con opciones existentes + "Nueva categoría"
class ProductCategoryField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> existingCategories;
  final VoidCallback? onChanged;

  const ProductCategoryField({
    super.key,
    required this.controller,
    required this.existingCategories,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Selecciona una categoría',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
            ),
            prefixIcon: const Icon(
              Icons.category_outlined,
              color: AppColors.colorOnSurfaceMuted,
            ),
            filled: true,
            fillColor: AppColors.colorSurfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          items: [
            ...existingCategories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )),
          ],
          onChanged: (value) {
            controller.text = value ?? '';
            onChanged?.call();
          },
        ),
        const SizedBox(height: AppSpacing.spacing8),
        Text(
          'Para agregar una nueva categoría, simplemente escribe el nombre en el campo de texto',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.colorOnSurfaceMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        TextFormField(
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurface,
          ),
          decoration: InputDecoration(
            hintText: 'O escribe una nueva categoría',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
            ),
            filled: true,
            fillColor: AppColors.colorSurfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            controller.text = value;
            onChanged?.call();
          },
        ),
      ],
    );
  }
}

/// Product Stock Field
///
/// TextFormField for stock (integer)
/// - Numérico entero, requerido
class ProductStockField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const ProductStockField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock inicial',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.colorOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        TextFormField(
          controller: controller,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Ej: 100',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.colorOnSurfaceMuted,
            ),
            prefixIcon: const Icon(
              Icons.inventory_outlined,
              color: AppColors.colorOnSurfaceMuted,
            ),
            filled: true,
            fillColor: AppColors.colorSurfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.colorError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El stock es requerido';
            }
            final stock = int.tryParse(value);
            if (stock == null) {
              return 'Ingresa un número válido';
            }
            if (stock < 0) {
              return 'El stock no puede ser negativo';
            }
            return null;
          },
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}
