# Pixverse Original Video - Firebase Storage Integration

## Problem
Pixverse Original API'den gelen video URL'leri geçici olabiliyor. Bu URL'ler bir süre sonra erişilemez hale gelebiliyor.

## Çözüm
Pixverse'den gelen videoları otomatik olarak Firebase Storage'a yüklüyoruz. Böylece videolar kalıcı olarak bizim Firebase Storage'ımızda saklanıyor.

## Nasıl Çalışıyor?

### 1. Firebase Functions (Server-Side)
**Dosya:** `functions/index.js`

Firebase Functions her 1 dakikada bir `checkPendingPixverseVideos` fonksiyonunu çalıştırıyor:

1. **Pending videoları bulur:** `processing` statusundeki Pixverse Original videoları filtreler
2. **Status kontrolü yapar:** Pixverse API'ye istek atarak video durumunu kontrol eder
3. **Video tamamlandıysa:**
   - Pixverse URL'den videoyu indirir
   - Firebase Storage'a yükler (`pixverse_videos/{userId}/{videoId}_{timestamp}.mp4`)
   - Public URL oluşturur
   - Firestore'daki video datasını günceller:
     - `output`: Firebase Storage URL'i
     - `pixverseUrl`: Orijinal Pixverse URL'i (backup için)
     - `status`: 'succeeded'
     - `completedAt`: Tamamlanma zamanı

**Önemli Fonksiyon:**
```javascript
async function uploadPixverseVideoToFirebase(pixverseUrl, userId, videoId) {
  // Videoyu Pixverse'den indir
  const response = await axios.get(pixverseUrl, {
    responseType: 'arraybuffer',
    timeout: 60000
  });
  
  // Firebase Storage'a yükle
  const bucket = admin.storage().bucket();
  const fileName = `pixverse_videos/${userId}/${videoId}_${Date.now()}.mp4`;
  const file = bucket.file(fileName);
  
  await file.save(videoBuffer, {
    metadata: {
      contentType: 'video/mp4',
      metadata: {
        userId: userId,
        videoId: videoId,
        source: 'pixverse-original',
        uploadedAt: new Date().toISOString()
      }
    }
  });
  
  // Public URL oluştur
  await file.makePublic();
  return publicUrl;
}
```

### 2. Flutter Client (App Resume Check)
**Dosya:** `lib/app/features/video_generate/data/video_generate_usecase.dart`

Kullanıcı app'i açtığında veya library'ye geldiğinde:

1. **Pending videoları kontrol eder:** `checkPixverseOriginalVideoStatusOnce` metodu
2. **Video tamamlandıysa:**
   - Pixverse URL'den videoyu indirir
   - Firebase Storage'a yükler
   - Firebase URL'i döner
   - Firestore'u günceller

**Önemli Fonksiyon:**
```dart
Future<String?> uploadPixverseVideoToFirebase({
  required String pixverseUrl,
  required String videoId,
}) async {
  // Videoyu indir
  final response = await http.get(Uri.parse(pixverseUrl));
  final videoBytes = response.bodyBytes;
  
  // Firebase Storage'a yükle
  final fileName = 'pixverse_videos/$userId/${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
  final ref = storage.ref().child(fileName);
  
  final uploadTask = await ref.putData(
    videoBytes,
    SettableMetadata(
      contentType: 'video/mp4',
      customMetadata: {
        'userId': userId,
        'videoId': videoId,
        'source': 'pixverse-original',
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    ),
  );
  
  return await uploadTask.ref.getDownloadURL();
}
```

## Firestore Video Data Yapısı

```json
{
  "id": "364487838592718",
  "model": "pixverse-original-4.5",
  "status": "succeeded",
  "output": "https://storage.googleapis.com/disciplify-26970.appspot.com/pixverse_videos/userId/videoId_timestamp.mp4",
  "pixverseUrl": "https://media.pixverse.ai/...",
  "trace_id": "uuid-trace-id",
  "template_id": 302325299692608,
  "video_id": 364487838592718,
  "createdAt": "2025-01-10T12:00:00Z",
  "completedAt": "2025-01-10T12:05:00Z"
}
```

## Avantajlar

✅ **Kalıcı URL'ler:** Videolar Firebase Storage'da kalıcı olarak saklanıyor
✅ **Backup:** Orijinal Pixverse URL'i de `pixverseUrl` alanında saklanıyor
✅ **Otomatik:** Hem server-side (Firebase Functions) hem client-side (App Resume) otomatik çalışıyor
✅ **Güvenilir:** Yükleme başarısız olursa Pixverse URL'i fallback olarak kullanılıyor
✅ **Metadata:** Her video için userId, videoId, source, uploadedAt bilgileri saklanıyor

## Firebase Storage Yapısı

```
pixverse_videos/
  └── {userId}/
      ├── {videoId}_1234567890.mp4
      ├── {videoId}_1234567891.mp4
      └── ...
```

## Deployment

Firebase Functions deploy edildi:
```bash
firebase deploy --only functions:checkPendingPixverseVideos
```

## Monitoring

Firebase Console'dan kontrol edebilirsiniz:
- **Functions Logs:** https://console.firebase.google.com/project/disciplify-26970/functions/logs
- **Storage:** https://console.firebase.google.com/project/disciplify-26970/storage

## Test Senaryosu

1. Kullanıcı Pixverse Original template ile video generate eder
2. Video `processing` statusuyla Firebase'e kaydedilir
3. Firebase Functions 1 dakika içinde status kontrolü yapar
4. Video tamamlandığında:
   - Pixverse'den indirilir
   - Firebase Storage'a yüklenir
   - Firestore güncellenir
5. Kullanıcı library'ye geldiğinde Firebase Storage URL'i ile videoyu görür

## Fallback Mekanizması

Eğer Firebase Storage'a yükleme başarısız olursa:
- Orijinal Pixverse URL'i kullanılır
- Log'a hata yazılır ama işlem devam eder
- Kullanıcı videoyu yine de görebilir

