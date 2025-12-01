# PixVerse Dynamic API Key Configuration

## 🎯 Genel Bakış

PixVerse Original API key'i artık Firebase Firestore'dan dinamik olarak çekiliyor. Bu sayede API key değiştirildiğinde uygulama güncellemesi gerekmeden yeni key kullanılabilir.

---

## 🔧 Firebase Ayarları

### 1. Firestore Yapısı

Firebase Firestore'da şu yapıyı oluşturun:

```
Firestore Database
└── keys (collection)
    └── original_pixverse (document)
        └── originalPixverseApiKey: "yeni-api-key-buraya" (string field)
```

### 2. Manuel Kurulum Adımları

#### Firebase Console'dan:
1. Firebase Console'a gidin: https://console.firebase.google.com
2. Projenizi seçin: `disciplify-26970`
3. Sol menüden **Firestore Database** seçin
4. Eğer `keys` collection'ı yoksa:
   - **Start collection** butonuna tıklayın
   - Collection ID: `keys`
   - İlk document ID: `original_pixverse`
   - Field ekleyin:
     - Field name: `originalPixverseApiKey`
     - Type: `string`
     - Value: `sk-YENI-API-KEY-BURAYA`
   - **Save** butonuna tıklayın

5. Eğer `keys` collection'ı varsa:
   - `keys` collection'ına tıklayın
   - **Add document** butonuna tıklayın
   - Document ID: `original_pixverse`
   - Field ekleyin:
     - Field name: `originalPixverseApiKey`
     - Type: `string`
     - Value: `sk-YENI-API-KEY-BURAYA`
   - **Save** butonuna tıklayın

---

## 🚀 Nasıl Çalışır?

### 1. API Key Caching

```dart
// VideoGenerateUsecase içinde
String? _cachedPixverseApiKey;
DateTime? _keyLastFetched;
```

- API key **5 dakika** süreyle cache'de tutulur
- Her API çağrısında Firebase'e gitmez, cache'den kullanır
- 5 dakika geçtikten sonra Firebase'den yeniden çekilir

### 2. Fallback Mekanizması

```dart
Future<String> getPixverseApiKey() async {
  try {
    // 1. Cache kontrol et
    if (_cachedPixverseApiKey != null && 
        _keyLastFetched != null && 
        now.difference(_keyLastFetched!).inMinutes < 5) {
      return _cachedPixverseApiKey!; // Cache'den dön
    }

    // 2. Firebase'den çek
    final docSnapshot = await firestore
        .collection('keys')
        .doc('original_pixverse')
        .get();

    if (docSnapshot.exists) {
      final apiKey = data?['originalPixverseApiKey'] as String?;
      if (apiKey != null && apiKey.isNotEmpty) {
        _cachedPixverseApiKey = apiKey;
        _keyLastFetched = now;
        return apiKey; // Firebase'den dön
      }
    }

    // 3. Fallback: Hardcoded key
    return pixverseOriginalApiKey;
  } catch (e) {
    // 4. Error: Fallback key kullan
    return pixverseOriginalApiKey;
  }
}
```

**Fallback Önceliği:**
1. ✅ **Cache** (5 dakika içinde çekilmişse)
2. ✅ **Firebase** (keys/original_pixverse/originalPixverseApiKey)
3. ⚠️ **Hardcoded** (app_constants.dart içindeki eski key)

---

## 📍 Kullanım Yerleri

API key şu metodlarda kullanılıyor:

### 1. Image Upload
```dart
Future<PixverseOriginalImageUploadResponse?> uploadImageToPixverseOriginal(String imageUrl) async {
  final apiKey = await getPixverseApiKey(); // 🔑 Dynamic
  // ...
  request.headers.addAll({'API-KEY': apiKey});
}
```

### 2. Video Generation
```dart
Future<VideoGenerateResponseModel?> generateVideoPixverseOriginal(...) async {
  final apiKey = await getPixverseApiKey(); // 🔑 Dynamic
  // ...
  headers: {'API-KEY': apiKey}
}
```

### 3. Video Status Check (Once)
```dart
Future<VideoGenerateResponseModel?> checkPixverseOriginalVideoStatusOnce(...) async {
  final apiKey = await getPixverseApiKey(); // 🔑 Dynamic
  // ...
  headers: {'API-KEY': apiKey}
}
```

### 4. Video Status Polling
```dart
Future<VideoGenerateResponseModel?> pollPixverseOriginalVideoStatus(...) async {
  final apiKey = await getPixverseApiKey(); // 🔑 Loop öncesi bir kere al
  // ...
  headers: {'API-KEY': apiKey}
}
```

---

## 🔄 API Key Değiştirme Rehberi

### Senaryo: PixVerse kredileri bittiğinde

1. **Yeni API Key Al:**
   - PixVerse Platform'a giriş yap: https://platform.pixverse.ai
   - Yeni hesap oluştur veya başka bir hesaba geç
   - Settings > API Keys > Create New Key
   - Yeni key'i kopyala: `sk-YENI-KEY-XXXXX`

2. **Firebase'e Ekle:**
   - Firebase Console'a git
   - Firestore Database > `keys` > `original_pixverse`
   - `originalPixverseApiKey` field'ını düzenle
   - Yeni key'i yapıştır: `sk-YENI-KEY-XXXXX`
   - **Save** butonuna tıkla

3. **Uygulama Otomatik Güncellenir:**
   - ❌ **App rebuild gerekmez**
   - ❌ **App restart gerekmez**
   - ✅ **Maksimum 5 dakika içinde** yeni key otomatik kullanılır
   - ✅ Tüm kullanıcılar için geçerli olur

4. **Hızlı Test:**
   - Uygulamada bir template seç
   - Fotoğraf yükle ve video oluştur
   - Logları kontrol et:
     ```
     ✅ PixVerse API key loaded from Firebase: sk-YENI-K...
     ```

---

## 📊 Log Mesajları

### Başarılı Senaryolar

```bash
# Cache'den kullanıldı
🔑 Using cached PixVerse API key

# Firebase'den ilk defa çekildi
🔥 Fetching PixVerse API key from Firebase...
✅ PixVerse API key loaded from Firebase: sk-5e85c41...
```

### Fallback Senaryoları

```bash
# Firebase'de key yoksa
⚠️ Firebase key not found, using fallback hardcoded key

# Error durumunda
❌ Error fetching PixVerse API key from Firebase: [error]
```

---

## 🧪 Test Senaryoları

### Test 1: Firebase'den Çekme
1. Firebase'de key'i ayarla
2. Uygulama loglarını aç
3. Video oluştur
4. Log'da görmeli: `✅ PixVerse API key loaded from Firebase:`

### Test 2: Cache Mekanizması
1. İlk video oluştur (Firebase'den çeker)
2. Hemen ikinci video oluştur (cache'den kullanır)
3. Log'da görmeli: `🔑 Using cached PixVerse API key`

### Test 3: Fallback Mekanizması
1. Firebase'deki key'i sil veya field'ı değiştir
2. Video oluştur
3. Log'da görmeli: `⚠️ Firebase key not found, using fallback`
4. Video yine de oluşturulur (eski hardcoded key ile)

### Test 4: Dinamik Güncelleme
1. Firebase'de key'i değiştir: `sk-OLD-KEY` → `sk-NEW-KEY`
2. 5 dakika bekle (veya uygulamayı restart et)
3. Yeni video oluştur
4. Log'da yeni key görmeli: `sk-NEW-KEY...`

---

## ⚡ Performans

- **Cache Hit:** 0ms (bellekten okuma)
- **Cache Miss:** ~50-200ms (Firebase Firestore read)
- **Fallback:** 0ms (hardcoded sabit)

**Cache Stratejisi:**
- İlk API çağrısı: Firebase'den çek (~100ms)
- Sonraki 5 dakika: Cache'den kullan (0ms)
- 5 dakika sonra: Tekrar Firebase'den çek ve cache'i güncelle

---

## 🔒 Güvenlik

### Firestore Rules

Şu Firestore Security Rules'u öneriyoruz:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // keys collection'ı sadece okuma izni
    match /keys/{document=**} {
      allow read: if request.auth != null;  // Authenticated users can read
      allow write: if false;                // Nobody can write from app
    }
  }
}
```

**Önemli:**
- API keys sadece **Firebase Console'dan** yazılabilir (write: false)
- Authenticated kullanıcılar **okuyabilir** (read: if request.auth != null)
- Public erişim **kapalı** (güvenlik)

---

## 🛠️ Troubleshooting

### Problem 1: "Firebase key not found"

**Sebep:** Firestore'da doğru yolda key yok

**Çözüm:**
```
1. Firebase Console'a git
2. Firestore > keys > original_pixverse kontrol et
3. originalPixverseApiKey field'ının var olduğundan emin ol
4. Field tipi "string" olmalı
5. Value boş olmamalı
```

### Problem 2: "Permission denied"

**Sebep:** Firestore Security Rules okuma izni vermiyor

**Çözüm:**
```javascript
// Firestore Rules'da bu kuralı ekle:
match /keys/{document=**} {
  allow read: if request.auth != null;
}
```

### Problem 3: Cache çok uzun

**Çözüm:**
```dart
// video_generate_usecase.dart içinde cache süresini değiştir:
if (now.difference(_keyLastFetched!).inMinutes < 5) {
//                                                   ^ Bunu 1'e düşür
```

---

## 📁 İlgili Dosyalar

```
lib/
├── app/
│   └── features/
│       └── video_generate/
│           └── data/
│               └── video_generate_usecase.dart  [🔑 getPixverseApiKey()]
└── core/
    └── constants/
        └── app_constants.dart                   [⚠️ Fallback key]
```

---

## 🎉 Avantajlar

✅ **Dinamik Key Yönetimi:** App güncellemesi gerekmeden key değiştirilebilir  
✅ **Hızlı Güncelleme:** Maksimum 5 dakika içinde tüm kullanıcılara yayılır  
✅ **Cache Mekanizması:** Her çağrıda Firebase'e gitmez, performanslı  
✅ **Fallback Güvenliği:** Firebase erişilemezse hardcoded key ile çalışmaya devam eder  
✅ **Merkezi Yönetim:** Tüm API çağrıları tek kaynaktan key alır  
✅ **Log Desteği:** Her adım loglanır, debug kolay  

---

## 📌 Önemli Notlar

⚠️ **Hardcoded key'i silmeyin!** Fallback olarak kullanılıyor.  
⚠️ **Cache süresi 5 dakika** - acil değişiklik gerekirse uygulamayı restart edin.  
⚠️ **Firebase Rules** doğru ayarlanmalı - okuma izni olmalı.  
⚠️ **API key gizli tutulmalı** - Firestore Rules ile korunuyor.

---

**Son Güncelleme:** 2024-11-10  
**Status:** ✅ Production Ready  
**Versiyon:** 1.0.0













