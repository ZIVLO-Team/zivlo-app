import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/value_objects/payment_method.dart';

/// Use Case: Validate Payment
/// 
/// Validates payment data before processing
/// 
/// Checks:
/// - Payment method is valid
/// - Amount received >= total (for cash)
/// - Card amount is valid (for mixed payments)
/// - Total amount is positive
class ValidatePayment {
  const ValidatePayment();

  /// Validates payment data
  /// 
  /// [total] - Total amount to pay
  /// [method] - Payment method
  /// [amountReceived] - Cash amount received (for cash/mixed)
  /// [cardAmount] - Card amount (for mixed)
  /// 
  /// Returns [Unit.value] on success, [Failure] on validation error
  Either<Failure, Unit> execute({
    required double total,
    required PaymentMethod method,
    double? amountReceived,
    double? cardAmount,
  }) {
    // Validate total
    if (total <= 0) {
      return left(const PaymentValidationFailure('Total must be greater than zero'));
    }

    // Validate based on payment method
    switch (method) {
      case PaymentMethod.cash:
        return _validateCash(total, amountReceived);
      case PaymentMethod.card:
        return _validateCard(total);
      case PaymentMethod.mixed:
        return _validateMixed(total, amountReceived, cardAmount);
    }
  }

  /// Validates cash payment
  Either<Failure, Unit> _validateCash(double total, double? amountReceived) {
    if (amountReceived == null) {
      return left(const PaymentValidationFailure('Cash amount is required'));
    }

    if (amountReceived < 0) {
      return left(const PaymentValidationFailure('Cash amount cannot be negative'));
    }

    if (amountReceived < total) {
      return left(const PaymentValidationFailure('Insufficient cash amount'));
    }

    return right(unit);
  }

  /// Validates card payment
  Either<Failure, Unit> _validateCard(double total) {
    // Card payments just need a valid total
    // The actual card processing happens externally
    if (total <= 0) {
      return left(const PaymentValidationFailure('Invalid total for card payment'));
    }

    return right(unit);
  }

  /// Validates mixed payment
  Either<Failure, Unit> _validateMixed(
    double total,
    double? amountReceived,
    double? cardAmount,
  ) {
    if (amountReceived == null) {
      return left(const PaymentValidationFailure('Cash amount is required for mixed payment'));
    }

    if (cardAmount == null) {
      return left(const PaymentValidationFailure('Card amount is required for mixed payment'));
    }

    if (amountReceived < 0) {
      return left(const PaymentValidationFailure('Cash amount cannot be negative'));
    }

    if (cardAmount < 0) {
      return left(const PaymentValidationFailure('Card amount cannot be negative'));
    }

    if (amountReceived + cardAmount < total) {
      return left(const PaymentValidationFailure('Total payment (cash + card) is insufficient'));
    }

    // For mixed payments, cash should be less than total
    // (otherwise it would be a pure cash payment)
    if (amountReceived >= total) {
      return left(const PaymentValidationFailure(
        'Cash amount covers the total - use cash payment instead'));
    }

    return right(unit);
  }
}

/// Failure for payment validation errors
class PaymentValidationFailure extends Failure {
  const PaymentValidationFailure(super.message);
}
