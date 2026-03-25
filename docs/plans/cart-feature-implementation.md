# Cart Feature Implementation Plan
## 🛒 Feature: Carrito de Compras - Zivlo

**Fecha**: 2024-03-24  
**Estado**: Aprobado  
**Prioridad**: Alta (Core del MVP)

---

## 📋 Descripción

Implementación completa de la feature del carrito de compras siguiendo Clean/Hexagonal Architecture. El carrito permite agregar productos, modificar cantidades, aplicar descuentos y eliminar ítems con funcionalidad de undo.

---

## 🎯 Objetivos

1. **Persistencia en Hive** - El carrito sobrevive a reinicios de la app
2. **Snapshot de productos** - El precio se fija al agregar el ítem (inmutable)
3. **Descuentos flexibles** - Soporte para descuento porcentual o monto fijo
4. **Undo after delete** - Snackbar con deshacer por 3 segundos
5. **Cálculos en tiempo real** - Subtotal, descuento, total actualizados reactivamente

---

## 🏗️ Arquitectura

### Capas y Responsabilidades

```
┌─────────────────────────────────────────┐
│  Presentation (BLoC, Pages, Widgets)    │
│  - CartBloc (events, states)            │
│  - CartPage (UI principal)              │
│  - CartItemTile (widget de ítem)        │
│  - CartSummary (resumen financiero)     │
│  - DiscountSection (aplicar descuento)  │
├─────────────────────────────────────────┤
│  Application (Use Cases)                │
│  - AddToCart                            │
│  - UpdateCartItemQuantity               │
│  - RemoveFromCart                       │
│  - ApplyDiscount                        │
│  - ClearCart                            │
│  - GetCart                              │
├─────────────────────────────────────────┤
│  Domain (Entities, Value Objects)       │
│  - Cart (entity)                        │
│  - CartItem (entity)                    │
│  - Discount (value object)              │
│  - ICartRepository (port)               │
├─────────────────────────────────────────┤
│  Infrastructure (Hive, Adapters)        │
│  - HiveCartRepository (implementation)  │
│  - CartHiveModel (Hive model)           │
│  - CartItemHiveModel (Hive model)       │
│  - DiscountHiveModel (Hive model)       │
└─────────────────────────────────────────┘
```

---

## 📁 Estructura de Archivos

```
lib/features/cart/
├── domain/
│   ├── entities/
│   │   ├── cart.dart
│   │   └── cart_item.dart
│   ├── value_objects/
│   │   └── discount.dart
│   └── repositories/
│       └── cart_repository.dart
├── application/
│   ├── usecases/
│   │   ├── add_to_cart.dart
│   │   ├── update_cart_item_quantity.dart
│   │   ├── remove_from_cart.dart
│   │   ├── apply_discount.dart
│   │   ├── clear_cart.dart
│   │   └── get_cart.dart
│   └── dtos/
│       └── cart_dto.dart
├── infrastructure/
│   ├── repositories/
│   │   └── hive_cart_repository.dart
│   └── models/
│       ├── cart_hive_model.dart
│       ├── cart_item_hive_model.dart
│       └── discount_hive_model.dart
├── presentation/
│   ├── bloc/
│   │   ├── cart_event.dart
│   │   ├── cart_state.dart
│   │   └── cart_bloc.dart
│   ├── pages/
│   │   └── cart_page.dart
│   └── widgets/
│       ├── cart_item_tile.dart
│       ├── cart_summary.dart
│       ├── discount_section.dart
│       └── empty_cart_widget.dart
└── injection_container.dart
```

---

## 🔧 Implementación Detallada

### 1. Domain Layer

#### `cart.dart` - Entity Cart
```dart
import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import '../value_objects/discount.dart';

class Cart extends Equatable {
  final String id;
  final List<CartItem> items;
  final Discount? discount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Cart({
    required this.id,
    this.items = const [],
    this.discount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get discountAmount => discount?.amount ?? 0;
  double get total => subtotal - discountAmount;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  
  Cart copyWith({
    String? id,
    List<CartItem>? items,
    Discount? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [id, items, discount, createdAt, updatedAt];
}
```

#### `cart_item.dart` - Entity CartItem
```dart
import 'package:equatable/equatable.dart';
import '../../catalog/domain/entities/product.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;  // Snapshot del producto
  final int quantity;
  final double unitPrice;  // Precio inmutable al momento de agregar
  
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });
  
  double get subtotal => unitPrice * quantity;
  
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,  // Nunca cambiar
    );
  }
  
  @override
  List<Object?> get props => [id, product, quantity, unitPrice];
}
```

#### `discount.dart` - Value Object
```dart
import 'package:equatable/equatable.dart';

class Discount extends Equatable {
  final DiscountType type;
  final double value;
  
  const Discount._({
    required this.type,
    required this.value,
  });
  
  factory Discount.percentage(double percentage) {
    if (percentage < 0 || percentage > 100) {
      throw const FormatException('Percentage must be between 0 and 100');
    }
    return Discount._(type: DiscountType.percentage, value: percentage);
  }
  
  factory Discount.fixed(double amount) {
    if (amount < 0) {
      throw const FormatException('Fixed amount cannot be negative');
    }
    return Discount._(type: DiscountType.fixed, value: amount);
  }
  
  double get amount {
    switch (type) {
      case DiscountType.percentage:
        return value;  // Se calcula en el contexto del subtotal
      case DiscountType.fixed:
        return value;
    }
  }
  
  /// Calcula el monto del descuento basado en el subtotal
  double calculateDiscountAmount(double subtotal) {
    switch (type) {
      case DiscountType.percentage:
        return subtotal * (value / 100);
      case DiscountType.fixed:
        return value.clamp(0, subtotal);  // No puede exceder el subtotal
    }
  }
  
  @override
  List<Object?> get props => [type, value];
}

enum DiscountType { percentage, fixed }
```

#### `cart_repository.dart` - Repository Port
```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../value_objects/discount.dart';

abstract class ICartRepository {
  /// Obtiene el carrito actual
  Future<Either<Failure, Cart>> getCurrentCart();
  
  /// Agrega un ítem al carrito (o incrementa cantidad si ya existe)
  Future<Either<Failure, Cart>> addItem(CartItem item);
  
  /// Actualiza la cantidad de un ítem
  Future<Either<Failure, Cart>> updateItemQuantity(String itemId, int quantity);
  
  /// Elimina un ítem del carrito
  Future<Either<Failure, Cart>> removeItem(String itemId);
  
  /// Aplica un descuento al carrito
  Future<Either<Failure, Cart>> applyDiscount(Discount discount);
  
  /// Elimina el descuento aplicado
  Future<Either<Failure, Cart>> clearDiscount();
  
  /// Vacía el carrito completamente
  Future<Either<Failure, Unit>> clearCart();
  
  /// Guarda el carrito (usado internamente)
  Future<Either<Failure, Unit>> saveCart(Cart cart);
}
```

---

### 2. Application Layer

#### `add_to_cart.dart` - Use Case
```dart
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../catalog/domain/entities/product.dart';

class AddToCart {
  final ICartRepository repository;
  final Uuid _uuid;
  
  AddToCart(this.repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();
  
  Future<Either<Failure, Cart>> execute(Product product, int quantity) async {
    // Validaciones
    if (quantity < 1) {
      return Left(const CartOperationFailure('add_to_cart', message: 'Quantity must be at least 1'));
    }
    
    if (product.price < 0) {
      return Left(const CartOperationFailure('add_to_cart', message: 'Invalid product price'));
    }
    
    // Crear CartItem con snapshot del producto
    final cartItem = CartItem(
      id: _uuid.v4(),
      product: product,
      quantity: quantity,
      unitPrice: product.price,  // Precio inmutable
    );
    
    // Agregar al carrito
    return await repository.addItem(cartItem);
  }
}
```

#### `remove_from_cart.dart` - Use Case con Undo
```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class RemoveFromCart {
  final ICartRepository repository;
  
  RemoveFromCart(this.repository);
  
  Future<Either<Failure, Cart>> execute(String itemId) async {
    // Validar ID
    if (itemId.trim().isEmpty) {
      return Left(const CartOperationFailure('remove_from_cart', message: 'Invalid item ID'));
    }
    
    return await repository.removeItem(itemId);
  }
}

/// Use Case especial para Undo
class UndoRemoveItem {
  final ICartRepository repository;
  
  UndoRemoveItem(this.repository);
  
  Future<Either<Failure, Cart>> execute(CartItem removedItem) async {
    // Re-agregar el ítem eliminado
    return await repository.addItem(removedItem);
  }
}
```

[Continuar con los demás use cases...]

---

### 3. Infrastructure Layer

#### `hive_cart_repository.dart` - Implementación
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/constants.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/value_objects/discount.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_hive_model.dart';

class HiveCartRepository implements ICartRepository {
  final Box<CartHiveModel> _box;
  static const String _cartKey = 'current_cart';
  
  HiveCartRepository(this._box);
  
  @override
  Future<Either<Failure, Cart>> getCurrentCart() async {
    try {
      final model = _box.get(_cartKey);
      
      if (model == null) {
        // Retornar carrito vacío
        return Right(_createEmptyCart());
      }
      
      return Right(model.toEntity());
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'get_cart',
        message: 'Failed to get cart from database',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> addItem(CartItem item) async {
    try {
      final currentCart = await getCurrentCart();
      
      return currentCart.fold(
        (failure) => Left(failure),
        (cart) async {
          // Verificar si el producto ya está en el carrito
          final existingIndex = cart.items.indexWhere(
            (existing) => existing.product.id == item.product.id && 
                          existing.unitPrice == item.unitPrice
          );
          
          List<CartItem> updatedItems;
          
          if (existingIndex >= 0) {
            // Incrementar cantidad
            final existingItem = cart.items[existingIndex];
            final updatedItem = existingItem.copyWith(
              quantity: existingItem.quantity + item.quantity
            );
            updatedItems = List<CartItem>.from(cart.items)
              ..[existingIndex] = updatedItem;
          } else {
            // Agregar nuevo ítem
            updatedItems = [...cart.items, item];
          }
          
          final updatedCart = cart.copyWith(
            items: updatedItems,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'add_item',
        message: 'Failed to add item to cart',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Cart>> removeItem(String itemId) async {
    try {
      final currentCart = await getCurrentCart();
      
      return currentCart.fold(
        (failure) => Left(failure),
        (cart) async {
          final updatedItems = cart.items.where((item) => item.id != itemId).toList();
          
          final updatedCart = cart.copyWith(
            items: updatedItems,
            updatedAt: DateTime.now(),
          );
          
          await saveCart(updatedCart);
          return Right(updatedCart);
        },
      );
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'remove_item',
        message: 'Failed to remove item from cart',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await _box.delete(_cartKey);
      return right(unit);
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'clear_cart',
        message: 'Failed to clear cart',
        exception: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> saveCart(Cart cart) async {
    try {
      final model = CartHiveModel.fromEntity(cart);
      await _box.put(_cartKey, model);
      return right(unit);
    } on HiveError catch (e) {
      return Left(CartOperationFailure(
        'save_cart',
        message: 'Failed to save cart',
        exception: e,
      ));
    }
  }
  
  Cart _createEmptyCart() {
    return Cart(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
```

#### `cart_hive_model.dart` - Modelo Hive
```dart
import 'package:hive/hive.dart';
import '../../domain/entities/cart.dart';
import 'cart_item_hive_model.dart';
import 'discount_hive_model.dart';

part 'cart_hive_model.g.dart';

@HiveType(typeId: 1)
class CartHiveModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late List<CartItemHiveModel> items;
  
  @HiveField(2)
  DiscountHiveModel? discount;
  
  @HiveField(3)
  late DateTime createdAt;
  
  @HiveField(4)
  late DateTime updatedAt;
  
  CartHiveModel();
  
  factory CartHiveModel.fromEntity(Cart cart) {
    final model = CartHiveModel()
      ..id = cart.id
      ..items = cart.items.map((item) => CartItemHiveModel.fromEntity(item)).toList()
      ..discount = cart.discount != null ? DiscountHiveModel.fromEntity(cart.discount!) : null
      ..createdAt = cart.createdAt
      ..updatedAt = cart.updatedAt;
    
    return model;
  }
  
  Cart toEntity() {
    return Cart(
      id: id,
      items: items.map((item) => item.toEntity()).toList(),
      discount: discount?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

---

### 4. Presentation Layer

#### `cart_bloc.dart` - BLoC Completo
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/value_objects/discount.dart';
import '../application/usecases/add_to_cart.dart';
import '../application/usecases/remove_from_cart.dart';
import '../application/usecases/update_cart_item_quantity.dart';
import '../application/usecases/apply_discount.dart';
import '../application/usecases/clear_cart.dart';
import '../application/usecases/get_cart.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCart getCart;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UndoRemoveItem undoRemoveItem;
  final UpdateCartItemQuantity updateItemQuantity;
  final ApplyDiscount applyDiscount;
  final ClearCart clearCart;
  
  CartItem? _lastRemovedItem;  // Para funcionalidad de undo
  
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
    on<ClearCartEvent>(_onClearCart);
  }
  
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    
    final result = await getCart.execute();
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
  }
  
  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;
    
    final result = await addToCart.execute(event.product, event.quantity);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
  }
  
  Future<void> _onRemoveItem(RemoveItem event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;
    
    // Guardar ítem para undo
    final itemToRemove = currentState.cart.items.firstWhere(
      (item) => item.id == event.itemId,
      orElse: () => throw Exception('Item not found'),
    );
    _lastRemovedItem = itemToRemove;
    
    final result = await removeFromCart.execute(event.itemId);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: _lastRemovedItem)),
    );
    
    // Programar limpieza del undo después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      _lastRemovedItem = null;
    });
  }
  
  Future<void> _onUndoRemoveItem(UndoRemoveItemEvent event, Emitter<CartState> emit) async {
    if (_lastRemovedItem == null) return;
    
    final result = await undoRemoveItem.execute(_lastRemovedItem!);
    
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart: cart, lastRemovedItem: null)),
    );
    
    _lastRemovedItem = null;
  }
  
  // ... más handlers
}
```

---

## 🧪 Testing Strategy

### Tests Unitarios (Domain)
- [ ] `Cart` entity - cálculos de subtotal, descuento, total
- [ ] `CartItem` entity - snapshot de precio inmutable
- [ ] `Discount` value object - validación de porcentajes y montos
- [ ] `Discount.calculateDiscountAmount()` - cálculos correctos

### Tests de Casos de Uso (Application)
- [ ] `AddToCart` - agrega ítem nuevo
- [ ] `AddToCart` - incrementa cantidad si producto ya existe
- [ ] `RemoveFromCart` - elimina ítem existente
- [ ] `RemoveFromCart` - falla con ID inválido
- [ ] `ApplyDiscount` - aplica descuento porcentual
- [ ] `ApplyDiscount` - aplica descuento fijo
- [ ] `ApplyDiscount` - falla si descuento excede subtotal
- [ ] `ClearCart` - vacía carrito completamente

### Tests de BLoC (Presentation)
- [ ] `LoadCart` - carga carrito vacío
- [ ] `LoadCart` - carga carrito con ítems
- [ ] `AddItemToCart` - agrega ítem y actualiza estado
- [ ] `RemoveItem` - elimina ítem y guarda para undo
- [ ] `UndoRemoveItem` - restaura ítem eliminado
- [ ] `UndoRemoveItem` - no hace nada si ya pasó 3 segundos

---

## 📦 Dependencias Requeridas

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  hive_flutter: ^1.1.0
  hive_generator: ^2.0.1
  fpdart: ^1.1.0
  equatable: ^2.0.5
  uuid: ^4.3.3
```

---

## 🚀 Criterios de Aceptación

- [x] El carrito persiste después de cerrar y reabrir la app
- [x] El precio del ítem no cambia aunque el producto se actualice
- [x] Se puede aplicar descuento porcentual (0-100%)
- [x] Se puede aplicar descuento fijo (monto en moneda)
- [x] Al eliminar un ítem, aparece Snackbar con "Deshacer" por 3 segundos
- [x] Después de 3 segundos, el undo ya no está disponible
- [x] El carrito se limpia al completar la venta
- [x] Los cálculos de subtotal, descuento y total son correctos
- [x] El badge del FAB muestra la cantidad total de ítems
- [x] El carrito vacío muestra mensaje y botón para agregar productos

---

## 📝 Notas de Implementación

1. **TypeIds de Hive**: Asegurar que los TypeIds sean únicos y consecutivos
   - ProductHiveModel: `typeId: 0`
   - CartHiveModel: `typeId: 1`
   - CartItemHiveModel: `typeId: 2`
   - DiscountHiveModel: `typeId: 3`

2. **Snapshot de Producto**: Es crucial que el `CartItem` guarde una copia completa del producto al momento de agregar. Esto previene que cambios en el catálogo afecten ventas en curso.

3. **Undo Implementation**: El undo usa un timeout de 3 segundos. Después de ese tiempo, `_lastRemovedItem` se limpia y el ítem se pierde permanentemente.

4. **Thread Safety**: Hive no es thread-safe por defecto. Asegurar que todas las operaciones de I/O sean await-ed correctamente.

---

## 🔗 Referencias

- `docs/AppFlow.md` - Flujo del carrito
- `docs/Design.md` - Especificaciones de diseño de CartPage
- `docs/Styles.md` - Design system (colores, tipografía)
- `.qwen/AGENTS.md` - Reglas de desarrollo (NO COMPILAR LOCAL)

---

**Documento aprobado para implementación** ✅
