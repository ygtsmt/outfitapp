// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/payment/bloc/payment_bloc.dart';
import 'package:ginfit/app/features/payment/ui/widgets/payment_advantages_widget.dart'
    show PaymentAdvantagesWidget, PaymentAdvantagesWidgetState;
import 'package:ginfit/app/features/payment/ui/widgets/payment_plans_widget.dart';
import 'package:ginfit/app/features/payment/ui/widgets/credit_packages_widget.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/core/core.dart';

import 'package:ginfit/app/core/services/revenue_cat_service.dart';
import 'package:ginfit/generated/l10n.dart';

class PaymentsScreen extends StatefulWidget {
  final bool? isPaywall;
  const PaymentsScreen({super.key, this.isPaywall = false});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<PaymentAdvantagesWidgetState> _advantagesKey =
      GlobalKey<PaymentAdvantagesWidgetState>();

  TabController? _tabController;
  bool _hasActiveSubscription = false;
  bool _isLoadingSubscription = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final hasSubscription = await RevenueCatService.isUserSubscribed();
      setState(() {
        _hasActiveSubscription = hasSubscription;
        _isLoadingSubscription = false;
        _tabController = TabController(
          length: hasSubscription ? 2 : 1, // Abonelik varsa 2 tab, yoksa 1 tab
          vsync: this,
        );
        _tabController!.addListener(() {
          if (_tabController!.indexIsChanging) {
            setState(() {});
          }
        });
      });
    } catch (e) {
      setState(() {
        _hasActiveSubscription = false;
        _isLoadingSubscription = false;
        _tabController = TabController(
            length: 1, vsync: this); // Hata durumunda sadece plans
        _tabController!.addListener(() {
          if (_tabController!.indexIsChanging) {
            setState(() {});
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state.addCreditForRewardedStatus == EventStatus.success) {
          getIt<ProfileBloc>().add(
            FetchProfileInfoEvent(auth.currentUser?.uid ?? ''),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.gray100,
          body: BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Advantages Widget
                    PaymentAdvantagesWidget(
                      key: _advantagesKey,
                    ),
                    LayoutConstants.defaultEmptyHeight,

                    // Loading state
                    if (_isLoadingSubscription || _tabController == null)
                      const Center(child: CircularProgressIndicator())

                    // TabBar - SADECE aboneliği olanlara göster (2 tab varsa)
                    else if (_hasActiveSubscription)
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.2),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController!,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: Theme.of(context).primaryColor,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.white,
                              unselectedLabelColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              labelStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              tabs: [
                                Tab(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context).plans),
                                      ],
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).credits,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LayoutConstants.defaultEmptyHeight,
                          // TabBarView - 2 tab için
                          IndexedStack(
                            index: _tabController!.index,
                            children: [
                              PaymentPlansWidget(
                                onPlanSelected: (index) {
                                  _advantagesKey.currentState
                                      ?.updateSelectedPlan(index);
                                },
                              ),
                              const CreditPackagesWidget(),
                            ],
                          ),
                        ],
                      )

                    // Aboneliği yok - Direkt Plans göster (TabBar yok!)
                    else
                      PaymentPlansWidget(
                        onPlanSelected: (index) {
                          _advantagesKey.currentState
                              ?.updateSelectedPlan(index);
                        },
                      ),
                    // Legal links - her sekme için ayrı ayrı göster
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
