# Review System Update - 2. Video Unlock

## 🎯 Genel Bakış

Review sistemi güncellendi. Artık review yapıldığında **kredi verilmez**, sadece **2. video oluşturma izni** verilir.

---

## 📊 Yeni Sistem

### Kullanıcı Tipleri:

#### 💎 PLAN SAHİBİ (RevenueCat Subscription)
```dart
// RevenueCat kontrolü
final hasActiveSubscription = await RevenueCatService.isUserSubscribed();

if (hasActiveSubscription) {
  // ✅ Review gerekmez
  // ✅ Sınırsız video oluşturabilir
  return true;
}
```

#### 🆓 FREE KULLANICI (Plan yok)
```
1️⃣ İlk Video:
   ✅ İlk indirme bonusu: 60 kredi
   ✅ Direkt oluşturabilir

2️⃣ İkinci Video:
   ⚠️ REVIEW ZORUNLU
   ⭐ 5 yıldız verip yorum yap
   ❌ Kredi kazanılmaz
   ✅ Sadece 2. video oluşturma izni

3️⃣ Sonraki Videolar:
   ✅ Reklam kredileri (günde 60 kredi)
   ✅ Satın alma kredileri
```

---

## 🔧 Yapılan Değişiklikler

### 1. Cloud Function (`functions/src/bonusSystem/reviewCredit.js`)

#### Önceki Sistem:
```javascript
transaction.update(userRef, {
  'profile_info.totalCredit': admin.firestore.FieldValue.increment(60), // ❌ Kredi veriliyordu
  'profile_info.hasReceivedReviewCredit': true,
});
```

#### Yeni Sistem:
```javascript
transaction.update(userRef, {
  // ❌ KREDİ YOK
  'profile_info.hasReceivedReviewCredit': true, // ✅ Sadece flag
  'profile_info.reviewCreditDate': admin.firestore.FieldValue.serverTimestamp(),
  'profile_info.reviewRating': rating
});

return {
  success: true,
  creditAmount: 0, // ⚠️ Artık kredi yok
  message: 'Review tamamlandı! Artık 2. videoyu oluşturabilirsiniz.'
};
```

---

### 2. Video Generation Kontrolü

**Dosya:** `lib/app/features/template_generate/ui/screens/generate_template_video_screen.dart`

#### Review Kontrolü Akışı:
```dart
Future<bool> _checkReviewRequirement(BuildContext context) async {
  // 1. User kontrolü
  if (user == null) return true;
  
  // 2. Video sayısı kontrolü
  final videoCount = videos?.length ?? 0;
  if (videoCount != 1) return true; // 1. video değilse geç
  
  // 3. 🔥 REVENUECAT KONTROLÜ
  final hasActiveSubscription = await RevenueCatService.isUserSubscribed();
  if (hasActiveSubscription) {
    debugPrint('✅ User has active plan (RevenueCat), bypassing review');
    return true; // Planı var, review gerekmez
  }
  
  // 4. Review yapılmış mı?
  final hasReceivedReviewCredit = userData?['profile_info']?['hasReceivedReviewCredit'] ?? false;
  if (hasReceivedReviewCredit) {
    debugPrint('✅ User already completed review');
    return true; // Review yapılmış
  }
  
  // 5. Device kontrolü
  final deviceDoc = await FirebaseFirestore.instance
      .collection('device_review_credits')
      .doc(deviceId)
      .get();
      
  if (deviceDoc.exists && deviceDoc.data()?['claimed'] == true) {
    return true; // Bu cihazdan review yapılmış
  }
  
  // 6. Review gerekli!
  await _showReviewRequiredDialog(context);
  return false; // Video üretimini durdur
}
```

---

### 3. UI Mesajları Güncellendi

#### İngilizce (`intl_en.arb`):
```json
{
  "reviewRequiredTitle": "Unlock 2nd Video",
  "reviewRequiredMessage": "Please rate our app to create your 2nd video!",
  "reviewRequiredButton": "Rate 5 Stars & Create 2nd Video",
  "rateAppSubtitle": "Rate 5 stars, write a review and unlock 2nd video"
}
```

#### Türkçe (`intl_tr.arb`):
```json
{
  "reviewRequiredTitle": "2. Videoyu Aç",
  "reviewRequiredMessage": "2. videonuzu oluşturmak için lütfen uygulamamızı değerlendirin!",
  "reviewRequiredButton": "5 Yıldız Ver & 2. Videoyu Aç",
  "rateAppSubtitle": "5 yıldız ver, yorum yap ve 2. videoyu aç"
}
```

---

## 🔑 RevenueCat Entegrasyon

### Subscription Kontrolü:
```dart
// lib/app/core/services/revenue_cat_service.dart

/// Kullanıcı abone mi kontrol et
static Future<bool> isUserSubscribed() async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.isNotEmpty;
  } catch (e) {
    debugPrint('❌ Failed to check subscription status: $e');
    return false;
  }
}
```

### Kullanım:
```dart
// Template generate screen'de
final hasActiveSubscription = await RevenueCatService.isUserSubscribed();

if (hasActiveSubscription) {
  // Planı var, review zorunluluğu yok
  return true;
}
```

---

## 📱 Kullanıcı Deneyimi

### Senaryo 1: Free Kullanıcı
```
Kullanıcı Actions:
├─ 1. Uygulamayı indirir
│  └─ +60 kredi (ilk indirme bonusu)
│
├─ 2. İlk videoyu oluşturur
│  └─ ✅ 60 kredi ile direkt oluşturur
│  └─ Video sayısı: 1
│
├─ 3. İkinci video için Generate'e tıklar
│  └─ ⚠️ Review dialog'u gösterilir
│  └─ "2. videonuzu oluşturmak için review yapın"
│
├─ 4. Review yaparak 5 yıldız verir
│  └─ ✅ hasReceivedReviewCredit = true
│  └─ ❌ Kredi eklenmez
│  └─ ✅ "2. videoyu oluşturabilirsiniz" mesajı
│
├─ 5. İkinci videoyu oluşturur
│  └─ ✅ Review flag sayesinde geçer
│  └─ Kalan kredi ile oluşturur
│
└─ 6. Sonraki videolar
   └─ Reklam izleyerek kredi kazanır (max 3 reklam/gün)
   └─ Satın alarak kredi kazanır
```

### Senaryo 2: Plan Sahibi
```
Kullanıcı Actions:
├─ 1. Plan satın alır (RevenueCat)
│  └─ ✅ Aktif subscription
│
├─ 2. İlk videoyu oluşturur
│  └─ ✅ Direkt oluşturur
│
├─ 3. İkinci videoyu oluşturur
│  └─ ✅ RevenueCat kontrolü: true
│  └─ ✅ Review gerekmeden oluşturur
│
└─ 4. Sınırsız video oluşturur
   └─ ✅ Plan sayesinde kısıtlama yok
```

---

## 🚀 Deployment

### 1. Firebase Functions Deploy:
```bash
cd /Users/yigitsametolmez/ginly/functions
firebase deploy --only functions:claimReviewCredit
```

### 2. Flutter Build:
```bash
cd /Users/yigitsametolmez/ginly
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Test:
```bash
# iOS
flutter run -d "iPhone Simulator"

# Android
flutter run -d "Android Emulator"
```

---

## ✅ Test Senaryoları

### Test 1: Free Kullanıcı - Review Zorunlu
```
1. Yeni hesap oluştur
2. İlk videoyu oluştur (60 kredi ile)
3. İkinci video için Generate'e tıkla
4. ✅ Review dialog'u gösterilmeli
5. Review yap (5 yıldız)
6. ✅ "2. videoyu oluşturabilirsiniz" mesajı görmeli
7. ✅ Kredi eklenmemeli (0 kredi)
8. İkinci videoyu oluştur
9. ✅ Başarılı olmalı
```

### Test 2: Plan Sahibi - Review Yok
```
1. Plan satın al (RevenueCat)
2. İlk videoyu oluştur
3. İkinci videoyu oluştur
4. ✅ Review dialog'u GÖSTERİLMEMELİ
5. ✅ Direkt video oluşturmalı
```

### Test 3: Device Zaten Kullanılmış
```
1. Hesap A ile review yap
2. Logout ol
3. Hesap B ile giriş yap (aynı device)
4. İkinci video için Generate'e tıkla
5. ✅ Review dialog'u gösterilmemeli
6. ✅ "Başka hesap bu cihazdan review yaptı" log'u
```

---

## 📊 Firebase Firestore Yapısı

### User Document:
```javascript
{
  profile_info: {
    hasReceivedReviewCredit: true,    // Review yapıldı mı?
    reviewCreditDate: Timestamp,      // Review tarihi
    reviewRating: 5,                  // Kaç yıldız verildi
    totalCredit: 60,                  // ❌ Review'dan kredi eklenmez
    has_active_subscription: false    // ⚠️ Artık kullanılmıyor (RevenueCat kontrolü kullan)
  }
}
```

### Device Review Credits:
```javascript
{
  device_review_credits: {
    [deviceId]: {
      claimed: true,
      claimedAt: Timestamp,
      userId: "user123",
      creditAmount: 0,                // ⚠️ Artık 0
      rating: 5
    }
  }
}
```

---

## 🔍 Debug Log'ları

### Başarılı Review:
```
🔥 [TEMPLATE-REVIEW-CHECK] Video count: 1
🔥 [TEMPLATE-REVIEW-CHECK] Has Active Subscription (RevenueCat): false
🔥 [TEMPLATE-REVIEW-CHECK] User Has Received Review Credit: false
🔥 [TEMPLATE-REVIEW-CHECK] Device Already Claimed: false
⚠️ [TEMPLATE-REVIEW-CHECK] No review! Showing dialog...
⭐ Requesting review credit via Cloud Function...
✅ Review completed! Now you can create your 2nd video.
```

### Plan Sahibi:
```
🔥 [TEMPLATE-REVIEW-CHECK] Video count: 1
🔥 [TEMPLATE-REVIEW-CHECK] Has Active Subscription (RevenueCat): true
✅ [TEMPLATE-REVIEW-CHECK] User has active plan, bypassing review requirement
```

---

## ⚠️ Önemli Notlar

1. **RevenueCat Öncelikli**: `has_active_subscription` field'ı artık kullanılmıyor. RevenueCat'in kendi kontrolü kullanılıyor.

2. **Kredi Değişmez**: Review yapıldığında kredi eklenmez, sadece `hasReceivedReviewCredit` flag'i true olur.

3. **2. Video Kontrolü**: Sadece video sayısı 1 olan kullanıcılar için review zorunlu.

4. **Device Lock**: Bir cihazdan sadece 1 kere review yapılabilir.

5. **Plan Bypass**: Aktif planı olan kullanıcılar review yapmadan sınırsız video oluşturabilir.

---

## 🔗 İlgili Dosyalar

```
functions/
└── src/
    └── bonusSystem/
        └── reviewCredit.js              [Cloud Function]

lib/
├── app/
│   ├── core/
│   │   └── services/
│   │       └── revenue_cat_service.dart [RevenueCat kontrolü]
│   └── features/
│       ├── template_generate/
│       │   └── ui/
│       │       └── screens/
│       │           └── generate_template_video_screen.dart [Review kontrolü]
│       └── payment/
│           └── ui/
│               └── free_credit_screen.dart [Review UI]
└── l10n/
    ├── intl_en.arb                      [İngilizce metinler]
    └── intl_tr.arb                      [Türkçe metinler]
```

---

**Son Güncelleme:** 2024-11-10  
**Versiyon:** 2.0  
**Status:** ✅ Production Ready













