import 'package:json_annotation/json_annotation.dart';

part 'purchased_info_model.g.dart';

@JsonSerializable()
class PurchasedInfo {
  final String? currentPlanId;
  final String? lastProductId;
  PurchasedInfo({this.currentPlanId, this.lastProductId});

  factory PurchasedInfo.fromJson(Map<String, dynamic> json) {
    return PurchasedInfo(
      currentPlanId: json['current_plan_id'],
      lastProductId: json['plan_history'].last['product_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_plan_id': currentPlanId,
      'last_product_id': lastProductId,
    };
  }
}
