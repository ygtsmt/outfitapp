# 🚀 Pixverse Original API - Deployment Guide

## ✅ Tamamlanan İşlemler

### 1. Model Dosyaları ✓
- ✅ `pixverse_original_image_upload_model.dart`
- ✅ `pixverse_original_video_generate_model.dart`
- ✅ `pixverse_original_video_result_model.dart`
- ✅ `video_generate_response_model.dart` (template_id, video_id, traceId eklendi)

### 2. Video Generate Usecase ✓
- ✅ `uploadImageToPixverseOriginal()` - Image upload
- ✅ `generateVideoPixverseOriginal()` - Video generation
- ✅ `checkPixverseOriginalVideoStatusOnce()` - Tek seferlik status check (app resume için)
- ✅ `pollPixverseOriginalVideoStatus()` - Full polling (ihtiyaç halinde)

### 3. Template Generate Bloc ✓
- ✅ `aiModel == 'originalPixverse45'` kontrolü
- ✅ Background polling kaldırıldı
- ✅ Firebase Functions'a güveniyor

### 4. Library Bloc ✓
- ✅ `CheckPendingPixverseOriginalVideosEvent` eklendi
- ✅ App resume check handler eklendi
- ✅ `_updateVideoInFirebase()` helper method

### 5. Library Screen ✓
- ✅ `WidgetsBindingObserver` eklendi
- ✅ `didChangeAppLifecycleState()` - App resume trigger
- ✅ `initState()` - İlk check

### 6. Firebase Functions ✓
- ✅ `checkPendingPixverseVideos` scheduled function (her 30 saniye)
- ✅ Tüm kullanıcıların pending videoları check ediliyor
- ✅ Otomatik Firebase update

---

## ⚙️ Deployment Adımları

### 1️⃣ Firebase Config - Pixverse API Key Ekle

```bash
cd /Users/yigitsametolmez/ginly/functions

# API key'i config'e ekle
firebase functions:config:set pixverse.apikey="sk-5e85c415c778470cde912f0f684526f6"

# Kontrol et
firebase functions:config:get
```

**Beklenen Output:**
```json
{
  "pixverse": {
    "apikey": "sk-5e85c415c778470cde912f0f684526f6"
  },
  "pollo": {
    "webhook_secret": "..."
  }
}
```

---

### 2️⃣ NPM Packages Install

```bash
cd /Users/yigitsametolmez/ginly/functions

# Axios'u kur
npm install

# Package kontrolü
npm list axios
```

**Beklenen Output:**
```
functions@1.0.0
└── axios@1.6.0
```

---

### 3️⃣ Firebase Functions Deploy

```bash
# Sadece yeni function'ı deploy et
firebase deploy --only functions:checkPendingPixverseVideos

# VEYA tüm functions'ları deploy et
firebase deploy --only functions
```

**Beklenen Output:**
```
✔  Deploy complete!

Functions:
  - checkPendingPixverseVideos(us-central1)
    https://us-central1-disciplify-26970.cloudfunctions.net/checkPendingPixverseVideos
```

---

### 4️⃣ Test - App Resume Check

Flutter uygulamasını test et:

```
Test Adımları:
1. ✅ App'i aç
2. ✅ originalPixverse45 template seç
3. ✅ Video generate et
4. ✅ Library'ye git → "Processing..." görünür
5. ✅ App'i kapat (force close)
6. ⏰ 1-2 dakika bekle (Firebase Functions polling yapıyor)
7. ✅ App'i tekrar aç
8. ✅ Library'ye git
9. 🎯 CheckPendingPixverseOriginalVideosEvent tetiklenir
10. ✅ 2-3 saniye içinde video güncellenir (succeeded/failed)
11. ✅ Video izlenebilir! 🎉
```

---

## 📊 Sistem Akışı

### Senaryo 1: App Açık
```
User → Generate Video
        ↓
Firebase'e Save (processing)
        ↓
User → Library'ye gider
        ↓
[30 saniye içinde]
        ↓
Firebase Functions → Polling (her 30 saniye)
        ↓
Video Hazır! → Firebase Update
        ↓
UI Otomatik Refresh → Video Görünür ✅
```

### Senaryo 2: App Kapalı
```
User → Generate Video
        ↓
Firebase'e Save (processing)
        ↓
User → App'i Kapatır ❌
        ↓
[Background]
Firebase Functions → Polling (her 30 saniye)
        ↓
Video Hazır! → Firebase Update ✅
        ↓
User → App'i Açar
        ↓
Library → CheckPendingPixverseOriginalVideosEvent
        ↓
Status Check → Video Zaten Hazır!
        ↓
UI Refresh → Video Görünür ✅
```

---

## 🔥 Firebase Functions Detayları

### Scheduled Function: `checkPendingPixverseVideos`

**Çalışma Sıklığı:** Her 30 saniye

**Yapılan İşler:**
1. Tüm kullanıcıları tara
2. `model == 'pixverse-original-4.5'` && `status == 'processing'` olan videoları bul
3. Her video için Pixverse API'ye status check at
4. Tamamlanan/başarısız videoları Firebase'de güncelle

**Log Output (Console):**
```
🔍 Checking pending Pixverse Original videos...
📋 User abc123: Found 2 pending videos
🔍 Checking video 364487838592718 for user abc123
✅ Video 364487838592718 completed! URL: https://...
💾 Video 364487838592718 updated in Firebase for user abc123
✅ Polling completed! Pending: 2, Checked: 2, Completed: 1
```

---

## 🎯 App Resume Check

### Event: `CheckPendingPixverseOriginalVideosEvent`

**Tetiklenme Zamanları:**
1. Library screen ilk açılışta (`initState`)
2. App foreground'a geldiğinde (`didChangeAppLifecycleState`)

**Yapılan İşler:**
1. Kullanıcının pending videolarını kontrol et
2. Her biri için **TEK SEFERLİK** Pixverse API check
3. Tamamlanmış videoları Firebase'de güncelle
4. UI refresh

**Neden İkisi Birlikte?**
- ✅ Firebase Functions: Otomatik, sürekli, güvenilir
- ✅ App Resume Check: Hızlı response, kullanıcı deneyimi

---

## 💰 Maliyet Analizi

### Firebase Functions (Scheduled)

```
Scenario: 100 active user, her biri 1 video/gün oluşturuyor

Polling Frequency: Her 30 saniye
Video Processing Time: Ortalama 1 dakika

Calculation:
- 100 video/gün
- Her video 2 polling cycle (1 dakika / 30 saniye)
- Günlük invocation: 100 video × 2 = 200
- Aylık invocation: 200 × 30 = 6,000

Firebase Pricing:
- İlk 2 million invocation: ÜCRETSİZ
- 6,000 << 2,000,000 ✅

Monthly Cost: $0 (ücretsiz limit içinde!)
```

---

## 🐛 Troubleshooting

### 1. Function Deploy Edilemiyorsa

```bash
# Firebase login kontrol
firebase login

# Project kontrol
firebase use

# Deploy with verbose
firebase deploy --only functions --debug
```

### 2. Config Görünmüyorsa

```bash
# Local'de test için .runtimeconfig.json oluştur
cd functions
echo '{
  "pixverse": {
    "apikey": "sk-5e85c415c778470cde912f0f684526f6"
  }
}' > .runtimeconfig.json

# Emulator ile test
firebase emulators:start --only functions
```

### 3. Polling Çalışmıyorsa

```bash
# Function logs'u izle
firebase functions:log --only checkPendingPixverseVideos

# Veya Firebase Console'dan izle
# https://console.firebase.google.com/project/disciplify-26970/functions
```

### 4. Video Update Edilmiyorsa

**Kontrol Et:**
- ✅ Video Firebase'de var mı? (`userGeneratedVideos`)
- ✅ `traceId` kaydedilmiş mi?
- ✅ `model` doğru mu? (`pixverse-original-4.5`)
- ✅ `status` processing mi?

**Firebase Console'dan Manuel Kontrol:**
```javascript
// Firestore'da:
users/YOUR_USER_ID/

userGeneratedVideos: [
  {
    id: "364487838592718",
    model: "pixverse-original-4.5",
    status: "processing", // ✅ Bu olmalı
    traceId: "uuid-here",
    templateId: 302325299692608,
    videoId: 364487838592718
  }
]
```

---

## 📱 Test Checklist

### Pre-Deployment Test
- [ ] Model dosyaları build edildi mi?
- [ ] Functions package.json'da axios var mı?
- [ ] Firebase config set edildi mi?

### Post-Deployment Test
- [ ] Function deploy edildi mi?
- [ ] Function scheduler çalışıyor mu? (Firebase Console'dan kontrol)
- [ ] Video generate edildi mi?
- [ ] Firebase'de video kaydedildi mi?
- [ ] 30-60 saniye içinde video tamamlandı mı?
- [ ] App kapatıp açtığında video güncellenmiş mi?

---

## 🎉 Success Indicators

### Firebase Functions Logs'da:
```
✅ "Checking pending Pixverse Original videos..."
✅ "User abc123: Found 1 pending videos"
✅ "Video 364487838592718 completed!"
✅ "Video updated in Firebase"
```

### Flutter Console Logs'da:
```
✅ "Video saved! Firebase Functions will check status every 30 seconds"
✅ "Checking pending Pixverse Original videos..."
✅ "Video 364487838592718 completed! Updating Firebase..."
```

### Library UI'da:
```
Before:
┌─────────────────────────────┐
│  🎬 Template Name           │
│  ⏳ Processing...           │
└─────────────────────────────┘

After (30-60 saniye içinde):
┌─────────────────────────────┐
│  ▶️ [Video Thumbnail]       │
│  🎬 Template Name           │
│  ✅ Completed               │
│  [Play] [Download] [Share]  │
└─────────────────────────────┘
```

---

## 🚀 Quick Start

```bash
# 1. Config set et
firebase functions:config:set pixverse.apikey="sk-5e85c415c778470cde912f0f684526f6"

# 2. Functions klasörüne git ve install
cd functions
npm install

# 3. Deploy
firebase deploy --only functions:checkPendingPixverseVideos

# 4. Test et!
```

---

## 📝 Next Steps

Deployment sonrası:
1. Test video oluştur
2. Firebase Console'dan function logs'u izle
3. 30 saniye bekle
4. Video'nun tamamlandığını gör! 🎉

**Status:** Ready to deploy! 🚀



