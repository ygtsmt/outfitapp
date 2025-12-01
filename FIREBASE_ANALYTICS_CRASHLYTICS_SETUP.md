# 🔥 Firebase Analytics & Crashlytics Kurulum Rehberi

## ✅ Yapılan Değişiklikler

### 1. Paketler Eklendi
- `firebase_crashlytics: ^4.1.5` - Hata raporlama için
- `firebase_analytics: ^11.3.5` - Kullanıcı davranış analizi için

### 2. Main.dart Yapılandırması
Firebase Crashlytics ve Analytics başlatıldı:
- **Global Error Handler**: Tüm Flutter hataları otomatik olarak Crashlytics'e raporlanıyor
- **Asenkron Error Handler**: Platform hatalarını yakalıyor
- **App Open Tracking**: Uygulama her açıldığında loglanıyor

### 3. Analytics Servisi Oluşturuldu
`lib/core/services/analytics_service.dart` dosyası eklendi ve şu fonksiyonları içeriyor:

#### Splash Screen Events
- `logSplashStarted()` - Splash başladığında
- `logSplashProgress(stage, progress)` - Her aşamada ilerleme
- `logSplashCompleted(durationMs)` - Splash tamamlandığında (ne kadar sürdü)
- `logSplashError(error, stage)` - Hangi aşamada hata oldu

#### Auth Events
- `logLoginScreenViewed()` - Login ekranı görüntülendi
- `logLoginSuccess(method)` - Login başarılı (email/google/apple/guest)
- `logLoginError(error, method)` - Login başarısız
- `logSignupScreenViewed()` - Kayıt ekranı görüntülendi
- `logSignupSuccess(method)` - Kayıt başarılı
- `logSignupError(error, method)` - Kayıt başarısız

#### Home Screen Events
- `logHomeScreenReached()` - Kullanıcı ana ekrana ulaştı

#### User Properties
- `setUserId(userId)` - Kullanıcı ID'sini ayarla
- `setUserProperty(name, value)` - Kullanıcı özelliği ayarla

#### Error Tracking
- `logError(error, stackTrace)` - Hata kaydet
- `log(message)` - Debug mesajı kaydet
- `setBreadcrumb(key, value)` - Kullanıcı akışını takip et

### 4. Tracking Eklenen Ekranlar

#### ✅ Splash Screen (`splash_screen.dart`)
- Her aşamada ilerleme loglanıyor (theme, language, ads, revenue_cat)
- Hata durumunda hangi aşamada hata olduğu loglanıyor
- Toplam splash süresi ölçülüyor
- Kullanıcı durumu (logged_in/logged_out) breadcrumb olarak ekleniyor

#### ✅ Login Screen (`login_bloc.dart`)
- Screen view tracking
- Her login metodu için tracking (email, google, apple, guest)
- Login süresi ölçülüyor
- Başarısız login denemeleri ve hata kodları loglanıyor

#### ✅ Create Account Screen (`create_account_bloc.dart`)
- Screen view tracking
- Her kayıt metodu için tracking
- Kayıt süresi ölçülüyor
- Anonymous'tan upgrade durumu tracking
- Başarısız kayıt denemeleri loglanıyor

#### ✅ Home Screen (`home_screen.dart`)
- Kullanıcı ana ekrana ulaştığında log
- User properties ayarlanıyor (is_anonymous, has_email)

### 5. Android Yapılandırması
- `android/settings.gradle.kts` - Crashlytics plugin eklendi
- `android/app/build.gradle.kts` - Crashlytics plugin apply edildi

## 📊 Firebase Console'da Neler Görebilirsiniz?

### Analytics (Google Analytics)
1. Firebase Console > Analytics > Events
   - `splash_started` - Kaç kullanıcı splash'e ulaştı
   - `splash_progress` - Hangi aşamada takıldılar
   - `splash_completed` - Splash süresi (milisaniye)
   - `login_screen_viewed` - Login ekranını kaç kişi gördü
   - `signup_screen_viewed` - Kayıt ekranını kaç kişi gördü
   - `login` - Başarılı login'ler (method ile)
   - `sign_up` - Başarılı kayıtlar (method ile)
   - `user_reached_home` - Ana ekrana ulaşan kullanıcılar
   - `login_failed` - Başarısız login'ler (hata kodu ile)
   - `signup_failed` - Başarısız kayıtlar

2. Firebase Console > Analytics > User Properties
   - `is_anonymous` - Kullanıcı anonim mi?
   - `has_email` - Email var mı?

### Crashlytics
1. Firebase Console > Crashlytics > Dashboard
   - Crash-free kullanıcı yüzdesi
   - En çok crash veren yerler
   - Crash trendleri

2. Issues
   - Splash hatalarını "Splash" tag'i ile filtreleyebilirsiniz
   - Her hata için:
     - Stack trace
     - Kullanıcı breadcrumbs (hangi ekranlardan geçti)
     - User ID
     - Device bilgisi
     - OS version

## 🎯 Sorunları Tespit Etme

### "Kullanıcılar splash'te takılıyor mu?"
```
Analytics > Events > splash_progress
```
- Hangi aşamada progress durdu?
- `splash_completed` event sayısı `splash_started`'dan çok düşükse sorun var

### "Login ekranına kaç kişi ulaşıyor?"
```
Analytics > Events > login_screen_viewed
vs
Analytics > Events > splash_completed
```
- Eğer splash_completed yüksek ama login_screen_viewed düşükse, splash sonrası routing'de sorun var

### "Kayıt ekranını görenlerden kaçı kayıt oluyor?"
```
Analytics > Funnels
1. signup_screen_viewed
2. sign_up
```
- Conversion rate'i görebilirsiniz

### "Hangi login metodu daha başarılı?"
```
Analytics > Events > login
- method parametresine göre filtrele (email, google, apple)
```

### "En çok hangi hatalar oluşuyor?"
```
Crashlytics > Issues
- Splash hatalarını görün
- Login hatalarını görün
- "reason" field'ına bakın
```

## 🚀 Test Etme

### 1. Normal Akış (Başarılı)
1. Uygulamayı tamamen kapatın
2. Açın (splash_started log)
3. Login ekranına ulaşın (login_screen_viewed)
4. Login yapın (login success)
5. Home ekranına ulaşın (user_reached_home)

### 2. Hata Durumları (Kasıtlı)
1. İnterneti kapatıp splash'i açın → `splash_error` eventi görmeli
2. Yanlış şifre ile login deneyin → `login_failed` eventi görmeli
3. Var olan email ile kayıt deneyin → `signup_failed` eventi görmeli

### 3. Analytics'i Görüntüleme
Analytics verileri **gerçek zamanlı** değildir:
- **DebugView**: Gerçek zamanlı test için (aşağıda açıklama)
- **Normal Events**: 24 saat içinde görünür

### 4. DebugView Açma (Gerçek Zamanlı Test)

#### iOS:
```bash
# DebugView'ı aç
adb shell setprop debug.firebase.analytics.app com.ginowl.ginlyai

# DebugView'ı kapat
adb shell setprop debug.firebase.analytics.app .none.
```

#### Android:
```bash
# DebugView'ı aç
adb shell setprop debug.firebase.analytics.app com.ginowl.ginlyai

# DebugView'ı kapat
adb shell setprop debug.firebase.analytics.app .none.
```

Sonra Firebase Console > Analytics > DebugView'a gidin ve cihazınızı seçin.

## 📱 Production'da Kullanım

### Crashlytics
✅ Otomatik olarak çalışır
✅ Release build'de aktif
✅ Kullanıcı izni gerektirmez

### Analytics
✅ Otomatik olarak çalışır
✅ GDPR uyumlu (gerekirse user opt-out eklenebilir)
✅ Anonim kullanıcı ID'leri

## 🔧 Ekstra İyileştirmeler (Gelecek)

### 1. Custom Funnels
Firebase Console'da funnel oluşturabilirsiniz:
- Splash → Login → Signup → Home
- Bu sayede her adımda kaç kullanıcı kaybolduğunu görürsünüz

### 2. User Retention
Analytics otomatik olarak retention metriklerini hesaplar:
- 1-day retention
- 7-day retention
- 30-day retention

### 3. Performance Monitoring
İlave olarak eklenebilir:
```yaml
firebase_performance: ^0.10.0
```

### 4. Remote Config
Sorun varsa uzaktan değişiklik yapabilirsiniz:
```yaml
firebase_remote_config: ^5.0.0
```

## 📞 Destek

Bu kurulumla ilgili sorularınız için:
1. Firebase Console > Support
2. [FlutterFire Documentation](https://firebase.flutter.dev/)
3. Bu projedeki tracking kodlarını inceleyebilirsiniz

## 🎉 Sonuç

Artık kullanıcıların:
- ✅ Nerede takıldığını
- ✅ Hangi hataları aldığını
- ✅ Hangi ekranlara ulaştığını
- ✅ Ne kadar sürede login/signup yaptığını

Firebase Console'dan gerçek zamanlı görebilirsiniz!

**Önemli**: Firebase Analytics verilerinin görünmesi 24 saat sürebilir. DebugView ile anlık test edebilirsiniz.


