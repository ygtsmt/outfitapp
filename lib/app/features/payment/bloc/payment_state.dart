part of 'payment_bloc.dart';

class PaymentState extends Equatable {
  final EventStatus? status;
  final EventStatus? addCreditForRewardedStatus;
  final EventStatus? oneTimePurchaseStatus;
  final List<OneTimeProduct> oneTimeProducts;

  final String? errorMessage;

  const PaymentState({
    this.status,
    this.addCreditForRewardedStatus,
    this.oneTimePurchaseStatus,
    this.oneTimeProducts = const [],
    this.errorMessage,
  });

  PaymentState copyWith({
    EventStatus? status,
    EventStatus? addCreditForRewardedStatus,
    EventStatus? oneTimePurchaseStatus,
    List<OneTimeProduct>? oneTimeProducts,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      addCreditForRewardedStatus:
          addCreditForRewardedStatus ?? this.addCreditForRewardedStatus,
      oneTimePurchaseStatus:
          oneTimePurchaseStatus ?? this.oneTimePurchaseStatus,
      oneTimeProducts: oneTimeProducts ?? this.oneTimeProducts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addCreditForRewardedStatus,
        oneTimePurchaseStatus,
        oneTimeProducts,
        errorMessage,
      ];
}
