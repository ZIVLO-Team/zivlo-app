import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

/// Use Case: Calculate Change
/// 
/// Calculates the change to return to the customer for cash payments
/// 
/// This is a pure calculation use case - no side effects
/// Used by the UI to display change in real-time as the user enters cash amount
class CalculateChange {
  const CalculateChange();

  /// Calculates change given total and amount received
  /// 
  /// [total] - The total amount to pay
  /// [amountReceived] - The amount given by the customer
  /// 
  /// Returns the change amount (can be negative if insufficient payment)
  Either<Failure, double> execute({
    required double total,
    required double amountReceived,
  }) {
    // Validate inputs
    if (total < 0) {
      return left(const InvalidAmountFailure('Total cannot be negative'));
    }

    if (amountReceived < 0) {
      return left(const InvalidAmountFailure('Amount received cannot be negative'));
    }

    // Calculate change
    final change = amountReceived - total;

    return right(change);
  }

  /// Calculates change for mixed payment
  /// 
  /// [total] - The total amount to pay
  /// [cashAmount] - The cash portion paid
  /// [cardAmount] - The card portion paid
  /// 
  /// Returns the change from the cash portion
  Either<Failure, double> executeMixed({
    required double total,
    required double cashAmount,
    required double cardAmount,
  }) {
    // Validate inputs
    if (total < 0) {
      return left(const InvalidAmountFailure('Total cannot be negative'));
    }

    if (cashAmount < 0) {
      return left(const InvalidAmountFailure('Cash amount cannot be negative'));
    }

    if (cardAmount < 0) {
      return left(const InvalidAmountFailure('Card amount cannot be negative'));
    }

    // Calculate remaining amount after card payment
    final remainingAfterCard = total - cardAmount;

    // Calculate change from cash portion
    final change = cashAmount - remainingAfterCard;

    return right(change);
  }
}

/// Failure for invalid amount errors
class InvalidAmountFailure extends Failure {
  const InvalidAmountFailure(super.message);
}
