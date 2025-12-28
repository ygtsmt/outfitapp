import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/core/services/revenue_cat_service.dart';
import 'package:ginfit/app/features/payment/ui/widgets/payment_plan_card.dart';
import 'package:ginfit/app/ui/widgets/auth_required_widget.dart';
import 'package:ginfit/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'dart:io' show Platform;

import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaymentPlansWidget extends StatefulWidget {
  final Function(int)? onPlanSelected;

  const PaymentPlansWidget({super.key, this.onPlanSelected});

  @override
  State<PaymentPlansWidget> createState() => _PaymentPlansWidgetState();
}

class _PaymentPlansWidgetState extends State<PaymentPlansWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // Product IDs - Platform'a göre farklı
  List<String> get _productIds {
    if (Platform.isIOS) {
      // iOS Product IDs - Tek subscription group altında
      return [
        'ginly_plus_weekly_ios',
        'ginly_pro_weekly_ios',
        'ginly_ultra_weekly_ios',
      ];
    } else {
      // Android Product IDs - Ayrı subscription groups
      return [
        'ginly_plus_weekly',
        'ginly_pro_weekly',
        'ginly_ultra_weekly',
      ];
    }
  }

  int _selectedPlanIndex = 1; // Default olarak Pro plan (index 1) seçili
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.1, end: 1).animate(_controller);

    // Firebase'den plan'ları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBloc>().add(const GetPlansEvent());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: _isLoading
          ? Center(
              child: Column(
              children: [
                LoadingAnimationWidget.fourRotatingDots(
                  size: 42.h,
                  color: context.baseColor,
                ),
              ],
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...List.generate(_productIds.length, (index) {
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlanIndex = index;
                        });
                        // Seçilen plan index'ini parent widget'a bildir
                        widget.onPlanSelected?.call(index);

                        // Firebase Auth durumunu kontrol et
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          // Giriş yapmış kullanıcılar için ödeme ekranını çıkar
                          if (Platform.isIOS) {
                            // iOS için direkt abone olma
                            _purchaseIOSSubscription(index);
                          } else {
                            // Android için mevcut logic
                            _purchaseSubscription();
                          }
                        }
                        // Giriş yapmamış kullanıcılar için normal tıklama devam eder
                      },
                      child: FutureBuilder<String>(
                        future: _getDynamicPlanTitle(index),
                        builder: (context, titleSnapshot) {
                          return FutureBuilder<String>(
                            future: _getDynamicPlanPrice(index),
                            builder: (context, priceSnapshot) {
                              final title = titleSnapshot.data ??
                                  AppLocalizations.of(context).loading;
                              final price = priceSnapshot.data ??
                                  AppLocalizations.of(context).loading;

                              // Seçilen plana göre kredi sayısını ve benefits'i Firebase'den çek
                              final credits = _getCreditsForPlan(index);
                              final benefits = _getBenefitsForPlan(index);

                              return PaymentPlanCard(
                                title: _getPackageNameFromProductId(
                                    _productIds[index]),
                                price: price, // Sadece fiyat
                                duration: AppLocalizations.of(context)
                                    .perWeek, // Duration label'ı
                                isSelected: index == _selectedPlanIndex,
                                isProPlan: index ==
                                    1, // Sadece Pro plan (index 1) için true
                                credits: credits,
                                benefits: benefits,
                              );
                            },
                          );
                        },
                      ));
                }),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    AppLocalizations.of(context).autoRenewable,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
                ScaleTransition(
                  scale: _animation,
                  child: FirebaseAuth.instance.currentUser?.uid == null
                      ? AuthRequiredWidget()
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: CustomGradientButton(
                            title: _isLoading
                                ? AppLocalizations.of(context).processing
                                : AppLocalizations.of(context).subscribeNow,
                            onTap: _isLoading ? null : _purchaseSubscription,
                            isFilled: true,
                          ),
                        ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                  child: Column(
                    children: [
                      // First row: Terms of Use and Privacy Policy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.router.push(DocumentsWebViewScreenRoute(
                                pdfUrl: 'https://ginfit.ai/terms',
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
                              context.router.push(DocumentsWebViewScreenRoute(
                                pdfUrl: 'https://ginfit.ai/privacy',
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
                            context.router.push(DocumentsWebViewScreenRoute(
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
            ),
    );
  }

  String _getSelectedProductId() {
    return _productIds[_selectedPlanIndex];
  }

  // Seçilen plana göre kredi sayısını Firebase'den çek
  int _getCreditsForPlan(int index) {
    final plans = context.read<AppBloc>().state.plans;
    if (plans == null || plans.isEmpty) return 0;
    log(plans.toString());
    log(_productIds[index]);

    final productId = _productIds[index];
    final plan = plans.firstWhere(
      (p) => p.planId == productId,
      orElse: () => plans.first,
    );

    return plan.purchasedCredit;
  }

  // Seçilen plana göre benefits'i Firebase'den çek (dil desteği ile)
  List<String> _getBenefitsForPlan(int index) {
    final plans = context.read<AppBloc>().state.plans;
    if (plans == null || plans.isEmpty) return [];

    final productId = _productIds[index];
    final plan = plans.firstWhere(
      (p) => p.planId == productId,
      orElse: () => plans.first,
    );

    // Mevcut dil kodunu al
    final currentLocale = Localizations.localeOf(context);
    final languageCode = currentLocale.languageCode;

    return plan.getBenefitsForLanguage(languageCode);
  }

  // Google Play'den dinamik veri çeken method'lar
  Future<String> _getDynamicPlanTitle(int index) async {
    final productId = _productIds[index];
    return await RevenueCatService.getDynamicPlanTitle(productId);
  }

  Future<String> _getDynamicPlanPrice(int index) async {
    final productId = _productIds[index];
    return await RevenueCatService.getDynamicPlanPrice(productId);
  }

  Future<void> _purchaseSubscription() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 🔥 Satın almadan ÖNCE RevenueCat'i Firebase User ID ile sync et
      await RevenueCatService.syncWithFirebase();
      
      final productId = _getSelectedProductId();
      final result = await RevenueCatService.purchaseProduct(productId);

      if (result != null) {
        // 🔄 Premium template hakkını sıfırla (abonelik satın alındı)
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'profile_info.user_used_premium_template': false});
            debugPrint('✅ Premium template usage reset after subscription purchase');
          } catch (e) {
            debugPrint('❌ Error resetting premium template usage: $e');
          }
        }

        // Başarılı purchase
        if (mounted) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).subscriptionSuccessful);
          context.router.pushNamed('/homeScreen/profile/profile-screen');
          getIt<ProfileBloc>().add(FetchProfileInfoEvent(
              FirebaseAuth.instance.currentUser?.uid ?? ''));
          getIt<AppBloc>().add(FetchPurchasedInfoEvent(
              FirebaseAuth.instance.currentUser?.uid ?? ''));
        }
      } else {
        // Başarısız purchase
        if (mounted) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).purchaseFailed);
        }
      }
    } catch (e) {
      if (mounted) {
        Utils.showToastMessage(
            context: context,
            content: AppLocalizations.of(context).errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // iOS için direkt abonelik satın alma
  Future<void> _purchaseIOSSubscription(int planIndex) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 🔥 Satın almadan ÖNCE RevenueCat'i Firebase User ID ile sync et
      await RevenueCatService.syncWithFirebase();

      final productId = _productIds[planIndex];
      print('iOS Purchase initiated for: $productId');

      final result = await RevenueCatService.purchaseProduct(productId);

      if (result != null) {
        // Başarılı purchase
        print('iOS Purchase successful');
        if (mounted) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).subscriptionSuccessful);
          context.router.pushNamed('/homeScreen/profile/profile-screen');
          getIt<ProfileBloc>().add(FetchProfileInfoEvent(
              FirebaseAuth.instance.currentUser?.uid ?? ''));
          getIt<AppBloc>().add(FetchPurchasedInfoEvent(
              FirebaseAuth.instance.currentUser?.uid ?? ''));
        }
      } else {
        // Başarısız purchase
        print('iOS Purchase failed');
        if (mounted) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).purchaseFailed);
        }
      }
    } catch (e) {
      print('iOS Purchase Error: $e');
      if (mounted) {
        Utils.showToastMessage(
            context: context,
            content: AppLocalizations.of(context).errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getPackageNameFromProductId(String productId) {
    if (Platform.isIOS) {
      switch (productId) {
        case 'ginly_plus_weekly_ios':
          return 'GinFit AI Plus';
        case 'ginly_pro_weekly_ios':
          return 'GinFit AI Pro';
        case 'ginly_ultra_weekly_ios':
          return 'GinFit AI Ultra';
        default:
          return 'Credit Package';
      }
    } else
      switch (productId) {
        case 'ginly_plus_weekly':
          return 'GinFit AI Plus';
        case 'ginly_pro_weekly':
          return 'GinFit AI Pro';
        case 'ginly_ultra_weekly':
          return 'GinFit AI Ultra';
        default:
          return 'Credit Package';
      }
  }
}
