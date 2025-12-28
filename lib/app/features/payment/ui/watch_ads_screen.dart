// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/payment/ui/widgets/watched_ads_daily_counter.dart';
import 'package:ginfit/app/ui/widgets/total_credit_widget.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/payment/bloc/payment_bloc.dart';
import 'package:ginfit/core/core.dart';

class WatchAdsScreen extends StatefulWidget {
  const WatchAdsScreen({super.key});

  @override
  State<WatchAdsScreen> createState() => _WatchAdsScreenState();
}

class _WatchAdsScreenState extends State<WatchAdsScreen> {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _hasEarnedReward = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getIt<ProfileBloc>().add(
      FetchProfileInfoEvent(auth.currentUser?.uid ?? ''),
    );

    // 🔒 Reklam izleme yetkisi kontrolü
    _checkWatchAdsPermission();

    // AdMob'u hem Android hem iOS'ta yükle
    _loadRewardedAd();
  }

  /// Kullanıcının reklam izleme yetkisi var mı kontrol et
  void _checkWatchAdsPermission() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileBloc = context.read<ProfileBloc>();
      final canWatchAds = profileBloc.state.profileInfo?.isCanWatchAds;
      
      // false ise (suistimal) geri yönlendir
      if (canWatchAds == false) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam izleme yetkiniz bulunmamaktadır.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .creditEarned), // Her reklam 6 kredi veriyor
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).earn_credits),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actionsPadding: EdgeInsets.only(right: 12.w),
            actions: const [
              TotalCreditWidget(
                navigateAvailable: false,
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                LayoutConstants.ultraEmptyHeight,
                const WatchedAdsDailyCounter(),
                LayoutConstants.highEmptyHeight,
                Column(
                  spacing: 4.h,
                  children: [
                    Text(
                      AppLocalizations.of(context).watch_ad,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.baseColor,
                              ),
                    ),
                    Text(
                      '${AppLocalizations.of(context).watchAdToEarn}\n${AppLocalizations.of(context).watchLimit}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                LayoutConstants.largeEmptyHeight,
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    final dailyAdsWatched =
                        state.profileInfo?.dailyAdsWatched ?? 0;
                    final canWatch =
                        canWatchAd(state.profileInfo?.lastClaimTimestamp);
                    final remainingTime =
                        state.profileInfo?.lastClaimTimestamp != null
                            ? state.profileInfo?.lastClaimTimestamp
                                ?.toDate()
                                .add(Duration(hours: 24))
                                .difference(DateTime.now())
                            : Duration.zero;

                    // Tüm platformlar: Günlük maksimum 3 reklam (60 kredi)
                    final hasReachedDailyLimit = dailyAdsWatched >= 60;

                    return Column(
                      spacing: 4.h,
                      children: [
                        if (!hasReachedDailyLimit && canWatch) ...[
                          ElevatedButton(
                            onPressed:
                                _isRewardedAdReady ? _showRewardedAd : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.baseColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32.w, vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow,
                                    color: Colors.white),
                                SizedBox(width: 8.w),
                                Text(
                                  _isRewardedAdReady
                                      ? AppLocalizations.of(context).watchAds
                                      : AppLocalizations.of(context).loading,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LayoutConstants.tinyEmptyHeight,
                          /*  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                PngPaths.coin,
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '20 ${AppLocalizations.of(context).credit}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.baseColor,
                                    ),
                              ),
                            ],
                          ), */
                        ] else ...[
                          if (!canWatch)
                            CountdownTimerWidget(
                              duration: remainingTime ?? Duration.zero,
                              onFinished: () {
                                // Geri sayım bittiğinde ne olsun?
                                print('Sayaç tamamlandı');
                                // setState ile butonu aktif edebilirsin
                              },
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.h, horizontal: 16.w),
                            child: Text(
                              AppLocalizations.of(context).daily_ads_earned,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                LayoutConstants.largeEmptyHeight,
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (builderContext, state) {
                    final currentWatched =
                        state.profileInfo?.dailyAdsWatched ?? 0;

                    // Her 60 kredi biriktiğinde claim aktif olur
                    final canClaim = currentWatched >= 60;

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !canClaim
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)
                                          .watch_5_ads_to_claim,
                                    ),
                                    backgroundColor: context.baseColor,
                                  ),
                                );
                              }
                            : () {
                                // Email doğrulama kontrolü KALDIRILDI - Direkt claim yap
                                getIt<PaymentBloc>().add(
                                  ClaimCreditForRewardedAd(context: context),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !canClaim
                              ? context.baseColor.withOpacity(0.2)
                              : context.baseColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w, vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).claim_earned_credits} (60 ${AppLocalizations.of(context).credit})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _loadRewardedAd() {
    // Platform-specific ad unit IDs
    final String adUnitId = Platform.isIOS
        ? 'ca-app-pub-9293946059678095/8574888035' // iOS rewarded ad unit ID
        : 'ca-app-pub-9293946059678095/9613012897'; // Android rewarded ad unit ID

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _setAdCallbacks();
          setState(() {});
        },
        onAdFailedToLoad: (_) {
          _isRewardedAdReady = false;
          setState(() {});
        },
      ),
    );
  }

  void _setAdCallbacks() {
    _hasEarnedReward = false;
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (_hasEarnedReward) {
          getIt<PaymentBloc>().add(
            AddCreditForRewardedAd(
                addingCreditCount: 20,
                context: context), // 6'dan 20'ye çıkarıldı
          );
        }
        ad.dispose();
        _loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewardedAd(); // Load next ad
      },
    );
  }

  void _showRewardedAd() {
    // Hem Android hem iOS'ta reklam göster
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (_, __) {
          _hasEarnedReward = true;
        },
      );
      _isRewardedAdReady = false;
      setState(() {});
    }
  }

  bool canWatchAd(Timestamp? lastClaimTimestamp) {
    // Tüm platformlar: Claim yapıldıktan sonra 24 saat bekle
    if (lastClaimTimestamp == null)
      return true; // Daha önce claim yapılmamışsa izin ver
    final lastClaim = lastClaimTimestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(lastClaim);
    return difference.inHours >= 24;
  }
}

class CountdownTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onFinished;

  const CountdownTimerWidget({
    super.key,
    required this.duration,
    this.onFinished,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds == 0) {
        timer.cancel();
        if (widget.onFinished != null) {
          widget.onFinished!();
        }
      } else {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(_remaining),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
    );
  }
}
