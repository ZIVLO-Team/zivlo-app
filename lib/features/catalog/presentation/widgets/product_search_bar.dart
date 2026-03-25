import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zivlo/core/theme/app_theme.dart';
/// Product Search Bar Widget
///
/// Search bar for filtering products by name or barcode
///
/// Features:
/// - SearchBar siempre visible
/// - Icono de búsqueda a la izquierda
/// - Botón de limpiar (X) cuando hay texto
/// - Actualiza CatalogBloc con SearchProductsEvent
/// - Búsqueda con debounce para evitar búsquedas prematuras
class ProductSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const ProductSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer with debounce
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      color: AppColors.colorSurface,
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.colorOnSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o código...',
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.colorOnSurfaceMuted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.colorOnSurfaceMuted,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.clear),
                color: AppColors.colorOnSurfaceMuted,
                onPressed: _clearSearch,
                tooltip: 'Limpiar búsqueda',
              );
            },
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
      ),
    );
  }
}
