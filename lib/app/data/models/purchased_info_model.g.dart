// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchased_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchasedInfo _$PurchasedInfoFromJson(Map<String, dynamic> json) =>
    PurchasedInfo(
      currentPlanId: json['currentPlanId'] as String?,
      lastProductId: json['lastProductId'] as String?,
    );

Map<String, dynamic> _$PurchasedInfoToJson(PurchasedInfo instance) =>
    <String, dynamic>{
      'currentPlanId': instance.currentPlanId,
      'lastProductId': instance.lastProductId,
    };
