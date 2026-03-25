import 'package:equatable/equatable.dart';

import 'package:zivlo/features/checkout/domain/value_objects/payment_method.dart';
/// Checkout Event - Base class
/// All checkout events extend this class
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Checkout page initialized
/// Dispatched when the checkout page is first loaded
/// Triggers loading of checkout summary
class CheckoutInitialized extends CheckoutEvent {
  const CheckoutInitialized();

  @override
  List<Object?> get props => [];
}

/// Event: Payment method selected
/// Dispatched when user selects a payment method (cash/card/mixed)
class PaymentMethodSelected extends CheckoutEvent {
  final PaymentMethod method;

  const PaymentMethodSelected(this.method);

  @override
  List<Object?> get props => [method];
}

/// Event: Cash amount entered
/// Dispatched when user enters cash amount
/// Triggers change calculation
class CashAmountEntered extends CheckoutEvent {
  final double amount;

  const CashAmountEntered(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Event: Card amount entered
/// Dispatched when user enters card amount (for mixed payments)
class CardAmountEntered extends CheckoutEvent {
  final double amount;

  const CardAmountEntered(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Event: Process payment requested
/// Dispatched when user confirms payment
class ProcessPaymentRequested extends CheckoutEvent {
  const ProcessPaymentRequested();

  @override
  List<Object?> get props => [];
}

/// Event: Payment processed successfully
/// Dispatched by BLoC after successful payment processing
/// Contains the sale ID for navigation
class PaymentProcessed extends CheckoutEvent {
  final String saleId;

  const PaymentProcessed(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Event: Payment error occurred
/// Dispatched when an error happens during payment processing
class PaymentError extends CheckoutEvent {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event: Clear error
/// Dispatched to clear the current error state
class ClearError extends CheckoutEvent {
  const ClearError();

  @override
  List<Object?> get props => [];
}

/// Event: Navigate back
/// Dispatched when user wants to go back from checkout
class NavigateBack extends CheckoutEvent {
  const NavigateBack();

  @override
  List<Object?> get props => [];
}

/// Event: Print receipt requested
/// Dispatched when user wants to print the receipt
class PrintReceiptRequested extends CheckoutEvent {
  final String saleId;

  const PrintReceiptRequested(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Event: View receipt requested
/// Dispatched when user wants to view the receipt details
class ViewReceiptRequested extends CheckoutEvent {
  final String saleId;

  const ViewReceiptRequested(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Event: Start new sale
/// Dispatched when user wants to start a new sale after completing one
class StartNewSale extends CheckoutEvent {
  const StartNewSale();

  @override
  List<Object?> get props => [];
}
