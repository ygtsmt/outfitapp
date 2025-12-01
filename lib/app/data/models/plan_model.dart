class PlanModel {
  final String planId;
  final Map<String, List<String>> benefits; // Language -> Benefits listesi
  final int purchasedCredit;

  const PlanModel({
    required this.planId,
    required this.benefits,
    required this.purchasedCredit,
  });

  factory PlanModel.fromMap(Map<String, dynamic> map, String planId) {
    final benefitsMap = <String, List<String>>{};

    // Benefits map'ini al
    final benefitsData = map['benefits'] as Map<String, dynamic>?;
    if (benefitsData != null) {
      // Her dil için benefits array'ini al
      benefitsData.forEach((key, value) {
        if (value is List) {
          benefitsMap[key] = List<String>.from(value);
        }
      });
    }

    return PlanModel(
      planId: planId,
      benefits: benefitsMap,
      purchasedCredit: map['purchased_credit'] ?? 0,
    );
  }

  // Belirli bir dildeki benefits'i getir
  List<String> getBenefitsForLanguage(String languageCode) {
    // Firebase'deki key formatına çevir (tr -> benefitsTR, en -> benefitsEN)
    final firebaseKey = 'benefits${languageCode.toUpperCase()}';

    // Önce tam eşleşme ara (benefitsTR, benefitsEN gibi)
    if (benefits.containsKey(firebaseKey)) {
      return benefits[firebaseKey]!;
    }

    // Tam eşleşme yoksa, dil kodunun ilk 2 karakterini ara (tr-TR -> benefitsTR)
    final shortCode = languageCode.split('_')[0].toLowerCase();
    final shortFirebaseKey = 'benefits${shortCode.toUpperCase()}';

    if (benefits.containsKey(shortFirebaseKey)) {
      return benefits[shortFirebaseKey]!;
    }

    // Hiç eşleşme yoksa İngilizce'yi döndür
    return benefits['benefitsEN'] ?? benefits.values.firstOrNull ?? [];
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'benefits': benefits,
      'purchasedCredit': purchasedCredit,
    };
  }

  @override
  String toString() {
    return 'PlanModel(planId: $planId, benefits: $benefits, purchasedCredit: $purchasedCredit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanModel &&
        other.planId == planId &&
        other.benefits == benefits &&
        other.purchasedCredit == purchasedCredit;
  }

  @override
  int get hashCode {
    return planId.hashCode ^ benefits.hashCode ^ purchasedCredit.hashCode;
  }
}
