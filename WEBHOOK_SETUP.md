# Pollo.ai Webhook Entegrasyonu Kurulum Rehberi ✅

Bu rehber, Pollo.ai'ın webhook sistemini kullanarak video generation durumunu takip etmeyi açıklar.

## 🎉 Kurulum Tamamlandı!

**Tüm adımlar başarıyla tamamlandı!** Pollo.ai webhook entegrasyonu artık aktif ve çalışıyor.

### 🧹 Temizlik Yapıldı:

- ✅ `CheckPolloStatusEvent` kaldırıldı
- ✅ `_startPolloStatusCheck()` method'u kaldırıldı
- ✅ `_stopPolloStatusCheck()` method'u kaldırıldı
- ✅ `checkPolloStatusStatus` state'i kaldırıldı
- ✅ `checkPolloStatus()` usecase method'u kaldırıldı
- ✅ Polling timer'ları kaldırıldı
- ✅ Sürekli API check'i kaldırıldı

### 🆕 Yeni Özellikler Eklendi:

- ✅ `PolloWebhookResponseModel` oluşturuldu
- ✅ Webhook'dan gelen video bilgileri Firebase'e kaydediliyor
- ✅ Video URL'i ve metadata'sı users collection'a kaydediliyor
- ✅ Gerçek Pollo.ai webhook formatı destekleniyor

## 🎯 Ne Değişti?

**Önceki Sistem:**
- Video generation başlatıldıktan sonra her 5 saniyede bir API'ye istek atılıyordu
- Sürekli API çağrıları yapılıyordu
- Gereksiz network trafiği oluşuyordu
- `CheckPolloStatusEvent` ve polling timer'ları kullanılıyordu

**Yeni Sistem:**
- Pollo.ai webhook kullanılıyor
- Video hazır olduğunda otomatik bildirim geliyor
- API çağrıları sadece gerektiğinde yapılıyor
- Daha verimli ve hızlı
- **✅ Eski polling sistemi tamamen kaldırıldı!**

## 🚀 Kurulum Adımları

### 1. Pollo.ai Webhook Secret'ı Alın ✅

1. [Pollo.ai Webhook Sayfası](https://docs.pollo.ai/webhooks)na gidin
2. Yeni bir webhook key oluşturun
3. Secret'ı kopyalayın ve güvenli bir yerde saklayın

**✅ Zaten alındı!** Webhook Secret: `6pwodEjgO3hu1snKajdPgu1sK8EJgEkuVgLJy3zsq5sn`

### 2. Firebase Functions'ı Deploy Edin ✅

```bash
# Functions klasörüne gidin
cd functions

# Dependencies'leri yükleyin
npm install

# Webhook secret'ı set edin
node ../scripts/set_webhook_secret.js

# Functions'ı deploy edin
firebase deploy --only functions
```

**✅ Zaten deploy edildi!** 
- Webhook URL: `https://us-central1-disciplify-26970.cloudfunctions.net/polloWebhook`
- Functions başarıyla deploy edildi ve test edildi

### 3. Webhook URL'ini Güncelleyin

`lib/core/constants/webhook_constants.dart` dosyasında:

```dart
static const String polloWebhookUrl = 'https://us-central1-disciplify-26970.cloudfunctions.net/polloWebhook';
```

**✅ Zaten güncellendi!** Firebase project ID: `disciplify-26970`

### 4. Flutter App'i Yeniden Build Edin ✅

```bash
flutter clean
flutter pub get
flutter build
```

**✅ Zaten build edildi!** App başarıyla build edildi ve webhook entegrasyonu hazır.

## 🔧 Konfigürasyon

### Webhook Secret Set Etme

```bash
# Manuel olarak set etmek için:
firebase functions:config:set pollo.webhook_secret="YOUR_SECRET_HERE"

# Mevcut config'i görmek için:
firebase functions:config:get
```

### Environment Variables

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Production
flutter run --dart-define=ENVIRONMENT=prod
```

## 📱 Kullanım

### Video Generation Başlatma

```dart
// Video generation başlat
final result = await generateUseCase.videoGeneratePixversePollo(requestModel);

if (result?.id != null) {
  // Task Firestore'a kaydediliyor
  await _saveTaskToFirestore(result.id!, 'processing');
  
  // Webhook ile task'ı dinlemeye başla
  _startWebhookListening(result.id!);
}
```

### Webhook Dinleme

```dart
// Webhook service otomatik olarak:
// 1. Task durumunu dinler
// 2. Video hazır olduğunda webhook data'sını parse eder
// 3. Video URL'i ve metadata'sı Firebase'e kaydeder
// 4. Kütüphaneyi günceller
// 5. Kullanıcıya bildirim gönderir
```

### Video Bilgileri Firebase'e Kaydediliyor

```dart
// Webhook'dan gelen response:
{
  "status": "succeed",
  "taskId": "cmecoyuz60a3w84llxf740rlr",
  "generations": [{
    "id": "cmecoyuzh0a3x84llwy4q1lsf",
    "url": "https://videocdn.pollo.ai/web-cdn/video/mp4/...",
    "status": "succeed",
    "mediaType": "video",
    "createdDate": "2025-08-15T10:34:54.000Z",
    "updatedDate": "2025-08-15T10:35:26.000Z"
  }]
}

// Bu bilgiler otomatik olarak Firebase'e kaydediliyor:
// - users/{userId}/generated_videos/{taskId}
// - Video URL'i, metadata'sı ve webhook data'sı

## 🔍 Test Etme

### 1. Webhook Test ✅

Webhook başarıyla test edildi:

```bash
# Test script'ini çalıştır
node scripts/test_webhook.js

# Manuel test
curl -X POST https://us-central1-disciplify-26970.cloudfunctions.net/polloWebhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Id: test-id" \
  -H "X-Webhook-Timestamp: $(date +%s)" \
  -H "X-Webhook-Signature: COMPUTED_SIGNATURE" \
  -d '{"taskId": "test-task", "status": "succeed"}'
```

**✅ Test Sonucu:** Webhook endpoint çalışıyor ve "OK" response'u alıyor!

**✅ Video Bilgileri Test Edildi:**
- Gerçek Pollo.ai webhook formatı test edildi
- Video URL'i ve metadata'sı başarıyla parse ediliyor
- Firebase'e kaydetme işlemi hazır

### 2. Local Testing

```bash
# Firebase emulator'ı başlat
firebase emulators:start --only functions

# Webhook URL'i güncelle (local)
static const String localWebhookUrl = 'http://localhost:5001/disciplify-26970/us-central1/polloWebhook';
```

### 2. Production Testing

1. Video generation başlat
2. Firebase Functions loglarını kontrol et
3. Webhook'ların geldiğini doğrula

## 📊 Monitoring

### Firebase Functions Logs

```bash
firebase functions:log --only polloWebhook
```

### Firestore Collections

- `pollo_tasks`: Task durumları
- `users`: Kullanıcı bilgileri ve FCM token'ları

## 🚨 Troubleshooting

### Webhook Gelmiyor

1. Secret doğru set edildi mi?
2. Functions deploy edildi mi?
3. URL doğru mu?
4. CORS ayarları doğru mu?

### Signature Verification Hatası

1. Secret Base64 encoded mu?
2. Timestamp formatı doğru mu?
3. Request body tam mı?

### FCM Notification Gelmiyor

1. Kullanıcının FCM token'ı var mı?
2. Firebase Messaging aktif mi?
3. App background'da mı?

## 📚 Kaynaklar

- [Pollo.ai Webhook Dokümantasyonu](https://docs.pollo.ai/webhooks)
- [Firebase Functions Dokümantasyonu](https://firebase.google.com/docs/functions)
- [Firebase Messaging](https://firebase.google.com/docs/cloud-messaging)

## 🤝 Destek

Herhangi bir sorun yaşarsanız:

1. Firebase Functions loglarını kontrol edin
2. Webhook secret'ın doğru set edildiğinden emin olun
3. URL'lerin doğru olduğunu kontrol edin
4. CORS ayarlarını doğrulayın
