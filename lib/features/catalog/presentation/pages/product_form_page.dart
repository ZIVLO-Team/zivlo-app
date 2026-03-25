import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/dtos/product_dto.dart';
import '../../injection_container.dart' as catalog_di;
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/product_form_fields.dart';

/// Product Form Page
///
/// Create or Edit product form page
///
/// Features:
/// - AppBar con título "Nuevo producto" o "Editar producto"
/// - Botón de guardar en AppBar (disabled si formulario inválido)
/// - Formulario con campos: nombre, precio, código de barras, categoría, stock
/// - Validación en tiempo real
/// - Guarda producto al presionar guardar
/// - Vuelve atrás al guardar exitosamente
class ProductFormPage extends StatefulWidget {
  /// Product to edit (null for new product)
  final dynamic product;

  const ProductFormPage({
    super.key,
    this.product,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final CatalogBloc _catalogBloc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  List<String> _existingCategories = [];

  @override
  void initState() {
    super.initState();
    _catalogBloc = catalog_di.sl<CatalogBloc>();
    _isEditing = widget.product != null;

    if (_isEditing) {
      _populateForm();
    }

    // Load existing categories
    _catalogBloc.add(LoadAllProducts());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _catalogBloc.close();
    super.dispose();
  }

  void _populateForm() {
    setState(() {
      _nameController.text = widget.product.name;
      _priceController.text = widget.product.price.toStringAsFixed(2);
      _barcodeController.text = widget.product.barcode ?? '';
      _categoryController.text = widget.product.category ?? '';
      _stockController.text = widget.product.stock.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar producto' : 'Nuevo producto';

    return BlocProvider.value(
      value: _catalogBloc,
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.colorSurface,
          foregroundColor: AppColors.colorOnSurface,
          elevation: 0,
          actions: [
            BlocBuilder<CatalogBloc, CatalogState>(
              builder: (context, state) {
                _isLoading = state is CatalogLoading;

                return IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.colorOnSurface,
                          ),
                        )
                      : const Icon(Icons.save),
                  onPressed: _isLoading ? null : _saveProduct,
                  tooltip: 'Guardar',
                );
              },
            ),
          ],
        ),
        body: BlocListener<CatalogBloc, CatalogState>(
          listener: (context, state) {
            if (state is CatalogLoaded) {
              setState(() {
                _existingCategories = state.categories;
              });
            }

            if (state is ProductCreatedSuccess ||
                state is ProductUpdatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isEditing
                        ? 'Producto actualizado exitosamente'
                        : 'Producto creado exitosamente',
                  ),
                  backgroundColor: AppColors.colorSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
                  ),
                ),
              );
              Navigator.pop(context);
            }

            if (state is CatalogError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.colorError,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
                  ),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Name
                  ProductNameField(
                    controller: _nameController,
                    onChanged: () => _validateForm(),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),

                  // Price
                  ProductPriceField(
                    controller: _priceController,
                    onChanged: () => _validateForm(),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),

                  // Barcode
                  ProductBarcodeField(
                    controller: _barcodeController,
                    onScan: _handleScan,
                    onChanged: () => _validateForm(),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),

                  // Category
                  ProductCategoryField(
                    controller: _categoryController,
                    existingCategories: _existingCategories,
                    onChanged: () => _validateForm(),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),

                  // Stock
                  ProductStockField(
                    controller: _stockController,
                    onChanged: () => _validateForm(),
                  ),
                  const SizedBox(height: AppSpacing.spacing48),

                  // Save Button (for mobile convenience)
                  ElevatedButton(
                    onPressed: _validateForm() ? _saveProduct : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorAccent,
                      foregroundColor: AppColors.colorOnSurface,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusMedium),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.colorOnSurface,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Actualizar producto' : 'Crear producto',
                            style: AppTypography.textTheme.labelLarge,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {}); // Trigger rebuild to update save button
    return isValid;
  }

  void _handleScan() {
    // TODO: Navigate to scanner and get barcode
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de escáner no implementada'),
        backgroundColor: AppColors.colorSurfaceVariant,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dto = ProductDTO(
      id: _isEditing ? widget.product.id : null,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      stock: int.parse(_stockController.text),
    );

    if (_isEditing) {
      _catalogBloc.add(UpdateProductEvent(dto));
    } else {
      _catalogBloc.add(CreateProductEvent(dto));
    }
  }
}
