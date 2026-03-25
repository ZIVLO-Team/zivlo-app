import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../domain/entities/cart_item.dart';
import '../../application/usecases/add_to_cart.dart';
import '../../application/usecases/remove_from_cart.dart';
import '../../application/usecases/update_cart_item_quantity.dart';
import '../../application/usecases/apply_discount.dart';
import '../../application/usecases/clear_cart.dart';
import '../../application/usecases/get_cart.dart';

/// Cart BLoC - Business Logic Component
/// Handles all cart-related business logic
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCart getCart;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UndoRemoveItem undoRemoveItem;
  final UpdateCartItemQuantity updateItemQuantity;
  final ApplyDiscount applyDiscount;
  final ClearCart clearCart;
  
  CartItem? _lastRemovedItem;  // Para funcionalidad de undo
  Timer? _undoTimer;  // Timer para limpiar el undo después de 3 segundos
  
  CartBloc({
    required this.getCart,
    required this.addToCart,
    required this.removeFromCart,
    required this.undoRemoveItem,
    required this.updateItemQuantity,
    required this.applyDiscount,
    required this.clearCart,
  }) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItem>(_onRemoveItem);
    on<UndoRemoveItemEvent>(_onUndoRemoveItem);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<ClearDiscountEvent>(_onClearDiscount);
    on<ClearCartEvent>(_onClearCart);
  }
  
  /// Handler: Load current cart
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    
    final result = await getCart.execute();
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
  }
  
  /// Handler: Add item to cart
  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) {
      // Si no hay carrito cargado, cargar primero
      await _onLoadCart(LoadCart(), emit);
    }
    
    final result = await addToCart.execute(event.product, event.quantity);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
  }
  
  /// Handler: Remove item from cart (with undo)
  Future<void> _onRemoveItem(RemoveItem event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;
    
    // Guardar ítem para undo
    final itemToRemove = currentState.cart.items.firstWhere(
      (item) => item.id == event.itemId,
      orElse: () => throw Exception('Item not found'),
    );
    _lastRemovedItem = itemToRemove;
    
    // Programar limpieza del undo después de 3 segundos
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 3), () {
      _lastRemovedItem = null;
      _undoTimer = null;
    });
    
    final result = await removeFromCart.execute(event.itemId);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
  }
  
  /// Handler: Undo remove item
  Future<void> _onUndoRemoveItem(UndoRemoveItemEvent event, Emitter<CartState> emit) async {
    if (_lastRemovedItem == null) return;
    
    final result = await undoRemoveItem.execute(_lastRemovedItem!);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) {
        _undoTimer?.cancel();
        _lastRemovedItem = null;
        _undoTimer = null;
        emit(CartLoaded(cart: cart, lastRemovedItem: null));
      },
    );
  }
  
  /// Handler: Update item quantity
  Future<void> _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<CartState> emit) async {
    final result = await updateItemQuantity.execute(event.itemId, event.quantity);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) {
        if (state is CartLoaded) {
          emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem));
        }
      },
    );
  }
  
  /// Handler: Apply discount
  Future<void> _onApplyDiscount(ApplyDiscountEvent event, Emitter<CartState> emit) async {
    final result = await applyDiscount.execute(event.discount);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) {
        if (state is CartLoaded) {
          emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem));
        }
      },
    );
  }
  
  /// Handler: Clear discount
  Future<void> _onClearDiscount(ClearDiscountEvent event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;
    
    final result = await removeFromCart.clearDiscount();
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
  }
  
  /// Handler: Clear cart
  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    final result = await clearCart.execute();
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) {
        _lastRemovedItem = null;
        _undoTimer?.cancel();
        emit(CartCleared());
      },
    );
  }
  
  @override
  Future<void> close() {
    _undoTimer?.cancel();
    return super.close();
  }
}
