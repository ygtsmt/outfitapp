part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class AddCreditForRewardedAd extends PaymentEvent {
  final int addingCreditCount;
  final BuildContext context;

  const AddCreditForRewardedAd({
    required this.addingCreditCount,
    required this.context,
  });

  @override
  List<Object> get props => [
        addingCreditCount,
        context,
      ];
}

class ClaimCreditForRewardedAd extends PaymentEvent {
  final BuildContext context;

  const ClaimCreditForRewardedAd({
    required this.context,
  });

  @override
  List<Object> get props => [context];
}

class PurchaseOneTimeProduct extends PaymentEvent {
  final String productId;
  final BuildContext context;

  const PurchaseOneTimeProduct({
    required this.productId,
    required this.context,
  });

  @override
  List<Object> get props => [productId, context];
}

class LoadOneTimeProducts extends PaymentEvent {
  const LoadOneTimeProducts();
}
