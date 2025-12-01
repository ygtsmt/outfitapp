import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String? displayName;
  final int? totalCredit;
  final int? dailyAdsWatched;
  final int? totalAdsWatched; // Toplam claim sayısı
  final Timestamp? dailyAdsTime;
  final Timestamp? lastClaimTimestamp;
  final String? email;
  final bool? emailVerified;
  final bool? isAnonymous;
  final String? refreshToken;
  final String? phoneNumber;
  String? photoURL;
  final String? tenantId;
  final String? uid;
  final String? authProvider;
  final int? refundCount;
  final bool? hasActiveSubscription; // Aktif subscription var mı?
  final bool? hasReceivedReviewCredit; // Review kredisi alındı mı?
  final bool? hasReceivedFirstInstallBonus; // First install bonus alındı mı?
  final String? firstInstallBonusLog; // First install bonus detaylı log
  final Timestamp? firstInstallBonusDate; // Bonus alınma tarihi
  final Timestamp? lastBonusCheckDate; // Son bonus kontrol tarihi
  final List<String>?
      userUploadedFiles; // Kullanıcının yüklediği dosya URL'leri
  final bool?
      isCanWatchAds; // Reklam izleme yetkisi (null veya true = izleyebilir, false = izleyemez)
  final bool?
      userUsedPremiumTemplate; // Kullanıcı premium template kullandı mı? (false = kullanabilir, true = kullandı, abonelik/kredi alana kadar kullanamaz)
  final bool?
      isDebug; // Debug hesabı mı? (true = debug, false/null = production)

  UserProfile(
      {this.displayName,
      this.totalCredit,
      this.dailyAdsWatched,
      this.totalAdsWatched,
      this.dailyAdsTime,
      this.lastClaimTimestamp,
      this.email,
      this.emailVerified,
      this.isAnonymous,
      this.refreshToken,
      this.tenantId,
      this.uid,
      this.photoURL,
      this.phoneNumber,
      this.authProvider,
      this.refundCount,
      this.hasActiveSubscription,
      this.hasReceivedReviewCredit,
      this.hasReceivedFirstInstallBonus,
      this.firstInstallBonusLog,
      this.firstInstallBonusDate,
      this.lastBonusCheckDate,
      this.userUploadedFiles,
      this.isCanWatchAds,
      this.userUsedPremiumTemplate,
      this.isDebug});

  // JSON'dan model oluşturma
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['profile_info']?['displayName'],
      totalCredit: json['profile_info']?['totalCredit'],
      dailyAdsWatched: json['profile_info']?['dailyAdsWatched'],
      totalAdsWatched: json['profile_info']?['totalAdsWatched'] ?? 0,
      dailyAdsTime: json['profile_info']?['dailyAdsTime'],
      lastClaimTimestamp: json['profile_info']?['lastClaimTimestamp'],
      email: json['profile_info']?['email'],
      emailVerified: json['profile_info']?['emailVerified'],
      isAnonymous: json['profile_info']?['isAnonymous'],
      refreshToken: json['refreshToken'],
      tenantId: json['tenantId'],
      uid: json['profile_info']?['uid'],
      photoURL: json['profile_info']?['photoURL'],
      phoneNumber: json['profile_info']?['phoneNumber'],
      authProvider: json['profile_info']?['authProvider'],
      refundCount: json['profile_info']?['refundCount'] ?? 0,
      hasActiveSubscription:
          json['profile_info']?['has_active_subscription'] ?? false,
      hasReceivedReviewCredit:
          json['profile_info']?['hasReceivedReviewCredit'] ?? false,
      hasReceivedFirstInstallBonus:
          json['profile_info']?['hasReceivedFirstInstallBonus'] ?? false,
      firstInstallBonusLog: json['profile_info']?['firstInstallBonusLog'],
      firstInstallBonusDate: json['profile_info']?['firstInstallBonusDate'],
      lastBonusCheckDate: json['profile_info']?['lastBonusCheckDate'],
      userUploadedFiles: json['user_uploaded_files'] != null
          ? List<String>.from(json['user_uploaded_files'])
          : null,
      isCanWatchAds: json['profile_info']?['is_can_watch_ads'],
      userUsedPremiumTemplate:
          json['profile_info']?['user_used_premium_template'] ?? false,
      isDebug: json['profile_info']?['is_debug'] ?? false,
    );
  }
}
