import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/cart/presentation/bloc/cart_state.dart';
import 'features/catalog/domain/entities/product.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await di.initializeDependencies();
  
  // Run app
  runApp(const ZivloApp());
}

/// Main Application Widget
class ZivloApp extends StatelessWidget {
  const ZivloApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: di.getBlocProviders(),
      child: MaterialApp(
        title: 'Zivlo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: AppColors.colorPrimary,
          scaffoldBackgroundColor: AppColors.colorBackground,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.colorPrimary,
            secondary: AppColors.colorAccent,
            surface: AppColors.colorSurface,
            error: AppColors.colorError,
            onPrimary: AppColors.colorOnSurface,
            onSecondary: AppColors.colorOnSurface,
            onSurface: AppColors.colorOnSurface,
            onError: AppColors.colorOnSurface,
          ),
          textTheme: AppTypography.textTheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.colorPrimary,
            foregroundColor: AppColors.colorOnSurface,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardTheme(
            color: AppColors.colorSurface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorAccent,
              foregroundColor: AppColors.colorOnSurface,
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing24,
                vertical: AppSpacing.spacing16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusXL),
              ),
              textStyle: AppTypography.textTheme.labelLarge,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.colorAccent,
            foregroundColor: AppColors.colorOnSurface,
            elevation: 6,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.colorSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide(color: AppColors.colorOnSurfaceMuted, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(color: AppColors.colorAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(color: AppColors.colorError, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
        ),
        home: const CartTestPage(),
      ),
    );
  }
}

/// Test Page for Cart Feature
/// This is a temporary page to test the Cart BLoC
class CartTestPage extends StatefulWidget {
  const CartTestPage({super.key});
  
  @override
  State<CartTestPage> createState() => _CartTestPageState();
}

class _CartTestPageState extends State<CartTestPage> {
  @override
  void initState() {
    super.initState();
    // Load cart on init
    context.read<CartBloc>().add(LoadCart());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zivlo - Cart Test'),
        actions: [
          // Cart badge
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Ítems: ${state.cart.itemCount}',
                      style: const TextStyle(
                        color: AppColors.colorOnSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CartError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is CartLoaded) {
            final cart = state.cart;
            
            if (cart.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.colorOnSurfaceMuted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Carrito vacío',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.colorOnSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Cart items
                ...cart.items.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Precio: \$${item.unitPrice.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            // Decrease quantity
                            if (item.quantity > 1) {
                              context.read<CartBloc>().add(
                                UpdateItemQuantity(item.id, item.quantity - 1),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            // Increase quantity
                            context.read<CartBloc>().add(
                              UpdateItemQuantity(item.id, item.quantity + 1),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.colorError),
                          onPressed: () {
                            // Remove item
                            context.read<CartBloc>().add(RemoveItem(item.id));
                          },
                        ),
                      ],
                    ),
                  ),
                )),
                
                const Divider(height: 32),
                
                // Summary
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Subtotal: ', style: TextStyle(fontSize: 16)),
                          Text(
                            '\$${cart.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (cart.discount != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Descuento: ', style: TextStyle(fontSize: 16)),
                            Text(
                              '-\$${cart.discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.colorSuccess,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Total: ', style: TextStyle(fontSize: 20)),
                          Text(
                            '\$${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.colorAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Clear cart button
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<CartBloc>().add(ClearCartEvent());
                  },
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Vaciar carrito'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorError,
                  ),
                ),
              ],
            );
          }
          
          return const Center(child: Text('Presiona + para agregar productos de prueba'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add test product
          final testProduct = Product(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Producto de Prueba',
            price: 9.99,
            barcode: '123456789',
            category: 'Test',
            stock: 100,
            createdAt: DateTime.now(),
          );
          
          context.read<CartBloc>().add(AddItemToCart(testProduct, 1));
          
          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto agregado al carrito')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Producto'),
      ),
    );
  }
}
