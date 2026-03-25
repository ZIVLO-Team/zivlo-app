import 'package:equatable/equatable.dart';

import '../../domain/value_objects/payment_method.dart';
import '../../application/usecases/get_checkout_summary.dart';

/// Checkout State - Base class
/// All checkout states extend this class
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state
/// Before checkout page is initialized
class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();

  @override
  List<Object?> get props => [];
}

/// Loading state
/// Loading checkout summary from cart
class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();

  @override
  List<Object?> get props => [];
}

/// Ready state
/// Checkout summary loaded, ready for payment selection
class CheckoutReady extends CheckoutState {
  final CheckoutSummary summary;
  final PaymentMethod selectedPaymentMethod;

  const CheckoutReady({
    required this.summary,
    this.selectedPaymentMethod = PaymentMethod.cash,
  });

  @override
  List<Object?> get props => [summary, selectedPaymentMethod];

  CheckoutReady copyWith({
    CheckoutSummary? summary,
    PaymentMethod? selectedPaymentMethod,
  }) {
    return CheckoutReady(
      summary: summary ?? this.summary,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

/// Cash payment state
/// User selected cash payment, entering amount
class CashPaymentState extends CheckoutState {
  final CheckoutSummary summary;
  final double? cashAmount;
  final double? change;
  final bool isValid;

  const CashPaymentState({
    required this.summary,
    this.cashAmount,
    this.change,
    this.isValid = false,
  });

  @override
  List<Object?> get props => [summary, cashAmount, change, isValid];

  CashPaymentState copyWith({
    CheckoutSummary? summary,
    double? cashAmount,
    double? change,
    bool? isValid,
  }) {
    return CashPaymentState(
      summary: summary ?? this.summary,
      cashAmount: cashAmount ?? this.cashAmount,
      change: change ?? this.change,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// Card payment state
/// User selected card payment, ready to confirm
class CardPaymentState extends CheckoutState {
  final CheckoutSummary summary;

  const CardPaymentState({
    required this.summary,
  });

  @override
  List<Object?> get props => [summary];
}

/// Mixed payment state
/// User selected mixed payment, entering cash and card amounts
class MixedPaymentState extends CheckoutState {
  final CheckoutSummary summary;
  final double? cashAmount;
  final double? cardAmount;
  final double? change;
  final double remainingAmount;
  final bool isValid;

  const MixedPaymentState({
    required this.summary,
    this.cashAmount,
    this.cardAmount,
    this.change,
    this.remainingAmount = 0,
    this.isValid = false,
  });

  @override
  List<Object?> get props => [
        summary,
        cashAmount,
        cardAmount,
        change,
        remainingAmount,
        isValid,
      ];

  MixedPaymentState copyWith({
    CheckoutSummary? summary,
    double? cashAmount,
    double? cardAmount,
    double? change,
    double? remainingAmount,
    bool? isValid,
  }) {
    return MixedPaymentState(
      summary: summary ?? this.summary,
      cashAmount: cashAmount ?? this.cashAmount,
      cardAmount: cardAmount ?? this.cardAmount,
      change: change ?? this.change,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// Processing state
/// Payment is being processed
class CheckoutProcessing extends CheckoutState {
  final PaymentMethod paymentMethod;

  const CheckoutProcessing({
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [paymentMethod];
}

/// Success state
/// Payment processed successfully
class CheckoutSuccess extends CheckoutState {
  final String saleId;
  final double totalPaid;
  final PaymentMethod paymentMethod;
  final double? change;

  const CheckoutSuccess({
    required this.saleId,
    required this.totalPaid,
    required this.paymentMethod,
    this.change,
  });

  @override
  List<Object?> get props => [saleId, totalPaid, paymentMethod, change];
}

/// Error state
/// An error occurred during checkout
class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
