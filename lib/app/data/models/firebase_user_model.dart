import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_user_model.g.dart';

class TimestampConverter implements JsonConverter<Timestamp?, dynamic> {
  const TimestampConverter();

  @override
  Timestamp? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json;
    if (json is Map<String, dynamic>) {
      return Timestamp(
        json['_seconds'] as int,
        json['_nanoseconds'] as int,
      );
    }
    return null;
  }

  @override
  dynamic toJson(Timestamp? timestamp) => timestamp;
}

@JsonSerializable(explicitToJson: true)
class FirebaseUserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final bool emailVerified;
  final bool isAnonymous;

  @TimestampConverter()
  final Timestamp? dailyAdsTime;

  @TimestampConverter()
  final Timestamp? lastClaimTimestamp;

  final int? dailyAdsWatched;
  final int? totalAdsWatched; // Toplam claim sayısı
  final String? phoneNumber;
  final String? photoURL;
  final String? refreshToken;
  final String? tenantId;
  final String? authProvider;
  final String? platform;
  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'user_uploaded_files')
  final List<String>? userUploadedFiles;

  const FirebaseUserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.dailyAdsTime,
    this.dailyAdsWatched,
    this.totalAdsWatched,
    this.lastClaimTimestamp,
    required this.emailVerified,
    required this.isAnonymous,
    this.phoneNumber,
    this.photoURL,
    this.refreshToken,
    this.tenantId,
    this.authProvider,
    this.platform,
    this.metadata,
    this.userUploadedFiles,
  });

  factory FirebaseUserModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseUserModelToJson(this);

  static Map<String, dynamic> toMap(User user,
      {String? displayName, String? authProvider, String? platform}) {
    return {
      'uid': user.uid,
      'displayName': user.displayName ?? displayName,
      'email': user.email,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'dailyAdsTime': Timestamp.now(),
      'lastClaimTimestamp':
          Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      'dailyAdsWatched': 0,
      'totalAdsWatched': 0, // Yeni hesap için 0
      'phoneNumber': user.phoneNumber,
      'photoURL': user.photoURL,
      'refreshToken': user.refreshToken,
      'tenantId': user.tenantId,
      'authProvider': authProvider,
      'platform': platform, // iOS, Android, Web
      'metadata': {
        'creationTime': user.metadata.creationTime?.toIso8601String(),
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
      },
      'user_uploaded_files': [], // Yeni hesap için boş liste
    };
  }
}
