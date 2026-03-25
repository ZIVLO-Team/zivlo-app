import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../injection_container.dart' as catalog_di;
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/empty_catalog_widget.dart';

/// Catalog Page
///
/// Main catalog listing page displaying all products in a grid
///
/// Features:
/// - AppBar with title "Catálogo" y botón "+" para agregar producto
/// - SearchBar siempre visible debajo del AppBar
/// - Category filter chips en scroll horizontal
/// - Grid de 2 columnas con ProductCards
/// - Empty state si no hay productos
/// - FAB para agregar nuevo producto
/// - Navega a ProductFormPage para crear/editar
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final CatalogBloc _catalogBloc;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _catalogBloc = catalog_di.sl<CatalogBloc>();
    _catalogBloc.add(LoadAllProducts());
  }

  @override
  void dispose() {
    _catalogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _catalogBloc,
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        appBar: AppBar(
          title: const Text('Catálogo'),
          backgroundColor: AppColors.colorSurface,
          foregroundColor: AppColors.colorOnSurface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _navigateToProductForm,
              tooltip: 'Agregar producto',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            ProductSearchBar(
              onSearch: (query) {
                if (query.isEmpty) {
                  _catalogBloc.add(ClearSearch());
                } else {
                  _catalogBloc.add(SearchProductsEvent(query));
                }
              },
            ),

            // Category Filter Chips
            _buildCategoryFilter(),

            // Product Grid or Empty State
            Expanded(
              child: BlocBuilder<CatalogBloc, CatalogState>(
                builder: (context, state) {
                  if (state is CatalogLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.colorAccent,
                      ),
                    );
                  }

                  if (state is CatalogError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.colorOnSurfaceMuted,
                          ),
                          const SizedBox(height: AppSpacing.spacing16),
                          Text(
                            'Error al cargar productos',
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: AppColors.colorOnSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing8),
                          Text(
                            state.message,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.colorOnSurfaceMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CatalogLoaded) {
                    final products = state.filteredProducts;

                    // Filter by category if selected
                    final filteredProducts = _selectedCategory != null
                        ? products
                            .where((p) =>
                                p.category?.trim().toLowerCase() ==
                                _selectedCategory!.trim().toLowerCase())
                            .toList()
                        : products;

                    if (filteredProducts.isEmpty) {
                      return EmptyCatalogWidget(
                        onAddProduct: _navigateToProductForm,
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.spacing16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.spacing16,
                          mainAxisSpacing: AppSpacing.spacing16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => _navigateToProductForm(product),
                          );
                        },
                      ),
                    );
                  }

                  // Initial state - empty
                  return EmptyCatalogWidget(
                    onAddProduct: _navigateToProductForm,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToProductForm,
          backgroundColor: AppColors.colorAccent,
          foregroundColor: AppColors.colorOnSurface,
          icon: const Icon(Icons.add),
          label: const Text('Producto'),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state is! CatalogLoaded) {
          return const SizedBox.shrink();
        }

        final categories = state.categories;

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing8,
            ),
            children: [
              // "Todas" chip
              CategoryFilterChip(
                label: 'Todas',
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(width: AppSpacing.spacing8),
              // Category chips
              ...categories.map((category) => Padding(
                    padding:
                        const EdgeInsets.only(right: AppSpacing.spacing8),
                    child: CategoryFilterChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              _selectedCategory == category
                                  ? null
                                  : category;
                        });
                      },
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProductForm([dynamic product]) {
    // TODO: Navigate to ProductFormPage
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product != null
              ? 'Editar producto: ${product.name}'
              : 'Nuevo producto',
        ),
        backgroundColor: AppColors.colorSurfaceVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        ),
      ),
    );
  }
}
