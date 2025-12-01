# Pixverse Original API - Video Generation Flow

## 📋 Genel Bakış

Bu doküman, `aiModel: "originalPixverse45"` olan template'lerin video üretim akışını detaylı olarak açıklar.

---

## 🎬 Tam Akış Senaryosu

### **SENARYO: Kullanıcı "Dance Challenge" Template'i ile Video Oluşturuyor**

---

### 1️⃣ **Kullanıcı Template Seçimi**

**Konum:** Template Listesi Ekranı

```
Kullanıcı Actions:
├─ Template listesini görüntüler
├─ "Dance Challenge" template'ini seçer
│  └─ Firebase'den template bilgileri:
│      ├─ id: "302325299692608"
│      ├─ aiModel: "originalPixverse45"
│      ├─ prompt: "A person dancing energetically"
│      ├─ quality: "540p"
│      ├─ duration: 5
│      └─ requiredCredit: 10
└─ Template detay ekranına yönlendirilir
```

**Dosya:** `lib/app/features/template/ui/screens/templates_screen.dart`

---

### 2️⃣ **Fotoğraf Yükleme**

**Konum:** Generate Template Video Screen

```
Kullanıcı Actions:
├─ "Upload Photo" butonuna tıklar
├─ Galeriden fotoğraf seçer
│  └─ Image picker açılır
│      └─ Fotoğraf seçimi: "user_photo.jpg"
├─ Crop ekranı açılır (optional)
│  └─ Kullanıcı fotoğrafı kırpar
└─ Fotoğraf preview'da gösterilir
```

**Dosya:** `lib/app/features/template_generate/ui/screens/generate_template_video_screen.dart`

**State Updates:**
```dart
_imageFile3 = File(croppedPath)
setState(() => ...) // UI güncellenir
```

---

### 3️⃣ **Video Generation Başlatma**

**Konum:** Generate Button Tıklanıyor

```
Kullanıcı Actions:
└─ "Generate" butonuna tıklar
    ├─ Credit kontrolü yapılır
    │  ├─ Gerekli: 10 credit
    │  ├─ Mevcut: 25 credit
    │  └─ ✅ Yeterli credit var
    └─ UploadPhotoForTemplateEvent tetiklenir
```

**Dosya:** `lib/app/features/template_generate/ui/screens/generate_template_video_screen.dart`

**Event Dispatch:**
```dart
getIt<TemplateGenerateBloc>().add(
  UploadPhotoForTemplateEvent(
    imageFile: _imageFile3!,
    prompt: "A person dancing energetically",
    negativePrompt: null,
    length: 5,
    aspectRatio: "1:1",
    seed: 12345,
    resolution: "540p",
    style: "auto",
    templateName: "Dance Challenge",
    aiModel: "originalPixverse45", // 🔥 Önemli!
    effect: null,
    templateId: 302325299692608, // 🔥 Pixverse Template ID
  ),
);
```

---

### 4️⃣ **Template Generate Bloc - Event İşleme**

**Dosya:** `lib/app/features/template_generate/bloc/template_generate_bloc.dart`

#### **4.1 - State: Upload Processing**
```
Bloc State Updates:
├─ uploadStatus: EventStatus.processing
├─ isGenerationStarted: true
└─ UI: Loading indicator gösterilir
```

#### **4.2 - Firebase Storage Upload**
```dart
// templateUseCase.uploadUserImage(event.imageFile)

Firebase Actions:
├─ Dosya yolu oluştur: "template_uploads/{userId}/{timestamp}.jpg"
├─ Fotoğrafı byte array'e çevir
├─ Firebase Storage'a yükle
│  ├─ Metadata set et (public, image/jpeg)
│  └─ Upload tamamlandı
└─ Download URL al
    └─ imageUrl = "https://firebasestorage.googleapis.com/.../12345.jpg"
```

**Log Output:**
```
✅ Image uploaded to Firebase: https://firebasestorage.googleapis.com/.../12345.jpg
```

#### **4.3 - AI Model Kontrolü**
```dart
if (event.aiModel == 'originalPixverse45') {
  log('Using Pixverse Original API for template generation');
  // 🎯 Bu dalga girecek!
}
```

---

### 5️⃣ **Pixverse Original API - Image Upload**

**Dosya:** `lib/app/features/video_generate/data/video_generate_usecase.dart`
**Method:** `uploadImageToPixverseOriginal()`

#### **5.1 - Trace ID Oluşturma**
```dart
final traceId = const Uuid().v4();
// traceId = "a7b3c4d5-e6f7-8901-2345-6789abcdef01"
```

#### **5.2 - API Request**
```http
POST https://app-api.pixverse.ai/openapi/v2/image/upload
Headers:
  API-KEY: sk-5e85c415c778470cde912f0f684526f6
  Ai-trace-id: a7b3c4d5-e6f7-8901-2345-6789abcdef01
Body (multipart/form-data):
  image_url: https://firebasestorage.googleapis.com/.../12345.jpg
```

#### **5.3 - API Response**
```json
{
  "ErrCode": 0,
  "ErrMsg": "success",
  "Resp": {
    "img_id": 987654321,
    "img_url": "https://media.pixverse.ai/openapi/image123.jpg"
  }
}
```

**Log Output:**
```
✅ Pixverse Original image uploaded successfully: 987654321
```

**Result:**
```dart
final imgId = 987654321; // 🎯 Bu ID video generation'da kullanılacak
```

---

### 6️⃣ **Pixverse Original API - Video Generation**

**Method:** `generateVideoPixverseOriginal()`

#### **6.1 - Credit Kontrolü & Düşme**
```dart
Credit Flow:
├─ AppBloc'tan credit requirements al
│  └─ videoTemplateRequiredCredits = 10
├─ Firebase'den user credits oku
│  ├─ Mevcut: 25 credit
│  └─ Yeterli mi? ✅ Evet
├─ Credit düş
│  ├─ Yeni değer: 25 - 10 = 15
│  └─ Firebase'e kaydet: profile_info.totalCredit = 15
└─ Log: "✅ Pixverse Original credits deducted: 10, Remaining: 15"
```

#### **6.2 - Yeni Trace ID**
```dart
final traceId = const Uuid().v4();
// traceId = "b8c9d0e1-f2a3-4567-8901-23456789beef"
```

#### **6.3 - API Request**
```http
POST https://app-api.pixverse.ai/openapi/v2/video/img/generate
Headers:
  API-KEY: sk-5e85c415c778470cde912f0f684526f6
  Ai-trace-id: b8c9d0e1-f2a3-4567-8901-23456789beef
  Content-Type: application/json
Body:
{
  "duration": 5,
  "img_id": 987654321,
  "model": "v4.5",
  "motion_mode": "normal",
  "prompt": "A person dancing energetically",
  "quality": "540p",
  "template_id": 302325299692608,
  "seed": 12345
}
```

#### **6.4 - API Response**
```json
{
  "ErrCode": 0,
  "ErrMsg": "success",
  "Resp": {
    "id": 555666777
  }
}
```

**Log Output:**
```
✅ Pixverse Original video generation started: 555666777
```

#### **6.5 - VideoGenerateResponseModel Oluşturma**
```dart
result = VideoGenerateResponseModel(
  id: "555666777",
  model: "pixverse-original-4.5",
  version: "4.5",
  status: "processing", // 🔥 İlk status
  createdAt: "2025-10-10T14:30:00Z",
  fromTemplate: true,
  traceId: "b8c9d0e1-f2a3-4567-8901-23456789beef", // 🔥 Polling için
  input: Input(
    prompt: "A person dancing energetically",
    quality: "540p",
    duration: 5,
    seed: 12345,
  ),
);
```

---

### 7️⃣ **Firebase'e İlk Kayıt**

**Method:** `templateUseCase.addUserVideo(result)`

#### **7.1 - Firebase Write**
```
Firebase Update:
└─ Collection: users/{userId}
    └─ Field: userGeneratedVideos (array)
        └─ ArrayUnion: [
            {
              "id": "555666777",
              "model": "pixverse-original-4.5",
              "status": "processing", // 🔄 İşleniyor
              "output": null, // ❌ Henüz yok
              "createdAt": "2025-10-10T14:30:00Z",
              "fromTemplate": true,
              "templateName": "Dance Challenge",
              "traceId": "b8c9d0e1-f2a3-4567-8901-23456789beef",
              "input": { ... }
            }
        ]
```

**Log Output:**
```
✅ Video saved to Firebase with processing status: 555666777
```

#### **7.2 - UI Update**
```
User Experience:
├─ generateStatus: EventStatus.success
├─ isGenerationStarted: false
├─ Loading indicator kaybolur
└─ Success snackbar: "Video generation başlatıldı! Library'den takip edebilirsiniz"
```

**Library Screen:**
```
Video Card Gösterimi:
┌─────────────────────────────┐
│  🎬 Dance Challenge         │
│  ⏳ Processing...           │
│  ━━━━━━━━━━━━━━━━━━━━━━━  │
│  Started: 2 seconds ago     │
└─────────────────────────────┘
```

---

### 8️⃣ **Background Polling Başlatma**

**Method:** `_pollAndUpdateVideo(videoId, traceId)`

```
Background Thread:
└─ Future.delayed() ile async çalışır
    └─ UI thread'i bloklamaz
```

**Log Output:**
```
🔄 Starting background polling for video: 555666777
```

---

### 9️⃣ **Polling Loop (Her 5 Saniyede Bir)**

**Method:** `pollPixverseOriginalVideoStatus()`

#### **Attempt 1 (0 saniye sonra)**
```http
GET https://app-api.pixverse.ai/openapi/v2/video/result/555666777
Headers:
  API-KEY: sk-5e85c415c778470cde912f0f684526f6
  Ai-trace-id: b8c9d0e1-f2a3-4567-8901-23456789beef
```

**Response:**
```json
{
  "ErrCode": 0,
  "ErrMsg": "success",
  "Resp": {
    "id": 555666777,
    "status": 0, // 🔄 Processing
    "create_time": "2025-10-10T14:30:00Z",
    "modify_time": "2025-10-10T14:30:05Z",
    "prompt": "A person dancing energetically",
    "url": null, // ❌ Henüz yok
    "outputWidth": 540,
    "outputHeight": 960
  }
}
```

**Log Output:**
```
🔄 Polling Pixverse Original video status (Attempt 1/60): 555666777
⏳ Video still processing... (status: 0)
⏰ Waiting 5 seconds...
```

---

#### **Attempt 2 (5 saniye sonra)**
```
Request: GET .../video/result/555666777
Status: 0 (processing)
Log: ⏳ Video still processing... (status: 0)
Action: await Future.delayed(5 seconds)
```

---

#### **Attempt 3 (10 saniye sonra)**
```
Request: GET .../video/result/555666777
Status: 0 (processing)
Log: ⏳ Video still processing... (status: 0)
Action: await Future.delayed(5 seconds)
```

---

#### **... (Polling devam ediyor) ...**

---

#### **Attempt 8 (35 saniye sonra) - ✅ VIDEO HAZIR!**

```http
GET https://app-api.pixverse.ai/openapi/v2/video/result/555666777
```

**Response:**
```json
{
  "ErrCode": 0,
  "ErrMsg": "success",
  "Resp": {
    "id": 555666777,
    "status": 1, // ✅ Succeeded!
    "create_time": "2025-10-10T14:30:00Z",
    "modify_time": "2025-10-10T14:30:35Z",
    "prompt": "A person dancing energetically",
    "url": "https://media.pixverse.ai/videos/dance_555666777.mp4", // ✅ Video URL!
    "outputWidth": 540,
    "outputHeight": 960,
    "seed": 12345,
    "size": 2457600
  }
}
```

**Log Output:**
```
🔄 Polling Pixverse Original video status (Attempt 8/60): 555666777
✅ Pixverse Original video completed: https://media.pixverse.ai/videos/dance_555666777.mp4
```

---

### 🔟 **Firebase Güncelleme (Final)**

**Method:** `templateUseCase.addUserVideo(finalResult)`

#### **10.1 - Updated VideoGenerateResponseModel**
```dart
finalResult = VideoGenerateResponseModel(
  id: "555666777",
  model: "pixverse-original-4.5",
  version: "4.5",
  status: "succeeded", // ✅ Güncellendi!
  output: "https://media.pixverse.ai/videos/dance_555666777.mp4", // ✅ URL eklendi!
  createdAt: "2025-10-10T14:30:00Z",
  completedAt: "2025-10-10T14:30:35Z", // ✅ Tamamlanma zamanı
  fromTemplate: true,
  templateName: "Dance Challenge",
  traceId: "b8c9d0e1-f2a3-4567-8901-23456789beef",
  input: { ... }
);
```

#### **10.2 - Firebase Update**
```
Firebase Transaction:
├─ userGeneratedVideos array'inden eski entry'yi bul
│  └─ id: "555666777" olan
├─ Eski entry'yi kaldır
└─ Yeni entry'yi ekle (güncellenmiş haliyle)
    └─ status: "succeeded"
    └─ output: "https://media.pixverse.ai/.../dance_555666777.mp4"
    └─ completedAt: "2025-10-10T14:30:35Z"
```

**Log Output:**
```
✅ Polling complete for video: 555666777, Status: succeeded
✅ Video updated in Firebase: 555666777
```

---

### 1️⃣1️⃣ **UI Otomatik Güncelleme**

**Dosya:** `lib/app/features/library/bloc/library_bloc.dart`

#### **11.1 - Firestore Listener Tetiklenir**
```dart
StreamSubscription:
└─ firestore
    .collection('users')
    .doc(userId)
    .snapshots()
    .listen((snapshot) {
      // userGeneratedVideos değişti!
      // Yeni state emit et
    });
```

#### **11.2 - Library Screen Güncellenir**
```
Video Card Gösterimi (Before):
┌─────────────────────────────┐
│  🎬 Dance Challenge         │
│  ⏳ Processing...           │
│  ━━━━━━━━━━━━━━━━━━━━━━━  │
│  Started: 35 seconds ago    │
└─────────────────────────────┘

Video Card Gösterimi (After):
┌─────────────────────────────┐
│  ▶️ [Video Thumbnail]       │
│  🎬 Dance Challenge         │
│  ✅ Completed               │
│  ⏱️ 35 seconds              │
│  [Play] [Download] [Share]  │
└─────────────────────────────┘
```

#### **11.3 - Kullanıcı Video İzleyebilir**
```
User Actions:
├─ ▶️ Play butonuna tıklar
└─ Video player açılır
    └─ URL: https://media.pixverse.ai/videos/dance_555666777.mp4
    └─ Video oynatılır 🎉
```

---

## 🔄 Alternatif Senaryolar

### ⚠️ **Senaryo 2: Video Generation Başarısız**

**Attempt 5 (20 saniye sonra)**
```json
{
  "ErrCode": 0,
  "ErrMsg": "success",
  "Resp": {
    "id": 555666777,
    "status": 2, // ❌ Failed!
    "url": null
  }
}
```

**Flow:**
```
Actions:
├─ Log: "❌ Pixverse Original video failed"
├─ Create error response
│  └─ status: "failed"
│  └─ error: "Video generation failed"
└─ Firebase'e kaydet (failed status)
    └─ UI'da hata gösterilir
        └─ "Video oluşturulamadı. Lütfen tekrar deneyin."
```

**Credit Refund:**
```dart
// Eğer failed ise, credit iade et
if (status == 'failed') {
  await refundCredits(userId, 10);
  // isWasRefund: true flag'i set et
}
```

---

### ⏱️ **Senaryo 3: Polling Timeout**

**Attempt 60 (5 dakika sonra)**
```
Condition: 
└─ attempt >= maxAttempts (60)
    └─ Video hala processing

Actions:
├─ Log: "❌ Pixverse Original polling timeout after 60 attempts"
├─ Create timeout response
│  └─ status: "failed"
│  └─ error: "Polling timeout"
└─ Firebase'e kaydet
    └─ UI'da timeout mesajı
        └─ "Video işleme süresi çok uzun sürdü. Destek ile iletişime geçin."
```

---

## 📊 Timing Breakdown

```
┌─────────────────────────────────────────────────────────────┐
│                     TOPLAM SÜRE: ~40 saniye                 │
├─────────────────────────────────────────────────────────────┤
│ 1. User uploads photo:                      ~2s             │
│ 2. Firebase Storage upload:                 ~3s             │
│ 3. Pixverse image upload API:               ~2s             │
│ 4. Pixverse video generate API:             ~1s             │
│ 5. Firebase initial save:                   ~1s             │
│ 6. Polling (8 attempts x 5s):               ~35s            │
│ 7. Firebase final update:                   ~1s             │
│ 8. UI refresh:                              ~0.5s           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 State Diagram

```
[User Selects Template]
        ↓
[User Uploads Photo]
        ↓
[Click Generate Button]
        ↓
[Firebase Storage Upload] ──────────────┐
        ↓                                │
[Pixverse Image Upload API]             │
        ↓                                │
[Pixverse Video Generate API]           │
        ↓                                │
[Credit Deduction]                       │
        ↓                                │
[Save to Firebase (processing)]         │
        ↓                                │
[UI: Success Message] ←─────────────────┘
        ↓
[Background Polling Starts]
        ↓
    ┌───┴────┐
    │ Every  │
    │ 5 sec  │
    └───┬────┘
        ↓
[Check Video Status]
        ↓
    ┌───┴────────────┐
    │ Processing?    │
    └───┬────────┬───┘
        │        │
   YES  │        │  NO
        ↓        ↓
   [Wait 5s]  [Success/Failed?]
        │            ↓
        └────────→ [Update Firebase]
                     ↓
                 [UI Auto Refresh]
                     ↓
                 [Video Ready! 🎉]
```

---

## 🔍 Error Handling Matrix

| Error Scenario | Detection Point | Action | User Message |
|----------------|----------------|--------|--------------|
| Insufficient credits | Before API call | Block generation | "Yetersiz kredi" |
| Image upload fails | Image upload API | Show error | "Fotoğraf yüklenemedi" |
| Video generate fails | Video API | Refund credits | "Video oluşturulamadı" |
| Polling timeout | After 5 minutes | Mark as failed | "Zaman aşımı" |
| Network error | Any API call | Retry/Show error | "Bağlantı hatası" |

---

## 📁 Dosya Haritası

```
lib/
├── app/
│   ├── features/
│   │   ├── template_generate/
│   │   │   ├── bloc/
│   │   │   │   ├── template_generate_bloc.dart      [AI Model Check]
│   │   │   │   ├── template_generate_event.dart     [templateId field]
│   │   │   │   └── template_generate_state.dart
│   │   │   ├── data/
│   │   │   │   └── template_generate_usecase.dart   [addUserVideo]
│   │   │   └── ui/
│   │   │       └── screens/
│   │   │           └── generate_template_video_screen.dart [Event dispatch]
│   │   │
│   │   └── video_generate/
│   │       ├── data/
│   │       │   └── video_generate_usecase.dart      [3 new methods]
│   │       └── model/
│   │           ├── pixverse_original_image_upload_model.dart
│   │           ├── pixverse_original_video_generate_model.dart
│   │           ├── pixverse_original_video_result_model.dart
│   │           └── video_generate_response_model.dart [traceId field]
│   │
├── core/
│   └── constants/
│       └── app_constants.dart                       [pixverseOriginalApiKey]
│
└── [Generated files by build_runner]
    └── *.g.dart
```

---

## 🎉 Başarı Kriterleri

✅ **Template seçimi başarılı**
✅ **Fotoğraf yükleme başarılı**  
✅ **Pixverse'e upload başarılı**
✅ **Video generation başarılı**
✅ **Credit düşümü doğru**
✅ **Polling background'da çalışıyor**
✅ **Firebase otomatik güncelleniyor**
✅ **UI real-time refresh yapıyor**
✅ **Video indirilebilir ve paylaşılabilir**

---

## 🚀 Next Steps (Potansiyel İyileştirmeler)

1. **Push Notification:** Video tamamlandığında bildirim gönder
2. **Progress Bar:** Polling sırasında yaklaşık ilerleme göster
3. **Retry Logic:** Başarısız videolar için retry butonu
4. **Queue System:** Birden fazla video sıralama
5. **Analytics:** Video generation süreleri ve başarı oranları

---

**Son Güncelleme:** 2025-10-10  
**API Version:** Pixverse Original v2  
**Flutter Version:** 3.8.0  
**Status:** ✅ Production Ready





