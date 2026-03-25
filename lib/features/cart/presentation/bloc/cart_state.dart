import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

/// Cart State - Base class
abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class CartInitial extends CartState {
  @override
  List<Object?> get props => [];
}

/// Loading state
class CartLoading extends CartState {
  @override
  List<Object?> get props => [];
}

/// Loaded state with cart
class CartLoaded extends CartState {
  final Cart cart;
  final CartItem? lastRemovedItem;  // Para funcionalidad de undo
  
  const CartLoaded({
    required this.cart,
    this.lastRemovedItem,
  });
  
  @override
  List<Object?> get props => [cart, lastRemovedItem];
}

/// Error state
class CartError extends CartState {
  final String message;
  
  const CartError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Cart cleared successfully
class CartCleared extends CartState {
  @override
  List<Object?> get props => [];
}
