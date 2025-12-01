# 🎯 EVENT EKLEME REHBERİ - Nasıl Eklenir?

## ✅ ŞU AN EKLENMİŞ OLANLAR

### 1. APP & SPLASH (✅ TAMAM)
- app_opened
- splash_started, splash_progress, splash_completed, splash_error

### 2. LOGIN & SIGNUP (✅ TAMAM) 
- login_screen_viewed, login_attempt_started, login_success, login_failed
- signup_screen_viewed, signup_attempt_started, signup_success, signup_failed

### 3. HOME (✅ TAMAM)
- home_screen_reached
- tab_changed

### 4. TEMPLATE (✅ TAMAM - TAM!)
- ✅ template_detail_viewed
- ✅ template_photo_uploaded
- ✅ template_generate_started
- ✅ template_generate_completed
- ✅ template_generate_failed
- ✅ template_screen_exited

---

## ❌ HENÜZ EKLENMEMİŞ - SEN EKLEYEBİLİRSİN!

### 📝 NASIL EKLERİM?

Her event için 3 adım:

#### 1️⃣ Import ekle
```dart

```

#### 2️⃣ Event'i çağır
```dart
// Basit event
UserJourneyLogger.logLibraryViewed();

// Data ile event
UserJourneyLogger.logPaymentPlanSelected('plan_123', 'Premium', 9.99);
```

#### 3️⃣ Doğru yere koy!

---

## 🎯 EKLEMEN GEREKEN EVENTLER

### 💳 PAYMENT EVENTS (ÇOK ÖNEMLİ!)

**Dosya**: `lib/app/features/payment/ui/payment_screen.dart`

```dart
// initState'e ekle
@override
void initState() {
  super.initState();
  UserJourneyLogger.logPaymentScreenViewed('unknown'); // Nereden geldi?
  ...
}

// Plan seçildiğinde (CreditPackagesWidget'ta)
UserJourneyLogger.logPaymentPlanSelected(
  planId,
  planName,
  price,
);

// Ödeme başladığında
UserJourneyLogger.logPaymentStarted(planId, planName);

// Ödeme başarılı (RevenueCat callback)
UserJourneyLogger.logPaymentCompleted(planId, planName, price);

// Ödeme başarısız
UserJourneyLogger.logPaymentFailed(planId, error);

// Ödeme iptal
UserJourneyLogger.logPaymentCancelled(planId);
```

---

### 📚 LIBRARY EVENTS

**Dosya**: `lib/app/features/library/ui/screens/library_screen.dart`

```dart
// Library açıldığında
@override
void initState() {
  super.initState();
  UserJourneyLogger.logLibraryViewed();
}

// Item tıklandığında (ImageDetailScreen, VideoDetailScreen)
UserJourneyLogger.logLibraryItemClicked('image', imageId);

// Share edildiğinde
UserJourneyLogger.logLibraryItemShared('video', 'instagram');

// Delete edildiğinde
UserJourneyLogger.logLibraryItemDeleted('image');
```

---

### 👤 PROFILE EVENTS

**Dosya**: `lib/app/features/auth/features/profile/ui/profile_screen.dart`

```dart
// Profile açıldığında
@override
void initState() {
  super.initState();
  UserJourneyLogger.logProfileViewed();
}

// Logout butonuna tıklandığında
UserJourneyLogger.logLogoutClicked();

// Logout tamamlandığında
UserJourneyLogger.logLogoutCompleted();

// Profile düzenleme
UserJourneyLogger.logProfileEdited('name'); // veya 'email', 'photo', vs.
```

---

### 🎨 TEXT TO IMAGE EVENTS

**Dosya**: `lib/app/features/text_to_image/ui/text_to_image_screen.dart`

```dart
// Generate başladığında
UserJourneyLogger.logTextToImageStarted(promptText);

// Generate tamamlandığında (Bloc listener'da)
UserJourneyLogger.logTextToImageCompleted(durationSeconds: duration);

// Hata oluştuğunda
UserJourneyLogger.logTextToImageFailed(errorMessage);
```

---

### 🎥 VIDEO GENERATE EVENTS

**Dosya**: `lib/app/features/video_generate/ui/video_generate_screen.dart`

```dart
// Video generate başladığında
UserJourneyLogger.logVideoGenerateStarted('text_to_video');

// Tamamlandığında
UserJourneyLogger.logVideoGenerateCompleted(durationSeconds: duration);

// Hata
UserJourneyLogger.logVideoGenerateFailed(errorMessage);
```

---

### ⚡ REALTIME AI EVENTS

**Dosya**: `lib/app/features/realtime/ui/realtime_screen.dart`

```dart
// Realtime AI başladığında
@override
void initState() {
  super.initState();
  UserJourneyLogger.logRealtimeAIStarted();
}

// Foto çekildiğinde
UserJourneyLogger.logRealtimeAIPhotoTaken();

// İşlem tamamlandığında
UserJourneyLogger.logRealtimeAICompleted(durationSeconds: duration);
```

---

### 🚨 ERROR TRACKING

**HER YERDE kullanabilirsin**:

```dart
try {
  // bir şey yap
} catch (e) {
  UserJourneyLogger.logErrorShown(
    e.toString(),
    screen: 'payment_screen',
    action: 'buy_premium',
  );
}

// Network hatası
UserJourneyLogger.logNetworkError('/api/generate', errorMessage);
```

---

### ⭐ FEATURE BLOCKED

**Kredit yoksa veya premium gerekiyorsa**:

```dart
// Özellik engellendi
UserJourneyLogger.logFeatureBlocked(
  'video_generate',
  reason: 'no_credit', // veya 'premium_only'
);

// Özellik kullanıldı
UserJourneyLogger.logFeatureAccessed('template_generate');
```

---

## 🎯 HANGİLERİ ÖNCELİKLİ?

### HEMEN EKLE:
1. ✅ **Payment Events** - Para için kritik!
2. ✅ **Feature Blocked** - Neden premium almıyorlar?
3. ✅ **Profile/Logout** - Kullanıcı davranışı

### İYİ OLUR:
4. **Text to Image / Video Generate** - Özellik kullanımı
5. **Library** - İçerik paylaşımı
6. **Realtime AI** - Özellik kullanımı

### SONRA:
7. **Error Tracking** - Hata analizi
8. **Onboarding** - Varsa

---

## 📋 ÖRNEK: Payment Event Ekleme

### Önce:
```dart
void _buyPremium(String planId) {
  RevenueCatService.purchasePackage(planId);
}
```

### Sonra:
```dart
void _buyPremium(String planId) {
  // Event ekle
  UserJourneyLogger.logPaymentStarted(planId, 'Premium Monthly');
  
  RevenueCatService.purchasePackage(planId).then((success) {
    if (success) {
      UserJourneyLogger.logPaymentCompleted(planId, 'Premium Monthly', 9.99);
    } else {
      UserJourneyLogger.logPaymentFailed(planId, 'Purchase cancelled');
    }
  });
}
```

---

## 🚀 TAVSİYEM

**Önce şunları ekle** (30 dakika):
1. Payment events (6 event)
2. Feature blocked (önemli yerlere)
3. Profile/Logout (3 event)

**Sonra bunları** (isteğe bağlı):
4. Text to Image / Video (6 event)
5. Library (4 event)
6. Realtime AI (3 event)

**TOPLAM**: ~20-25 event daha eklersin, bütün app tracking altında olur! 🔥

---

## 💡 HIZLI İPUÇLARI

1. **initState** → Ekran görüntüleme eventleri
2. **onPressed** → Button click eventleri  
3. **try-catch** → Error tracking
4. **Bloc listener** → Success/Failure eventleri
5. **dispose** → Ekrandan çıkış eventleri

Her dosyaya import'u eklemeyi unutma:
```dart

```

---

## 🎉 SONUÇ

Ben **Template events'leri tamamen ekledim** (en önemli kısım).

Sen şimdi:
- Payment events ekle (PARA İÇİN!)
- Feature blocked ekle (premium conversion için)
- Geri kalanını iste dilediğince!

**Her event Firestore'da gerçek zamanlı görünecek!** 🔥

