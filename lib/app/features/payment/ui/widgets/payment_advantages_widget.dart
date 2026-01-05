import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/features/payment/ui/widgets/payment_avantage.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/generated/l10n.dart';

class PaymentAdvantagesWidget extends StatefulWidget {
  const PaymentAdvantagesWidget({super.key});

  @override
  State<PaymentAdvantagesWidget> createState() =>
      PaymentAdvantagesWidgetState();
}

class PaymentAdvantagesWidgetState extends State<PaymentAdvantagesWidget> {
  int _selectedPlanIndex = 1; // Default olarak Pro plan (index 1) seçili

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaymentAvantage(
          label: AppLocalizations.of(context).fasterGenerationSpeed,
        ),
        PaymentAvantage(
          label: AppLocalizations.of(context).unlockAllFeatures,
        ),
        PaymentAvantage(
          label: AppLocalizations.of(context).noWatermarksAds,
        ),
      ],
    );
  }

  // Seçilen plana göre kredi sayısını Firebase'den çek
  int _getCreditsForSelectedPlan(AppState appState) {
    final plans = appState.plans;
    if (plans == null || plans.isEmpty) return 100; // Default değer

    // Product IDs - RevenueCat dashboard'da tanımlanan paketler
    final List<String> productIds = [
      'ginly_plus_weekly',
      'ginly_pro_weekly',
      'ginly_ultra_weekly',
    ];

    final productId = productIds[_selectedPlanIndex];
    final plan = plans.firstWhere(
      (p) => p.planId == productId,
      orElse: () => plans.first,
    );

    return plan.purchasedCredit;
  }

  // Seçilen plan index'ini güncelle (PaymentPlansWidget'tan çağrılacak)
  void updateSelectedPlan(int index) {
    setState(() {
      _selectedPlanIndex = index;
    });
  }
}
