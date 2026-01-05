import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/payment/bloc/payment_bloc.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/features/payment/ui/widgets/payment_plan_card.dart';
import 'package:comby/app/data/models/plan_model.dart';
import 'package:comby/app/core/services/revenue_cat_service.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:comby/core/utils.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

class CreditPackagesWidget extends StatefulWidget {
  final VoidCallback? onGoToSubscriptions;

  const CreditPackagesWidget({super.key, this.onGoToSubscriptions});

  @override
  State<CreditPackagesWidget> createState() => _CreditPackagesWidgetState();
}

class _CreditPackagesWidgetState extends State<CreditPackagesWidget>
    with TickerProviderStateMixin {
  String? _selectedPackageId;
  bool _isLoading = false;
  List<PlanModel>? _cachedSortedPackages;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Default olarak Ginly AI Boost paketini seç
    _selectedPackageId = 'ginly_boost_credit';
    // AppState'den plans'ı çekmek için GetPlansEvent'i tetikle

    // Animasyon controller'ı başlat
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 1.1, end: 1).animate(_animationController);

    // Animasyonu başlat
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state.oneTimePurchaseStatus == EventStatus.success) {
          setState(() {
            _isLoading = false;
          });
          // Başarılı purchase sonrası profil güncelle
          Utils.showToastMessage(
            context: context,
            content: AppLocalizations.of(context).creditsAddedSuccessfully,
            color: Colors.green,
          );
        } else if (state.oneTimePurchaseStatus == EventStatus.failure) {
          setState(() {
            _isLoading = false;
          });
          Utils.showToastMessage(
            context: context,
            content: state.errorMessage ??
                AppLocalizations.of(context).purchaseFailed,
            color: Colors.red,
          );
        }
      },
      builder: (context, paymentState) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(), // StreamBuilder yerine FutureBuilder - tek seferlik okuma!
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError) {
                return Center(
                    child:
                        Text(AppLocalizations.of(context).userInfoLoadError));
              }

              if (!userSnapshot.hasData ||
                  userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return BlocBuilder<AppBloc, AppState>(
                builder: (context, appState) {
                  // Kredi paketlerini filtrele
                  final allCreditPackages = appState.plans
                          ?.where((plan) => plan.planId.contains('_credit'))
                          .toList() ??
                      [];

                  // Cache kontrolü
                  if (_cachedSortedPackages == null) {
                    _sortPackagesByPrice(allCreditPackages)
                        .then((sortedPackages) {
                      if (mounted) {
                        setState(() {
                          _cachedSortedPackages = sortedPackages;
                        });
                      }
                    });
                    return const Center(child: CircularProgressIndicator());
                  }

                  final visiblePackages = _cachedSortedPackages!;

                  if (visiblePackages.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).packagesLoading,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...visiblePackages.map((plan) => _buildCreditPackageCard(
                            context,
                            plan,
                            paymentState.oneTimePurchaseStatus ==
                                EventStatus.processing,
                          )),
                      // Non-renewable yazısı ve Satın Alma Butonu
                      _selectedPackageId != null
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).nonRenewable,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  ScaleTransition(
                                    scale: _animation,
                                    child: CustomGradientButton(
                                      title: _isLoading
                                          ? AppLocalizations.of(context)
                                              .processing
                                          : AppLocalizations.of(context)
                                              .purchaseNow,
                                      onTap: _isLoading
                                          ? null
                                          : () => _purchaseProduct(
                                              _selectedPackageId!),
                                      isFilled: true,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            // First row: Terms of Use and Privacy Policy
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    context.router
                                        .push(DocumentsWebViewScreenRoute(
                                      pdfUrl: 'https://comby.ai/terms',
                                      title: 'Terms of Use',
                                    ));
                                  },
                                  child: Text(
                                    'Terms of Use',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 12.h,
                                  color: Colors.grey[400],
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.router
                                        .push(DocumentsWebViewScreenRoute(
                                      pdfUrl: 'https://comby.ai/privacy',
                                      title: 'Privacy Policy',
                                    ));
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Second row: Apple Standard EULA
                            if (Platform.isIOS || Platform.isMacOS)
                              TextButton(
                                onPressed: () {
                                  context.router
                                      .push(DocumentsWebViewScreenRoute(
                                    pdfUrl:
                                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                                    title: 'Apple Standard EULA',
                                  ));
                                },
                                child: Text(
                                  'Apple Standard EULA',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11.sp,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreditPackageCard(
    BuildContext context,
    PlanModel plan,
    bool isLoading,
  ) {
    // Plan ID'den product ID'yi çıkar
    final productId = plan.planId;

    // Mevcut dildeki benefits'i al
    final currentLocale = Localizations.localeOf(context).languageCode;
    final benefits = plan.getBenefitsForLanguage(currentLocale);

    return FutureBuilder<Map<String, dynamic>>(
      future: RevenueCatService.getOneTimeProductDetails(productId),
      builder: (context, snapshot) {
        String price = AppLocalizations.of(context).loading;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          price = snapshot.data!['price'] ??
              AppLocalizations.of(context).priceNotAvailable;
        }

        return PaymentPlanCard(
          title: _getPackageNameFromProductId(productId),
          price: price,
          duration: AppLocalizations.of(context).oneTime,
          isSelected: _selectedPackageId == productId, // Seçili paket kontrolü
          isProPlan: productId
              .contains('boost'), // Boost içeren paketler için Best Price
          credits: plan.purchasedCredit,
          benefits: benefits,
          isLoading: false, // Card'da loading gösterme
          onTap: () => _selectPackage(productId), // Seçim için
          showPurchaseButton: false, // Buton gösterme
        );
      },
    );
  }

  String _getPackageNameFromProductId(String productId) {
    switch (productId) {
      case 'ginly_extra_credit':
        return 'Comby AI Extra';
      case 'ginly_boost_credit':
        return 'Comby AI Boost';
      case 'ginly_mega_credit':
        return 'Comby AI Mega';
      default:
        return 'Credit Package';
    }
  }

  void _selectPackage(String productId) {
    setState(() {
      _selectedPackageId = productId;
      _isLoading = true;
    });

    // Direkt satın alma işlemi
    _purchaseProduct(productId);
  }

  // Fiyatlara göre paketleri sırala
  Future<List<PlanModel>> _sortPackagesByPrice(List<PlanModel> packages) async {
    final List<MapEntry<PlanModel, double>> packagesWithPrices = [];

    for (final package in packages) {
      try {
        final productDetails =
            await RevenueCatService.getOneTimeProductDetails(package.planId);
        final priceString = productDetails['price'] as String? ?? '0';

        // Fiyat string'ini double'a çevir (örn: "₺29,99" -> 29.99)
        final price = _parsePrice(priceString);
        packagesWithPrices.add(MapEntry(package, price));
      } catch (e) {
        // Hata durumunda 0 fiyat ver
        packagesWithPrices.add(MapEntry(package, 0.0));
      }
    }

    // Fiyata göre sırala (ucuzdan pahalıya)
    packagesWithPrices.sort((a, b) => a.value.compareTo(b.value));

    return packagesWithPrices.map((entry) => entry.key).toList();
  }

  // Fiyat string'ini double'a çevir
  double _parsePrice(String priceString) {
    try {
      // Sadece sayıları ve nokta/virgülü al
      final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.,]'), '');

      // Virgülü noktaya çevir (Türkçe format için)
      final normalizedPrice = cleanPrice.replaceAll(',', '.');

      return double.parse(normalizedPrice);
    } catch (e) {
      return 0.0;
    }
  }

  void _purchaseProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });

    context.read<PaymentBloc>().add(
          PurchaseOneTimeProduct(
            productId: productId,
            context: context,
          ),
        );
  }
}
