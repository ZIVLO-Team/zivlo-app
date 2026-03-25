import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/value_objects/payment.dart';
import '../../domain/value_objects/payment_method.dart';
import '../../application/usecases/process_payment.dart';
import '../../application/usecases/calculate_change.dart';
import '../../application/usecases/validate_payment.dart';
import '../../application/usecases/get_checkout_summary.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

/// Checkout BLoC - Business Logic Component
/// Handles all checkout-related business logic
///
/// Manages the checkout state machine:
/// - CheckoutInitial -> CheckoutLoading -> CheckoutReady
/// - CheckoutReady -> CashPaymentState (on cash selected)
/// - CheckoutReady -> CardPaymentState (on card selected)
/// - CheckoutReady -> MixedPaymentState (on mixed selected)
/// - Any payment state -> CheckoutProcessing -> CheckoutSuccess/CheckoutError
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  // Use cases
  final GetCheckoutSummary getCheckoutSummary;
  final ProcessPayment processPayment;
  final CalculateChange calculateChange;
  final ValidatePayment validatePayment;

  // Current payment data
  double _cashAmount = 0;
  double _cardAmount = 0;

  CheckoutBloc({
    required this.getCheckoutSummary,
    required this.processPayment,
    required this.calculateChange,
    required this.validatePayment,
  }) : super(const CheckoutInitial()) {
    on<CheckoutInitialized>(_onCheckoutInitialized);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<CashAmountEntered>(_onCashAmountEntered);
    on<CardAmountEntered>(_onCardAmountEntered);
    on<ProcessPaymentRequested>(_onProcessPaymentRequested);
    on<PaymentProcessed>(_onPaymentProcessed);
    on<PaymentError>(_onPaymentError);
    on<ClearError>(_onClearError);
    on<NavigateBack>(_onNavigateBack);
    on<PrintReceiptRequested>(_onPrintReceiptRequested);
    on<ViewReceiptRequested>(_onViewReceiptRequested);
    on<StartNewSale>(_onStartNewSale);
  }

  /// Handler: Checkout initialized
  /// Loads checkout summary from cart
  Future<void> _onCheckoutInitialized(
    CheckoutInitialized event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());

    final result = await getCheckoutSummary.execute();
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (summary) {
        emit(CheckoutReady(summary: summary));
        // Reset payment amounts
        _cashAmount = 0;
        _cardAmount = 0;
      },
    );
  }

  /// Handler: Payment method selected
  /// Transitions to appropriate payment state
  Future<void> _onPaymentMethodSelected(
    PaymentMethodSelected event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutReady) {
      // Get current summary or return
      final summary = _getCurrentSummary();
      if (summary == null) return;
      emit(CheckoutReady(summary: summary, selectedPaymentMethod: event.method));
      return;
    }

    final currentState = state as CheckoutReady;

    switch (event.method) {
      case PaymentMethod.cash:
        emit(CashPaymentState(
          summary: currentState.summary,
          cashAmount: _cashAmount > 0 ? _cashAmount : null,
          isValid: _cashAmount >= currentState.summary.total,
        ));
        break;

      case PaymentMethod.card:
        emit(CardPaymentState(summary: currentState.summary));
        break;

      case PaymentMethod.mixed:
        final remainingAmount = currentState.summary.total - _cardAmount;
        emit(MixedPaymentState(
          summary: currentState.summary,
          cashAmount: _cashAmount > 0 ? _cashAmount : null,
          cardAmount: _cardAmount > 0 ? _cardAmount : null,
          remainingAmount: remainingAmount > 0 ? remainingAmount : 0,
          isValid: (_cashAmount + _cardAmount) >= currentState.summary.total,
        ));
        break;
    }
  }

  /// Handler: Cash amount entered
  /// Calculates change and validates payment
  Future<void> _onCashAmountEntered(
    CashAmountEntered event,
    Emitter<CheckoutState> emit,
  ) async {
    _cashAmount = event.amount;

    if (state is CashPaymentState) {
      final currentState = state as CashPaymentState;
      final total = currentState.summary.total;

      // Calculate change
      final changeResult = calculateChange.execute(
        total: total,
        amountReceived: event.amount,
      );

      final change = changeResult.getOrElse(() => 0.0);
      final isValid = event.amount >= total;

      emit(currentState.copyWith(
        cashAmount: event.amount,
        change: change > 0 ? change : null,
        isValid: isValid,
      ));
    } else if (state is MixedPaymentState) {
      final currentState = state as MixedPaymentState;
      final total = currentState.summary.total;
      final remainingAfterCard = total - _cardAmount;

      // Calculate change from cash portion
      final changeResult = calculateChange.execute(
        total: remainingAfterCard,
        amountReceived: event.amount,
      );

      final change = changeResult.getOrElse(() => 0.0);
      final remainingAmount = remainingAfterCard - event.amount;
      final isValid = (event.amount + _cardAmount) >= total;

      emit(currentState.copyWith(
        cashAmount: event.amount,
        change: change > 0 ? change : null,
        remainingAmount: remainingAmount > 0 ? remainingAmount : 0,
        isValid: isValid,
      ));
    }
  }

  /// Handler: Card amount entered (for mixed payments)
  Future<void> _onCardAmountEntered(
    CardAmountEntered event,
    Emitter<CheckoutState> emit,
  ) async {
    _cardAmount = event.amount;

    if (state is MixedPaymentState) {
      final currentState = state as MixedPaymentState;
      final total = currentState.summary.total;
      final remainingAfterCard = total - event.amount;

      // Calculate change from cash portion
      final changeResult = calculateChange.execute(
        total: remainingAfterCard,
        amountReceived: _cashAmount,
      );

      final change = changeResult.getOrElse(() => 0.0);
      final remainingAmount = remainingAfterCard - _cashAmount;
      final isValid = (_cashAmount + event.amount) >= total;

      emit(currentState.copyWith(
        cardAmount: event.amount,
        remainingAmount: remainingAmount > 0 ? remainingAmount : 0,
        change: change > 0 ? change : null,
        isValid: isValid,
      ));
    }
  }

  /// Handler: Process payment requested
  /// Validates and processes the payment
  Future<void> _onProcessPaymentRequested(
    ProcessPaymentRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    CheckoutSummary? summary;
    PaymentMethod? method;

    if (state is CashPaymentState) {
      final currentState = state as CashPaymentState;
      summary = currentState.summary;
      method = PaymentMethod.cash;

      if (!currentState.isValid) {
        emit(const CheckoutError('Insufficient cash amount'));
        return;
      }

      emit(const CheckoutProcessing(paymentMethod: PaymentMethod.cash));
    } else if (state is CardPaymentState) {
      final currentState = state as CardPaymentState;
      summary = currentState.summary;
      method = PaymentMethod.card;

      emit(const CheckoutProcessing(paymentMethod: PaymentMethod.card));
    } else if (state is MixedPaymentState) {
      final currentState = state as MixedPaymentState;
      summary = currentState.summary;
      method = PaymentMethod.mixed;

      if (!currentState.isValid) {
        emit(const CheckoutError('Total payment is insufficient'));
        return;
      }

      emit(const CheckoutProcessing(paymentMethod: PaymentMethod.mixed));
    } else {
      emit(const CheckoutError('Invalid checkout state'));
      return;
    }

    if (summary == null || method == null) {
      emit(const CheckoutError('Invalid checkout data'));
      return;
    }

    // Create payment based on method
    Payment payment;
    switch (method) {
      case PaymentMethod.cash:
        payment = Payment.cash(
          totalAmount: summary.total,
          amountReceived: _cashAmount,
        );
        break;

      case PaymentMethod.card:
        payment = Payment.card(totalAmount: summary.total);
        break;

      case PaymentMethod.mixed:
        payment = Payment.mixed(
          totalAmount: summary.total,
          cashAmount: _cashAmount,
          cardAmount: _cardAmount,
        );
        break;
    }

    // Validate payment
    final validationResult = validatePayment.execute(
      total: summary.total,
      method: method,
      amountReceived: method == PaymentMethod.card ? null : _cashAmount,
      cardAmount: method == PaymentMethod.mixed ? _cardAmount : null,
    );

    if (validationResult.isLeft()) {
      final failure = validationResult.getLeft()!;
      emit(CheckoutError(failure.message));
      return;
    }

    // Process payment
    final result = await processPayment.execute(payment);
    result.fold(
      (failure) {
        emit(CheckoutError(failure.message));
      },
      (sale) {
        add(PaymentProcessed(sale.id));
      },
    );
  }

  /// Handler: Payment processed
  /// Transitions to success state
  Future<void> _onPaymentProcessed(
    PaymentProcessed event,
    Emitter<CheckoutState> emit,
  ) async {
    CheckoutSummary? summary;
    PaymentMethod? method;
    double? change;

    if (state is CashPaymentState) {
      final currentState = state as CashPaymentState;
      summary = currentState.summary;
      method = PaymentMethod.cash;
      change = currentState.change;
    } else if (state is CardPaymentState) {
      final currentState = state as CardPaymentState;
      summary = currentState.summary;
      method = PaymentMethod.card;
    } else if (state is MixedPaymentState) {
      final currentState = state as MixedPaymentState;
      summary = currentState.summary;
      method = PaymentMethod.mixed;
      change = currentState.change;
    }

    if (summary == null) {
      emit(const CheckoutError('Invalid checkout data'));
      return;
    }

    emit(CheckoutSuccess(
      saleId: event.saleId,
      totalPaid: summary.total,
      paymentMethod: method ?? PaymentMethod.cash,
      change: change,
    ));
  }

  /// Handler: Payment error
  /// Transitions to error state
  Future<void> _onPaymentError(
    PaymentError event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutError(event.message));
  }

  /// Handler: Clear error
  /// Returns to ready state
  Future<void> _onClearError(
    ClearError event,
    Emitter<CheckoutState> emit,
  ) async {
    final summary = _getCurrentSummary();
    if (summary != null) {
      emit(CheckoutReady(summary: summary));
    } else {
      emit(const CheckoutInitial());
    }
  }

  /// Handler: Navigate back
  /// Just logs the event - actual navigation handled by UI
  Future<void> _onNavigateBack(
    NavigateBack event,
    Emitter<CheckoutState> emit,
  ) async {
    // Navigation is handled by the UI layer
  }

  /// Handler: Print receipt requested
  /// Logs the event - actual printing handled by printer feature
  Future<void> _onPrintReceiptRequested(
    PrintReceiptRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    // Printing is handled by the Printer feature
  }

  /// Handler: View receipt requested
  /// Logs the event - actual navigation handled by UI
  Future<void> _onViewReceiptRequested(
    ViewReceiptRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    // Navigation is handled by the UI layer
  }

  /// Handler: Start new sale
  /// Resets state and reinitializes checkout
  Future<void> _onStartNewSale(
    StartNewSale event,
    Emitter<CheckoutState> emit,
  ) async {
    _cashAmount = 0;
    _cardAmount = 0;
    add(const CheckoutInitialized());
  }

  /// Helper: Get current summary from state
  CheckoutSummary? _getCurrentSummary() {
    if (state is CheckoutReady) {
      return (state as CheckoutReady).summary;
    } else if (state is CashPaymentState) {
      return (state as CashPaymentState).summary;
    } else if (state is CardPaymentState) {
      return (state as CardPaymentState).summary;
    } else if (state is MixedPaymentState) {
      return (state as MixedPaymentState).summary;
    }
    return null;
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
