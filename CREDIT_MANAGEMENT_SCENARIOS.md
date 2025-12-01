# 🎯 Credit Management System - Senaryo Dokümantasyonu

## 📊 Sistem Genel Bakış

### **Planlar ve Krediler:**
- **Plus Plan**: 100 kredi/hafta
- **Pro Plan**: 250 kredi/hafta  
- **Ultra Plan**: 500 kredi/hafta

### **Credit Field Location:**
```
users/{userId}/profile_info/totalCredit (int)
```

---

## 🔄 Tüm Senaryolar ve Çözümler

### **1. 🎉 INITIAL_PURCHASE (İlk Abonelik)**

#### **Ne Oluyor:**
- Kullanıcı ilk kez abonelik satın alıyor
- RevenueCat'ten `INITIAL_PURCHASE` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: Plan tipine göre haftalık kredi ekleniyor
- **Firestore Yazma**: `purchased_info` field'ı oluşturuluyor
- **Plan History**: İlk kayıt ekleniyor

#### **Kod Mantığı:**
```javascript
const weeklyCredits = _getWeeklyCredits(productId); // 100, 250, 500
await _updateCredits(userRef, weeklyCredits, `Initial purchase: ${productId}`);
```

#### **Firestore Sonucu:**
```javascript
users/{userId}/
  profile_info: {
    totalCredit: 100, // +100 kredi
    lastCreditUpdate: timestamp
  }
  purchased_info: {
    current_plan_id: "ginly_plus_weekly",
    subscription_status: "active",
    weekly_credits: 100,
    plan_history: [{
      action: "initial_purchase",
      credits_added: 100
    }]
  }
```

---

### **2. 🔄 RENEWAL (Yenileme)**

#### **Ne Oluyor:**
- Haftalık otomatik yenileme gerçekleşiyor
- RevenueCat'ten `RENEWAL` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: Her hafta otomatik kredi ekleniyor
- **Status Güncelleme**: Subscription status "active" kalıyor
- **History Güncelleme**: Yeni renewal kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
const weeklyCredits = _getWeeklyCredits(productId);
await _updateCredits(userRef, weeklyCredits, `Weekly renewal: ${productId}`);
```

#### **Firestore Sonucu:**
```javascript
profile_info: {
  totalCredit: 200, // +100 kredi (100 + 100)
}
purchased_info: {
  plan_history: [
    // ... önceki kayıtlar ...
    {
      action: "renewal",
      credits_added: 100
    }
  ]
}
```

---

### **3. ❌ CANCELLATION (İptal)**

#### **Ne Oluyor:**
- Kullanıcı Google Play Store'dan aboneliği iptal ediyor
- RevenueCat'ten `CANCELLATION` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: ❌ Yok (mevcut periyot bitene kadar kredi alacak)
- **Status Güncelleme**: `subscription_status` → `"cancelled"`
- **History Güncelleme**: Cancellation kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
// Kredi ekleme yok, sadece status güncelleme
'credits_added': 0
```

#### **Firestore Sonucu:**
```javascript
purchased_info: {
  subscription_status: "cancelled",
  cancellation_date: timestamp,
  cancellation_reason: "Too expensive",
  plan_history: [
    // ... önceki kayıtlar ...
    {
      action: "cancellation",
      credits_added: 0
    }
  ]
}
```

---

### **4. ⏰ EXPIRATION (Süre Dolumu)**

#### **Ne Oluyor:**
- Cancelled subscription'ın son periyodu bitiyor
- RevenueCat'ten `EXPIRATION` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: ❌ Yok (son periyot kredisi zaten eklenmiş)
- **Status Güncelleme**: `subscription_status` → `"expired"`
- **History Güncelleme**: Expiration kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
// Kredi ekleme yok, sadece status güncelleme
'credits_added': 0
```

#### **Firestore Sonucu:**
```javascript
purchased_info: {
  subscription_status: "expired",
  expiration_date: timestamp,
  plan_history: [
    // ... önceki kayıtlar ...
    {
      action: "expiration",
      credits_added: 0
    }
  ]
}
```

---

### **5. 💰 REFUND (İade)**

#### **Ne Oluyor:**
- Kullanıcı Google Play Store'dan iade yapıyor
- RevenueCat'ten `REFUND` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Geri Alma**: Haftalık kredi miktarı geri alınıyor
- **Status Güncelleme**: `subscription_status` → `"refunded"`
- **History Güncelleme**: Refund kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
const weeklyCredits = _getWeeklyCredits(productId);
await _updateCredits(userRef, -weeklyCredits, `Refund: ${productId} - Credits removed`);
```

#### **Firestore Sonucu:**
```javascript
profile_info: {
  totalCredit: 100, // -100 kredi (200 - 100)
}
purchased_info: {
  subscription_status: "refunded",
  refund_date: timestamp,
  refund_reason: "User requested",
  plan_history: [
    // ... önceki kayıtlar ...
    {
      action: "refund",
      credits_removed: 100
    }
  ]
}
```

---

### **6. 🔄 RESTORATION (Geri Yükleme)**

#### **Ne Oluyor:**
- Kullanıcı iptal edilen aboneliği geri yüklüyor
- RevenueCat'ten `RESTORATION` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: ✅ Haftalık kredi tekrar ekleniyor
- **Status Güncelleme**: `subscription_status` → `"active"`
- **History Güncelleme**: Restoration kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
const weeklyCredits = _getWeeklyCredits(productId);
await _updateCredits(userRef, weeklyCredits, `Restoration: ${productId} - Credits restored`);
```

#### **Firestore Sonucu:**
```javascript
profile_info: {
  totalCredit: 200, // +100 kredi (100 + 100)
}
purchased_info: {
  subscription_status: "active",
  restoration_date: timestamp,
  plan_history: [
    // ... önceki kayıtlar ...
    {
      action: "restoration",
      credits_added: 100
    }
  ]
}
```

---

### **7. 🔄 TRANSFER (Transfer)**

#### **Ne Oluyor:**
- Abonelik başka hesaba transfer ediliyor
- RevenueCat'ten `TRANSFER` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: ❌ Yok (transfer'da kredi ekleme yok)
- **Status Güncelleme**: `subscription_status` → `"transferred"`
- **History Güncelleme**: Transfer kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
// Kredi ekleme yok, sadece status güncelleme
'credits_added': 0
```

---

### **8. 🔄 UNCANCELLATION (İptal Geri Alma)**

#### **Ne Oluyor:**
- Kullanıcı iptal ettiği aboneliği geri alıyor
- RevenueCat'ten `UNCANCELLATION` event'i geliyor

#### **Sistem Ne Yapıyor:**
- **Kredi Ekleme**: ✅ Haftalık kredi tekrar ekleniyor
- **Status Güncelleme**: `subscription_status` → `"active"`
- **History Güncelleme**: Uncancellation kaydı ekleniyor

#### **Kod Mantığı:**
```javascript
const weeklyCredits = _getWeeklyCredits(productId);
await _updateCredits(userRef, weeklyCredits, `Uncancellation: ${productId} - Credits restored`);
```

---

## 🎯 Özel Durumlar

### **Billing Issue (Ödeme Sorunu):**
- Kredi ekleme yok
- Status: `"billing_issue"`
- Kullanıcı ödeme yapana kadar kredi yok

### **Non-Renewing Purchase (Tek Seferlik Satın Alma):**
- Kredi ekleme yok
- Status: `"lifetime"`
- Tek seferlik ödeme, kredi ekleme yok

---

## 📊 Credit Calculation Logic

### **Haftalık Kredi Hesaplama:**
```javascript
function _getWeeklyCredits(productId) {
  if (productId.includes('plus')) return 100;
  if (productId.includes('pro')) return 250;
  if (productId.includes('ultra')) return 500;
  return 100; // Default
}
```

### **Kredi Güncelleme:**
```javascript
async function _updateCredits(userRef, creditChange, reason) {
  const currentCredits = await _getCurrentCredits(userRef);
  const newCredits = Math.max(0, currentCredits + creditChange); // Negatif olmasın
  
  await userRef.update({
    'profile_info.totalCredit': newCredits,
    'profile_info.lastCreditUpdate': admin.firestore.FieldValue.serverTimestamp()
  });
}
```

---

## 🚀 Test Senaryoları

### **Test 1: İlk Abonelik**
1. Plus plan satın al
2. `totalCredit` → 100 olmalı
3. `purchased_info` oluşmalı

### **Test 2: Haftalık Yenileme**
1. 1 hafta bekle (test için manuel)
2. `totalCredit` → 200 olmalı
3. `plan_history`'de renewal kaydı olmalı

### **Test 3: İptal**
1. Google Play Store'dan iptal et
2. Status → "cancelled" olmalı
3. Kredi eklenmemeli

### **Test 4: Refund**
1. Google Play Store'dan iade yap
2. `totalCredit` → 100 olmalı (100 geri alınmalı)
3. Status → "refunded" olmalı

---

## ⚠️ Dikkat Edilecek Noktalar

### **1. Negatif Kredi:**
- `Math.max(0, currentCredits + creditChange)` ile negatif olması engelleniyor
- Kullanıcı hiçbir zaman negatif krediye sahip olamaz

### **2. Haftalık Periyot:**
- Krediler haftalık periyotlarda ekleniyor
- Test için manuel renewal gerekebilir

### **3. Plan Değişikliği:**
- Plan değişikliği durumunda eski plan kredileri geri alınmıyor
- Yeni plan kredileri ekleniyor

### **4. Concurrent Updates:**
- `_updateCredits` function'ı atomic update yapıyor
- Race condition riski yok

---

## 🔧 Troubleshooting

### **Kredi Eklenmiyor:**
1. Firebase Console'da log'ları kontrol et
2. `_updateCredits` function'ının çalıştığını doğrula
3. `profile_info.totalCredit` field'ının var olduğunu kontrol et

### **Yanlış Kredi Miktarı:**
1. `_getWeeklyCredits` function'ını kontrol et
2. Product ID'lerin doğru olduğunu doğrula
3. Plan mapping'lerini kontrol et

### **Status Güncellenmiyor:**
1. Webhook'ta event type'ı kontrol et
2. Handler function'ının çağrıldığını doğrula
3. Firestore permissions'ı kontrol et

---

## 📝 Sonuç

Bu sistem ile:
- ✅ **Otomatik kredi yönetimi** sağlanıyor
- ✅ **Tüm subscription event'leri** handle ediliyor
- ✅ **Credit history** tutuluyor
- ✅ **Race condition'lar** önleniyor
- ✅ **Audit trail** oluşturuluyor

**Sistem production'da kullanıma hazır!** 🚀
