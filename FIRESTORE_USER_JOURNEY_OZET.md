# 🔥 Firestore User Journey Logger - SÜPER GÜÇ!

## 🎯 Ne Yaptık?

Firebase Analytics'e EK OLARAK, her kullanıcının uygulamadaki **TAM YOLCULUĞUNU** Firestore'a kaydediyoruz!

## 📊 Firestore Yapısı

```
/user_sessions/
  /{randomSessionId}/
    sessionId: "abc-123-xyz"
    userId: null (başta) veya "user123" (login olduktan sonra)
    platform: "ios" veya "android"
    appVersion: "1.1.3"
    startTime: timestamp
    isActive: true
    logs: [
      {
        action: "app_opened",
        timestamp: 2025-01-15 10:30:00,
        timestampMs: 1705315800000,
        data: {platform: "ios", appVersion: "1.1.3"}
      },
      {
        action: "splash_started",
        timestamp: 2025-01-15 10:30:01,
        timestampMs: 1705315801000
      },
      {
        action: "splash_progress",
        timestamp: 2025-01-15 10:30:02,
        timestampMs: 1705315802000,
        data: {stage: "theme_loaded", progress: 50}
      },
      {
        action: "splash_completed",
        timestamp: 2025-01-15 10:30:03,
        timestampMs: 1705315803000,
        data: {durationMs: 2000}
      },
      {
        action: "login_screen_viewed",
        timestamp: 2025-01-15 10:30:04,
        timestampMs: 1705315804000
      },
      {
        action: "login_button_clicked",
        timestamp: 2025-01-15 10:30:45,
        timestampMs: 1705315845000,
        data: {method: "google"}
      },
      {
        action: "login_attempt_started",
        timestamp: 2025-01-15 10:30:46,
        timestampMs: 1705315846000,
        data: {method: "google"}
      },
      {
        action: "login_success",
        timestamp: 2025-01-15 10:30:50,
        timestampMs: 1705315850000,
        data: {method: "google", userId: "user123"}
      },
      {
        action: "session_linked_to_user",
        timestamp: 2025-01-15 10:30:50,
        timestampMs: 1705315850000,
        data: {userId: "user123"}
      },
      {
        action: "home_screen_reached",
        timestamp: 2025-01-15 10:30:51,
        timestampMs: 1705315851000
      }
    ]

/users/{userId}/
  sessions: ["abc-123-xyz", "def-456-uvw", ...]
```

## 🎉 ŞİMDİ NELER GÖREBİLİRSİN?

### 1. Gerçek Zamanlı - Her Kullanıcının Tam Journey'i

Firestore Console'a git:
```
Firebase Console > Firestore Database > user_sessions
```

**Rastgele bir session'a tıkla**, göreceksin:
```json
{
  "sessionId": "e7f8a9b0-1234-5678-90ab-cdef12345678",
  "userId": null,  // ← Henüz login olmamış!
  "platform": "ios",
  "appVersion": "1.1.3",
  "startTime": "2025-01-15T10:30:00Z",
  "isActive": true,
  "logs": [
    {action: "app_opened", timestamp: ..., data: {...}},
    {action: "splash_started", timestamp: ...},
    {action: "splash_progress", stage: "theme_loaded", progress: 50},
    {action: "splash_completed", durationMs: 2000},
    {action: "login_screen_viewed", timestamp: ...},
    {action: "login_screen_exited", durationSeconds: 45}  // ← 45 saniye bakıp çıkmış!
  ]
}
```

**ANLIK GÖRECEK

SİN**: "Bu kullanıcı login ekranında 45 saniye kaldı ama login yapmadan çıktı!"

### 2. Login Olan Kullanıcının Tüm Session'ları

```
Firebase Console > Firestore Database > users/{userId}
```

```json
{
  "sessions": [
    "session-1-abc",  // İlk açılış (login olmamış)
    "session-2-def",  // İkinci açılış (login olmuş!)
    "session-3-ghi"   // Üçüncü açılış
  ]
}
```

Her session ID'sine tıklayıp o session'daki tüm logları görebilirsin!

## 📱 Kullanım Örnekleri

### Örnek 1: "Login ekranında takılan kullanıcı"

```
user_sessions > session-123 > logs:
[
  {action: "app_opened", ...},
  {action: "splash_completed", ...},
  {action: "login_screen_viewed", timestamp: 10:30:00},
  {action: "login_screen_exited", timestamp: 10:32:30, duration: 150}
]
```

**SONUÇ**: 2.5 dakika (150 sn) login ekranında kaldı ama hiçbir butona basmadı!

### Örnek 2: "Login deneyen ama başarısız olan"

```
logs:
[
  {action: "login_screen_viewed", ...},
  {action: "login_button_clicked", method: "email", ...},
  {action: "login_attempt_started", method: "email", ...},
  {action: "login_failed", method: "email", error: "wrong-password", ...}
]
```

**SONUÇ**: Email ile denedi, yanlış şifre girdi!

### Örnek 3: "Başarılı journey"

```
logs:
[
  {action: "app_opened"},
  {action: "splash_completed", durationMs: 1800},
  {action: "login_screen_viewed"},
  {action: "login_button_clicked", method: "google"},
  {action: "login_success", method: "google", userId: "user123"},
  {action: "session_linked_to_user", userId: "user123"},
  {action: "home_screen_reached"}
]
```

**SONUÇ**: Mükemmel akış! 1.8 saniye splash, direkt Google ile login, home'a ulaştı!

## 🔍 Query Örnekleri (Firestore Console)

### 1. Son 1 saatte uygulamayı açan kullanıcılar
```
Collection: user_sessions
Filter: startTime >= (1 saat önce)
Order by: startTime descending
```

### 2. Login yapmadan çıkan session'lar
```
Collection: user_sessions
Filter: userId == null
Filter: isActive == false
```

### 3. Splash'te hata alan session'lar
```
Collection: user_sessions
Array contains: logs.action == "splash_error"
```

## 💡 En Güçlü Yanı

### Firebase Analytics vs Firestore Logger

| Özellik | Firebase Analytics | Firestore Logger |
|---------|-------------------|------------------|
| Gerçek zamanlı | ❌ 24 saat bekler | ✅ ANında |
| Kullanıcı bazında | ⚠️ Zor | ✅ Kolay |
| Tam journey | ❌ Parçalı | ✅ TAM |
| Custom query | ⚠️ Sınırlı | ✅ HER ŞEY |
| Export | ⚠️ BigQuery | ✅ Direkt JSON |
| Debug | DebugView | Firestore Console |

## 🚀 Firestore Console'da Nasıl Görürsün?

### 1. Git:
```
https://console.firebase.google.com/project/disciplify-26970/firestore
```

### 2. Collections:
- **user_sessions** → Tüm session'lar burada
- **users** → Login olan kullanıcıların session listesi

### 3. Bir session aç:
```
user_sessions > [herhangi bir ID] > logs array'ini aç
```

### 4. Her log'u gör:
```
{
  action: "login_screen_viewed"
  timestamp: January 15, 2025 at 10:30:04 AM UTC
  timestampMs: 1705315804000
}
```

## 📊 TikTok Kampanyası için Kullanım

### Senaryo: 1000 kullanıcı TikTok'tan geldi

Firestore'da göreceğin:

```
user_sessions: 1000 doküman

userId == null olan: 720 (login olmadılar)
userId != null olan: 280 (login oldular) ← %28 conversion!
```

**720 login olmayanın detayları**:
```
Query: userId == null
```

Her birine tek tek bakabilirsin:
- Kaçı splash'i tamamladı?
- Kaçı login ekranına ulaştı?
- Login ekranında ne kadar kaldılar?
- Hangi butona bastılar?
- Neden başarısız oldular?

## 🎯 Actionable Insights

### "650 kullanıcı login ekranını gördü ama hiçbir butona basmadı"

**Firestore Query**:
```
user_sessions
  Where: logs contains {action: "login_screen_viewed"}
  Where: logs NOT contains {action: "login_button_clicked"}
```

**Çözüm**: Login butonlarını daha belirgin yap!

### "120 kullanıcı Google butona bastı ama login başarısız oldu"

**Firestore Query**:
```
user_sessions
  Where: logs contains {action: "login_button_clicked", method: "google"}
  Where: logs contains {action: "login_failed"}
```

**Çözüm**: Google Sign-In config'de sorun var!

## 🔥 BONUS: User'a Özel Sorgular

### Belirli bir kullanıcının tüm session'larını gör

1. **Kullanıcı ID'si**: `user123`

2. **Users collection'a git**:
```
users > user123 > sessions array
```

3. **Her session'a tıkla**:
```
user_sessions > session-1-abc
user_sessions > session-2-def
...
```

4. **Tüm journey'i gör**: İlk açılıştan bugüne kadar her hareketi!

## 📝 Özet

✅ Her kullanıcının tam journey'i Firestore'da
✅ Gerçek zamanlı - hiç bekleme yok
✅ Login olan kullanıcının tüm session'larını görebilirsin
✅ Custom query'ler yazabilirsin
✅ Export edebilirsin (JSON)
✅ Splash'ten home'a kadar her adım loglanıyor

**ŞİMDİ ARTIK**:
- Kullanıcılar nerede takılıyor → GÖREBİLİRSİN
- Ne kadar süre kalıyorlar → GÖREBİLİRSİN
- Hangi butonlara basıyorlar → GÖREBİLİRSİN
- Neden başarısız oluyorlar → GÖREBİLİRSİN

Hepsi **gerçek zamanlı** Firestore'da! 🎉

