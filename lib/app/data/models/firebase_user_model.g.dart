// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseUserModel _$FirebaseUserModelFromJson(Map<String, dynamic> json) =>
    FirebaseUserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      dailyAdsTime: const TimestampConverter().fromJson(json['dailyAdsTime']),
      dailyAdsWatched: (json['dailyAdsWatched'] as num?)?.toInt(),
      totalAdsWatched: (json['totalAdsWatched'] as num?)?.toInt(),
      lastClaimTimestamp:
          const TimestampConverter().fromJson(json['lastClaimTimestamp']),
      emailVerified: json['emailVerified'] as bool,
      isAnonymous: json['isAnonymous'] as bool,
      phoneNumber: json['phoneNumber'] as String?,
      photoURL: json['photoURL'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tenantId: json['tenantId'] as String?,
      authProvider: json['authProvider'] as String?,
      platform: json['platform'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      userUploadedFiles: (json['user_uploaded_files'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FirebaseUserModelToJson(FirebaseUserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'emailVerified': instance.emailVerified,
      'isAnonymous': instance.isAnonymous,
      'dailyAdsTime': const TimestampConverter().toJson(instance.dailyAdsTime),
      'lastClaimTimestamp':
          const TimestampConverter().toJson(instance.lastClaimTimestamp),
      'dailyAdsWatched': instance.dailyAdsWatched,
      'totalAdsWatched': instance.totalAdsWatched,
      'phoneNumber': instance.phoneNumber,
      'photoURL': instance.photoURL,
      'refreshToken': instance.refreshToken,
      'tenantId': instance.tenantId,
      'authProvider': instance.authProvider,
      'platform': instance.platform,
      'metadata': instance.metadata,
      'user_uploaded_files': instance.userUploadedFiles,
    };
