import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ginfit/app/features/payment/data/payment_usecase.dart';
import 'package:ginfit/app/features/payment/data/models/one_time_product_model.dart';
import 'package:ginfit/app/core/services/revenue_cat_service.dart';
import 'package:ginfit/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'payment_event.dart';
part 'payment_state.dart';

@singleton
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentUsecase generateUseCase;

  PaymentBloc({
    required this.generateUseCase,
  }) : super(const PaymentState()) {
    on<AddCreditForRewardedAd>((event, emit) async {
      try {
        emit(
            state.copyWith(addCreditForRewardedStatus: EventStatus.processing));

        final result = await generateUseCase.addCreditForRewardedAd(
          addingCredit: event.addingCreditCount,
        );

        if (result == EventStatus.success) {
          emit(state.copyWith(
            addCreditForRewardedStatus: EventStatus.success,
          ));
        }
      } catch (e) {
        emit(state.copyWith(addCreditForRewardedStatus: EventStatus.failure));
        Utils.showToastMessage(
            context: event.context,
            content: AppLocalizations.current.error_adding_credit,
            color: Colors.red);
      }

      emit(state.copyWith(addCreditForRewardedStatus: EventStatus.idle));
    });
    on<ClaimCreditForRewardedAd>((event, emit) async {
      try {
        emit(
            state.copyWith(addCreditForRewardedStatus: EventStatus.processing));

        final result = await generateUseCase.claimCreditForRewardedAd();

        if (result == EventStatus.success) {
          emit(state.copyWith(
            addCreditForRewardedStatus: EventStatus.success,
          ));
          Utils.showToastMessage(
            context: event.context,
            content: AppLocalizations.current.credits_added_successfully,
            color: const Color(0xFF2F2B52),
          );
        }
      } catch (e) {
        emit(state.copyWith(addCreditForRewardedStatus: EventStatus.failure));
        Utils.showToastMessage(
            context: event.context,
            content: AppLocalizations.current.error_adding_credit,
            color: Colors.red);
      }

      emit(state.copyWith(addCreditForRewardedStatus: EventStatus.idle));
    });

    on<PurchaseOneTimeProduct>((event, emit) async {
      try {
        emit(state.copyWith(oneTimePurchaseStatus: EventStatus.processing));

        // 🔥 Satın almadan ÖNCE RevenueCat'i Firebase User ID ile sync et
        await RevenueCatService.syncWithFirebase();

        final result =
            await RevenueCatService.purchaseOneTimeProduct(event.productId);

        if (result != null) {
          // 🔄 Premium template hakkını sıfırla (kredi paketi satın alındı)
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({'profile_info.user_used_premium_template': false});
              debugPrint('✅ Premium template usage reset after credit package purchase');
            } catch (e) {
              debugPrint('❌ Error resetting premium template usage: $e');
            }
          }

          // Başarılı purchase - webhook üzerinden kredi eklenecek
          emit(state.copyWith(oneTimePurchaseStatus: EventStatus.success));

          // Başarı mesajı göster
          Utils.showToastMessage(
            context: event.context,
            content: AppLocalizations.current.purchaseSuccessful,
            color: Colors.green,
          );
        } else {
          emit(state.copyWith(
            oneTimePurchaseStatus: EventStatus.failure,
            errorMessage: AppLocalizations.current.purchaseFailed,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          oneTimePurchaseStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }

      emit(state.copyWith(oneTimePurchaseStatus: EventStatus.idle));
    });

    on<LoadOneTimeProducts>((event, emit) async {
      try {
        final productIds = RevenueCatService.getOneTimeProductIds();
        final products = <OneTimeProduct>[];

        for (final productId in productIds) {
          final details =
              await RevenueCatService.getOneTimeProductDetails(productId);
          if (details.isNotEmpty) {
            products.add(OneTimeProduct.fromJson(details));
          }
        }

        emit(state.copyWith(oneTimeProducts: products));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      }
    });
  }
}
