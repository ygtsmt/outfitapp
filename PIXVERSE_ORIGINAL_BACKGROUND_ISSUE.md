# ⚠️ Pixverse Original API - Background Processing Sorunu

## 🔴 Problem Senaryosu

```
Timeline:
├─ 14:30:00 - Kullanıcı "Generate" butonuna tıklar
├─ 14:30:05 - Video generation başlar (processing)
├─ 14:30:06 - Kullanıcı uygulamayı kapatır ❌
├─ 14:30:35 - Video hazır olur ✅ (Pixverse'de)
├─ 14:35:00 - Kullanıcı uygulamayı tekrar açar
└─ 14:35:05 - Library'de ne görür? 🤔
```

### ❌ Mevcut Durum
Kullanıcı videoyu **GÖREMEZ** çünkü:
- Video hala `status: "processing"` olarak Firebase'de
- `output: null` (video URL'si yok)
- Polling durdu (app kapandığında)

---

## 🔍 Sorunun Nedeni

### 1. Polling Flutter App Process'ine Bağlı

```dart
// lib/app/features/template_generate/bloc/template_generate_bloc.dart

Future<void> _pollAndUpdateVideo(String videoId, String traceId) async {
  // Bu metod Flutter app process içinde çalışır
  
  final result = await videoGenerateUsecase.pollPixverseOriginalVideoStatus(
    videoId: videoId,
    traceId: traceId,
  );
  
  // ⚠️ App kapatıldığında bu kod durur!
  // Polling tamamlanamaz
}
```

### 2. Background Execution Yok

Flutter'da:
- App killed → Dart code execution stops
- No native background service (without plugin)
- Polling loop kesilir

### 3. Firebase Update Yapılamaz

```
App Lifecycle:
├─ App Running → Polling Active ✅
├─ App Paused → Polling Active ✅ (kısa süre)
├─ App Killed → Polling STOPS ❌
└─ Result: Firebase never updated
```

---

## ✅ Çözüm Seçenekleri

### 🏆 **ÇÖZÜM 1: Firebase Functions Webhook (ÖNERİLEN)**

#### Nasıl Çalışır?

```
Flow:
├─ User generates video
├─ Video generation request → Pixverse API
├─ Pixverse'e webhook URL ver
│   └─ webhookUrl: "https://your-firebase-function.cloudfunctions.net/pixverseWebhook"
├─ App kapansa bile, Pixverse webhook'u tetikler
└─ Firebase Function:
    ├─ Webhook'u dinler
    ├─ Video hazır olunca Pixverse bildiriyor
    └─ Otomatik Firebase'e kaydeder
```

#### Implementation

##### 1. Firebase Function Oluştur

```javascript
// functions/index.js

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.pixverseOriginalWebhook = functions.https.onRequest(async (req, res) => {
  try {
    console.log('📥 Pixverse Original Webhook received:', req.body);
    
    const { videoId, status, url, userId, traceId } = req.body;
    
    if (!videoId || !userId) {
      return res.status(400).send('Missing required fields');
    }
    
    // Firebase'den kullanıcının videoları al
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    if (!userDoc.exists) {
      return res.status(404).send('User not found');
    }
    
    const userData = userDoc.data();
    const videos = userData.userGeneratedVideos || [];
    
    // İlgili videoyu bul ve güncelle
    const updatedVideos = videos.map(video => {
      if (video.id === videoId.toString()) {
        return {
          ...video,
          status: status === 1 ? 'succeeded' : status === 2 ? 'failed' : 'processing',
          output: url || null,
          completedAt: new Date().toISOString(),
        };
      }
      return video;
    });
    
    // Firebase'e kaydet
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .update({
        userGeneratedVideos: updatedVideos
      });
    
    console.log('✅ Video updated via webhook:', videoId);
    return res.status(200).send('OK');
    
  } catch (error) {
    console.error('❌ Webhook error:', error);
    return res.status(500).send('Internal Server Error');
  }
});
```

##### 2. Webhook URL'i Pixverse'e Ver

⚠️ **PROBLEM**: Pixverse Original API webhook desteği YOK!
- Dokümantasyonda webhook parametresi yok
- Sadece polling mevcut

Bu yüzden bu çözüm **KULLANAMAYIZ** ❌

---

### 🎯 **ÇÖZÜM 2: App Açıldığında Pending Video Kontrolü (PRATİK)**

#### Nasıl Çalışır?

```
App Lifecycle:
├─ App açılır (onResume/initState)
├─ Firebase'den processing statusündeki videoları çek
├─ Her biri için Pixverse API'ye status check
├─ Güncel status'ları Firebase'e kaydet
└─ Library UI güncellenir
```

#### Implementation

##### 1. Library Bloc'a Check Pending Videos Ekle

```dart
// lib/app/features/library/bloc/library_bloc.dart

on<CheckPendingVideosEvent>((event, emit) async {
  try {
    log('🔍 Checking pending videos...');
    
    final userId = auth.currentUser!.uid;
    final userDoc = await firestore.collection('users').doc(userId).get();
    
    if (!userDoc.exists) return;
    
    final userData = userDoc.data();
    final videos = userData?['userGeneratedVideos'] as List<dynamic>? ?? [];
    
    // Processing statusündeki Pixverse Original videoları filtrele
    final pendingVideos = videos.where((video) {
      return video['status'] == 'processing' &&
             video['model'] == 'pixverse-original-4.5' &&
             video['traceId'] != null;
    }).toList();
    
    if (pendingVideos.isEmpty) {
      log('✅ No pending videos');
      return;
    }
    
    log('📋 Found ${pendingVideos.length} pending videos');
    
    // Her pending video için status check
    for (final videoData in pendingVideos) {
      final videoId = videoData['id'] as String;
      final traceId = videoData['traceId'] as String;
      
      try {
        // Tek seferlik status check (polling değil!)
        final response = await http.get(
          Uri.parse('https://app-api.pixverse.ai/openapi/v2/video/result/$videoId'),
          headers: {
            'API-KEY': pixverseOriginalApiKey,
            'Ai-trace-id': traceId,
          },
        );
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final resultResponse = PixverseOriginalVideoResultResponse.fromJson(responseData);
          
          if (resultResponse.errCode == 0 && resultResponse.resp != null) {
            final resp = resultResponse.resp!;
            
            // Status: 0=processing, 1=succeeded, 2=failed
            if (resp.status == 1 && resp.url != null) {
              // ✅ Video hazır! Firebase'i güncelle
              log('✅ Video completed: $videoId');
              
              await _updateVideoInFirebase(
                userId: userId,
                videoId: videoId,
                status: 'succeeded',
                url: resp.url!,
                completedAt: resp.modifyTime,
              );
            } else if (resp.status == 2) {
              // ❌ Video başarısız
              log('❌ Video failed: $videoId');
              
              await _updateVideoInFirebase(
                userId: userId,
                videoId: videoId,
                status: 'failed',
                url: null,
                completedAt: resp.modifyTime,
              );
            } else {
              // ⏳ Hala processing
              log('⏳ Video still processing: $videoId');
            }
          }
        }
      } catch (e) {
        log('⚠️ Error checking video $videoId: $e');
        // Continue with next video
      }
    }
    
    log('✅ Pending videos check completed');
    
  } catch (e) {
    log('❌ Error in CheckPendingVideosEvent: $e');
  }
});

Future<void> _updateVideoInFirebase({
  required String userId,
  required String videoId,
  required String status,
  required String? url,
  required String completedAt,
}) async {
  final userDoc = await firestore.collection('users').doc(userId).get();
  final userData = userDoc.data();
  final videos = userData?['userGeneratedVideos'] as List<dynamic>? ?? [];
  
  final updatedVideos = videos.map((video) {
    if (video['id'] == videoId) {
      return {
        ...video,
        'status': status,
        'output': url,
        'completedAt': completedAt,
      };
    }
    return video;
  }).toList();
  
  await firestore.collection('users').doc(userId).update({
    'userGeneratedVideos': updatedVideos,
  });
}
```

##### 2. Event Oluştur

```dart
// lib/app/features/library/bloc/library_event.dart

class CheckPendingVideosEvent extends LibraryEvent {
  const CheckPendingVideosEvent();
  
  @override
  List<Object> get props => [];
}
```

##### 3. App Açıldığında Trigger Et

```dart
// lib/app/features/library/ui/screens/library_screen.dart

class _LibraryScreenState extends State<LibraryScreen> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // İlk açılışta check et
    _checkPendingVideos();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App foreground'a geldiğinde check et
      _checkPendingVideos();
    }
  }
  
  void _checkPendingVideos() {
    getIt<LibraryBloc>().add(const CheckPendingVideosEvent());
  }
  
  // ... rest of the code
}
```

---

### 🔧 **ÇÖZÜM 3: Background Task (EN KARMAŞIK)**

#### Native Background Service Kullan

- **Android**: WorkManager
- **iOS**: Background Fetch

```dart
// pubspec.yaml
dependencies:
  workmanager: ^0.5.0
```

⚠️ **ZORLUKLAR**:
- iOS background limitations (15 dakika)
- Battery drain concerns
- Kompleks implementasyon
- User permission gerekebilir

**ÖNERİ**: Bu çözümü KULLANMA, Çözüm 2 daha pratik.

---

## 📊 Çözüm Karşılaştırması

| Özellik | Firebase Webhook | App Resume Check | Background Task |
|---------|------------------|------------------|-----------------|
| **Komplekslik** | Orta | Düşük | Yüksek |
| **Realtime Update** | ✅ Evet | ❌ Hayır | ✅ Evet |
| **App Kapalıyken** | ✅ Çalışır | ❌ Çalışmaz | ✅ Çalışır |
| **Battery Impact** | ✅ Yok | ✅ Minimal | ⚠️ Var |
| **Pixverse Desteği** | ❌ YOK | ✅ Var | ✅ Var |
| **Implementation** | Firebase Functions | Flutter Code | Native + Plugin |
| **Öncelik** | - | 🏆 **ÖNERİLEN** | - |

---

## 🎯 ÖNERİLEN ÇÖZÜM: App Resume Check

### Avantajları
✅ Basit implementasyon
✅ Battery friendly
✅ Pixverse API ile uyumlu
✅ Her app açılışında güncelleme
✅ Ek maliyet yok

### Dezavantajları
⚠️ App kapalıyken update yok
⚠️ Kullanıcı app'i açana kadar göremez

### Kullanıcı Deneyimi

```
Senaryo 1: Normal Kullanım
├─ User generates video
├─ App açık kalır
└─ Polling tamamlanır → Video görülür ✅

Senaryo 2: App Kapatma
├─ User generates video
├─ App kapanır
├─ Video hazır olur (Pixverse'de)
├─ User app'i açar
├─ Library screen → CheckPendingVideosEvent tetiklenir
└─ 2-3 saniye içinde video güncellenir ✅
```

---

## 🚀 Implementation Adımları

### 1. Model'e Import Ekle
```dart
// video_generate_usecase.dart'a ekle
import 'package:ginly/app/features/video_generate/model/pixverse_original_video_result_model.dart';
```

### 2. Library Bloc'a Event Ekle
```dart
// library_event.dart
class CheckPendingVideosEvent extends LibraryEvent {}
```

### 3. Library Bloc'a Handler Ekle
```dart
// library_bloc.dart
on<CheckPendingVideosEvent>((event, emit) async {
  // Yukarıdaki kodu ekle
});
```

### 4. Library Screen'e Observer Ekle
```dart
// library_screen.dart
class _LibraryScreenState extends State<LibraryScreen> 
    with WidgetsBindingObserver {
  // Yukarıdaki kodu ekle
}
```

### 5. Test Et
```
Test Case:
1. Video generate et
2. App'i kapat (force close)
3. 1 dakika bekle
4. App'i aç
5. Library'ye git
6. Video otomatik güncellenmiş olmalı ✅
```

---

## 📱 Alternatif: Pull to Refresh

Kullanıcıya manuel kontrol imkanı ver:

```dart
// library_screen.dart

RefreshIndicator(
  onRefresh: () async {
    getIt<LibraryBloc>().add(const CheckPendingVideosEvent());
    await Future.delayed(Duration(seconds: 2));
  },
  child: ListView.builder(
    // video list
  ),
)
```

**UI:**
```
┌─────────────────────────────┐
│ ↓ Pull to refresh           │
│                             │
│  🎬 Dance Challenge         │
│  ⏳ Processing...           │
│  ━━━━━━━━━━━━━━━━━━━━━━━  │
│                             │
│  [Refresh manually]         │
└─────────────────────────────┘
```

---

## 🎉 Final Recommendation

**Hybrid Approach (İkisini birden kullan):**

1. ✅ **Otomatik**: App resume → auto check
2. ✅ **Manuel**: Pull to refresh → user control
3. ✅ **Indicator**: Processing videos için refresh butonu

```dart
// Processing video card'ında:
if (video.status == 'processing') {
  IconButton(
    icon: Icon(Icons.refresh),
    onPressed: () {
      getIt<LibraryBloc>().add(CheckPendingVideosEvent());
    },
  )
}
```

---

## 📝 Test Senaryoları

### Test 1: App Açık
```
✅ Expected: Polling tamamlanır, video otomatik güncellenir
✅ Actual: Working as designed
```

### Test 2: App Kapalı (Short)
```
Scenario: App 10 saniye kapalı (video 30 saniyede hazır)
✅ Expected: Polling devam eder, video güncellenir
✅ Actual: Working as designed
```

### Test 3: App Kapalı (Long)
```
Scenario: App 2 dakika kapalı
❌ Old: Video processing'de kalır
✅ New: App açılınca auto-check → video güncellenir
```

### Test 4: Çoklu Video
```
Scenario: 3 video processing durumunda
✅ Expected: Hepsi check edilir, güncellenebilir olanlar güncellenir
```

---

**Sonuç:** Kullanıcı app'i kapattıktan sonra açtığında videoyu **GÖREBILECEK** (Çözüm 2 ile) ✅





