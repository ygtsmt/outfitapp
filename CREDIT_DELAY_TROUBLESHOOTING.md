# 🔍 Kredi Gecikmesi ve Gelmeme Sorunları - Troubleshooting Guide

## 📋 Sorun Analizi

Kullanıcıların abonelik veya kredi paketi satın aldıktan sonra kredilerin gelmemesi/geç gelmesi durumları için tüm olası nedenler ve çözümler.

---

## 🔴 Olası Nedenler ve Çözümler

### **1. Cloud Tasks Queue Oluşturulmamış** ⚠️ **CRİTİCAL**

**Problem:**
- RevenueCat webhook'u Cloud Tasks kullanıyor
- Queue manuel oluşturulmazsa webhook çalışmaz
- Krediler hiçbir zaman gelmez

**Çözüm:**
```bash
cd scripts
chmod +x create_cloud_tasks_queue.sh
./create_cloud_tasks_queue.sh
```

**Doğrulama:**
```bash
gcloud tasks queues describe payment-processing \
  --project=disciplify-26970 \
  --location=us-central1
```

---

### **2. Firestore `update()` Hatası** ⚠️ **CRİTİCAL**

**Problem:**
- Yeni kullanıcı kaydolup hemen satın alma yapıyor
- User document henüz tam oluşmamış
- `update()` çağrısı "Document not found" hatası veriyor
- Krediler eklenemiyor

**Çözüm:** ✅ **FIX EDİLDİ**
- `update()` yerine `set() + merge: true` kullanıldı
- User document yoksa otomatik oluşturuluyor
- Tüm handler'larda güvenli hale getirildi

**Değişiklikler:**
- ✅ `creditManager.js` - `updateCredits()` düzeltildi
- ✅ `creditManager.js` - `addLog()` düzeltildi
- ✅ `creditManager.js` - `addOneTimePurchaseLog()` düzeltildi
- ✅ `paymentHandlers.js` - `handleInitialPurchase()` güçlendirildi
- ✅ `paymentHandlers.js` - `handleOneTimePurchase()` güçlendirildi

---

### **3. Race Condition**

**Problem:**
- RevenueCat webhook gönderiliyor
- Kullanıcı uygulama tarafında hemen kredi kontrolü yapıyor
- Backend henüż işlemedi
- Kullanıcı "kredi gelmedi" düşünüyor

**Çözüm:** ✅ **MEVCUT**
- Uygulama Firestore StreamBuilder kullanıyor
- Real-time dinleme aktif (`TotalCreditWidget`)
- Krediler eklendiği anda UI otomatik güncelleniyor

**Doğrulama:**
```dart
// TotalCreditWidget.dart - Line 18-24
StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots(includeMetadataChanges: false),
  ...
)
```

---

### **4. RevenueCat Webhook Konfigürasyonu**

**Problem:**
- RevenueCat dashboard'da webhook URL yanlış
- Authorization header eksik
- Test edilmemiş

**Çözüm:**

1. **RevenueCat Dashboard'a Git:**
   - https://app.revenuecat.com/
   - Project Settings → Webhooks

2. **Webhook URL'i Ayarla:**
   ```
   https://us-central1-disciplify-26970.cloudfunctions.net/revenueCatWebhook
   ```

3. **Event'leri Seç:**
   - ✅ INITIAL_PURCHASE
   - ✅ RENEWAL
   - ✅ CANCELLATION
   - ✅ EXPIRATION
   - ✅ NON_RENEWING_PURCHASE
   - ✅ REFUND

4. **Test Et:**
   ```bash
   cd scripts
   chmod +x test_revenuecat_webhook.sh
   ./test_revenuecat_webhook.sh
   ```

---

### **5. Firebase Plans Collection Eksik**

**Problem:**
- `plans` collection'da product bilgileri yok
- `getWeeklyCredits()` 0 dönüyor
- Krediler eklenmiyor

**Çözüm:**

Firestore'da `plans` collection'ı kontrol et:

```
plans/
  ginly_plus_weekly/
    purchased_credit: 100
    benefits: {...}
  
  ginly_pro_weekly/
    purchased_credit: 250
    benefits: {...}
  
  ginly_ultra_weekly/
    purchased_credit: 500
    benefits: {...}
  
  ginly_extra_credit/
    purchased_credit: 150
    benefits: {...}
  
  ginly_boost_credit/
    purchased_credit: 300
    benefits: {...}
  
  ginly_mega_credit/
    purchased_credit: 600
    benefits: {...}
```

**Doğrulama:**
```bash
firebase firestore:get plans/ginly_plus_weekly
```

---

### **6. Cloud Functions Timeout**

**Problem:**
- Function 60 saniyede timeout oluyor
- İşlem yarıda kalıyor
- Krediler eklenmiyor

**Çözüm:** ✅ **MEVCUT**
- Cloud Tasks 10 dakika timeout
- 3 retry girişimi
- Exponential backoff

**Konfigürasyon:**
```javascript
// revenuecat.js - Line 135-141
retryConfig: {
  maxAttempts: 3,
  maxRetryDuration: { seconds: 300 },
  minBackoff: { seconds: 1 },
  maxBackoff: { seconds: 60 },
  maxDoublings: 3
}
```

---

### **7. Network/Firebase Erişim Sorunu**

**Problem:**
- Firebase Functions Firebase'e erişemiyor
- Network timeout
- Firestore yazma hatası

**Çözüm:**

1. **Firebase Functions Loglarını Kontrol Et:**
   ```bash
   firebase functions:log --only revenueCatWebhook,processPaymentEvent
   ```

2. **Error Pattern'lerini Ara:**
   ```bash
   firebase functions:log | grep "❌"
   ```

3. **Cloud Tasks Loglarını Kontrol Et:**
   ```bash
   gcloud tasks queues list --location=us-central1
   gcloud logging read "resource.type=cloud_tasks_queue" --limit=50
   ```

---

### **8. RevenueCat App User ID Mismatch**

**Problem:**
- RevenueCat'te farklı user ID
- Firebase'de farklı user ID
- Krediler yanlış kullanıcıya gidiyor veya hiç gitmiyor

**Çözüm:**

RevenueCat'te `app_user_id`'nin Firebase Auth UID ile aynı olduğunu doğrula:

```dart
// RevenueCat konfigürasyonu
await Purchases.logIn(FirebaseAuth.instance.currentUser!.uid);
```

**Doğrulama:**
```bash
# RevenueCat dashboard'da customer ID'yi kontrol et
# Firebase Auth'daki UID ile eşleşmeli
```

---

## 🔧 Hızlı Tanı Adımları

### **Sorun Yaşayan Kullanıcı İçin:**

1. **Firebase Console'a Git**
2. **Firestore'da kullanıcı dokümanını aç:**
   ```
   users/{userId}
   ```

3. **Kontrol Et:**
   - ✅ `profile_info.totalCredit` değeri var mı?
   - ✅ `profile_info.lastCreditUpdate` timestamp'i yeni mi?
   - ✅ `purchased_info` field'ı var mı?
   - ✅ `purchased_info.logs` array'inde satın alma kaydı var mı?
   - ✅ `one_time_purchases` array'inde kredi paketi var mı?

4. **Firebase Functions Loglarında Ara:**
   ```bash
   firebase functions:log | grep "{userId}"
   firebase functions:log | grep "Processing initial purchase"
   firebase functions:log | grep "Credits updated"
   ```

5. **Cloud Tasks Queue'yu Kontrol Et:**
   ```bash
   gcloud tasks list --queue=payment-processing --location=us-central1
   ```

---

## 🚀 Deployment Checklist

Sistemi deploy etmeden önce:

- [ ] Cloud Tasks queue oluşturuldu
- [ ] Firebase Functions deploy edildi
- [ ] RevenueCat webhook URL'i ayarlandı
- [ ] RevenueCat webhook test edildi
- [ ] Firestore `plans` collection'ı dolu
- [ ] Test satın alma yapıldı (sandbox)
- [ ] Kredilerin geldiği doğrulandı
- [ ] Loglar kontrol edildi
- [ ] Production'da test yapıldı

---

## 📊 Monitoring

### **Günlük Kontroller:**

1. **Failed Webhook'ları İzle:**
   ```bash
   firebase functions:log --only revenueCatWebhook | grep "❌"
   ```

2. **Cloud Tasks Başarısızlıklarını İzle:**
   ```bash
   gcloud logging read "resource.type=cloud_tasks_queue AND severity=ERROR" --limit=20
   ```

3. **Credit Update Başarılarını İzle:**
   ```bash
   firebase functions:log | grep "Credits updated"
   ```

4. **User Şikayetlerini İzle:**
   - Firebase Analytics'te `payment_failed` event'lerini kontrol et
   - RevenueCat dashboard'da failed transaction'ları kontrol et

---

## 🆘 Acil Durum Çözümleri

### **Kullanıcı Kredisi Gelmedi:**

1. **Manuel Kredi Ekleme:**
   ```bash
   # Firestore console'dan manuel update:
   users/{userId}/profile_info/totalCredit = {eski_deger} + {eklenecek_kredi}
   ```

2. **Manuel Log Ekleme:**
   ```bash
   # purchased_info.logs array'ine ekle:
   "[2025-11-01 12:00:00] 🔧 Manuel kredi eklendi: +100 (Destek ekibi tarafından)"
   ```

3. **RevenueCat'te Transaction Kontrol:**
   - Customer'ı bul
   - Transaction history'yi kontrol et
   - Webhook gönderilmiş mi?

---

## 📈 İyileştirme Önerileri

### **Yakın Vadede:**

1. **Webhook Retry Stratejisi Güçlendir:**
   - Cloud Tasks retry sayısını 5'e çıkar
   - Dead letter queue ekle
   - Failed webhook'lar için alert sistemi

2. **Monitoring Dashboard:**
   - Firebase Analytics'te custom dashboard
   - Başarılı/başarısız purchase oranları
   - Ortalama kredi ekleme süresi

3. **User Feedback:**
   - "Kredi bekleniyorr..." loading state
   - "Kredi başarıyla eklendi!" success message
   - "Kredi eklenemedi, lütfen destek ekibiyle iletişime geçin" error message

### **Uzun Vadede:**

1. **Alternative Payment Webhook:**
   - Stripe webhook'u da ekle
   - Redundancy için çift webhook sistemi

2. **Auto-Recovery System:**
   - Kredisi gelmeyen kullanıcıları otomatik tespit et
   - RevenueCat'ten transaction'ı al
   - Otomatik kredi ekle

3. **A/B Testing:**
   - Kredi ekleme süresini ölç
   - Farklı stratejiler test et
   - En hızlı yöntemi production'a al

---

## 🔗 İlgili Dosyalar

- `functions/src/webhooks/revenuecat.js` - Webhook handler
- `functions/src/payment/paymentHandlers.js` - Payment processing
- `functions/src/payment/creditManager.js` - Credit management
- `lib/app/ui/widgets/total_credit_widget.dart` - Credit UI
- `lib/app/core/services/revenue_cat_service.dart` - RevenueCat integration

---

## 📞 Destek

Sorun devam ederse:

1. Firebase Functions loglarını kaydet
2. Cloud Tasks queue durumunu kaydet
3. Kullanıcı ID ve transaction ID'yi not al
4. RevenueCat dashboard'dan transaction'ı kontrol et
5. Yukarıdaki bilgilerle destek talebi oluştur






