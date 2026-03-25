/// Payment Method Value Object
/// 
/// Represents the method of payment used for a sale
/// 
/// Payment Methods:
/// - cash: Payment in cash (efectivo)
/// - card: Payment with card (tarjeta)
/// - mixed: Combined payment (cash + card)
enum PaymentMethod {
  /// Cash payment (efectivo)
  cash,

  /// Card payment (tarjeta)
  card,

  /// Mixed payment (mixto) - cash + card
  mixed;

  /// Returns the display name for this payment method
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.mixed:
        return 'Mixto';
    }
  }

  /// Returns the icon for this payment method
  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return 'payments'; // or 'attach_money'
      case PaymentMethod.card:
        return 'credit_card';
      case PaymentMethod.mixed:
        return 'account_balance_wallet';
    }
  }

  /// Returns true if this payment method involves cash
  bool get involvesCash => this == cash || this == mixed;

  /// Returns true if this payment method involves card
  bool get involvesCard => this == card || this == mixed;

  /// Parses a string to PaymentMethod
  /// Returns null if the string doesn't match any known method
  static PaymentMethod? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
      case 'efectivo':
        return PaymentMethod.cash;
      case 'card':
      case 'tarjeta':
        return PaymentMethod.card;
      case 'mixed':
      case 'mixto':
        return PaymentMethod.mixed;
      default:
        return null;
    }
  }

  /// Converts to string for storage/serialization
  @override
  String toString() {
    return name;
  }
}
