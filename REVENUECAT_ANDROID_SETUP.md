# 📱 RevenueCat Android Entegrasyonu - Detaylı Kurulum Rehberi

## 🎯 Genel Bakış

Bu dokümantasyon, GINLY uygulamasına Android için RevenueCat in-app purchase sisteminin nasıl entegre edileceğini adım adım açıklar.

## 📋 Gereksinimler

- Flutter SDK 3.1.0+
- Android Studio / VS Code
- Google Play Console hesabı
- RevenueCat hesabı
- Test cihazı (fiziksel cihaz önerilir)

## 🚀 1. RevenueCat Hesap Kurulumu

### 1.1 RevenueCat Dashboard'a Giriş
1. [RevenueCat Dashboard](https://app.revenuecat.com/) adresine gidin
2. Yeni hesap oluşturun veya mevcut hesabınıza giriş yapın
3. "New Project" butonuna tıklayın
4. Proje adını "GINLY" olarak belirleyin

### 1.2 Android App Kurulumu
1. Dashboard'da "Add App" butonuna tıklayın
2. Platform olarak "Android" seçin
3. Package name: `com.yourcompany.ginly` (AndroidManifest.xml'deki package name)
4. App name: "GINLY"
5. "Create App" butonuna tıklayın

### 1.3 API Key Alma
1. Oluşturulan app'e tıklayın
2. "Project Settings" > "API Keys" sekmesine gidin
3. **Public SDK Key**'i kopyalayın (bu key'i kodda kullanacağız)

### 1.4 Service Account Credentials Kurulumu
RevenueCat'in Google Play purchase'larını validate edebilmesi için Google Play Console'dan Service Account oluşturmanız gerekiyor:

#### 1.4.1 Google Play Console'da Service Account Oluşturma
1. [Google Play Console](https://play.google.com/console) adresine gidin
2. GINLY app'ini seçin
3. Sol menüden "Setup" > "API access" sekmesine gidin
4. "Create new service account" butonuna tıklayın
5. **Service account name**: "RevenueCat Service Account" yazın
6. **Service account ID**: Otomatik oluşacak
7. **Description**: "RevenueCat için Google Play API erişimi" yazın
8. "Create and continue" butonuna tıklayın

#### 1.4.2 Service Account'a Role Verme
1. "Grant access" sekmesinde:
   - **Role**: "View app information" seçin
   - **User**: Az önce oluşturduğunuz service account'ı seçin
2. "Grant access" butonuna tıklayın
3. "Done" butonuna tıklayın

#### 1.4.3 JSON Key Dosyası İndirme
1. "Service accounts" listesinde oluşturduğunuz account'a tıklayın
2. "Keys" sekmesine gidin
3. "Add key" > "Create new key" butonuna tıklayın
4. **Key type**: "JSON" seçin
5. "Create" butonuna tıklayın
6. **JSON dosyası otomatik indirilecek** - Bu dosyayı güvenli bir yerde saklayın

#### 1.4.4 RevenueCat'e Service Account Yükleme
1. RevenueCat Dashboard'a geri dönün
2. "Add App" > "Android" adımında
3. **Service Account Credentials JSON** alanına
4. İndirdiğiniz JSON dosyasını sürükleyin veya tıklayarak seçin
5. "Create App" butonuna tıklayın

**⚠️ Önemli Güvenlik Notları:**
- JSON dosyasını asla public repository'de paylaşmayın
- Bu dosya çok hassas bilgiler içerir
- Sadece RevenueCat'e yükleyin ve güvenli bir yerde saklayın
- Eğer dosya yanlışlıkla paylaşılırsa hemen Google Play Console'dan silin ve yeniden oluşturun

## 🛠️ 2. Flutter Proje Kurulumu

### 2.1 Dependencies Ekleme
`pubspec.yaml` dosyasına RevenueCat dependency'sini ekleyin:

```yaml
dependencies:
  purchases_flutter: ^6.0.0
```

### 2.2 Package Install
Terminal'de proje klasöründe çalıştırın:

```bash
flutter pub get
```

## 🔧 3. Android Konfigürasyonu

### 3.1 AndroidManifest.xml Güncelleme
`android/app/src/main/AndroidManifest.xml` dosyasına billing permission ekleyin:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Billing permission -->
    <uses-permission android:name="com.android.vending.BILLING" />
    
    <application>
        <!-- Mevcut konfigürasyon -->
    </application>
</manifest>
```

### 3.2 build.gradle Güncelleme
`android/app/build.gradle` dosyasında minSdkVersion'ı kontrol edin:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // RevenueCat için minimum 21 gerekli
        targetSdkVersion 33
    }
}
```

### 3.3 ProGuard Rules (Opsiyonel)
Eğer ProGuard kullanıyorsanız, `android/app/proguard-rules.pro` dosyasına ekleyin:

```pro
-keep class com.revenuecat.** { *; }
```

## 📱 4. Google Play Console Kurulumu

### 4.1 In-App Products Oluşturma
1. [Google Play Console](https://play.google.com/console) adresine gidin
2. GINLY app'ini seçin
3. Sol menüden "Monetize" > "Products" > "In-app products" seçin
4. "Create product" butonuna tıklayın

### 4.2 Subscription Plans Oluşturma
Her plan için ayrı product oluşturun:

#### Weekly Plan
- **Product ID**: `weekly_plan`
- **Name**: "Weekly Premium"
- **Description**: "Weekly premium subscription"
- **Price**: TRY 279.99
- **Billing period**: 1 week

#### Monthly Plan
- **Product ID**: `monthly_plan`
- **Name**: "Monthly Premium"
- **Description**: "Monthly premium subscription"
- **Price**: TRY 209.99
- **Billing period**: 1 month

#### Yearly Plan
- **Product ID**: `yearly_plan`
- **Name**: "Yearly Premium"
- **Description**: "Yearly premium subscription"
- **Price**: TRY 89.99
- **Billing period**: 1 year

### 4.3 Product Status
- Tüm product'ları "Active" yapın
- "Save" butonuna tıklayın

## 🔑 5. RevenueCat Product Mapping

### 5.1 Products Sekmesi
1. RevenueCat Dashboard'da "Products" sekmesine gidin
2. "Add Product" butonuna tıklayın

### 5.2 Product Eşleştirme
Her Google Play product'ı için:

1. **Product ID**: Google Play'deki Product ID'yi girin
2. **Product Type**: "Subscription" seçin
3. **Store**: "Google Play" seçin
4. **Product ID**: Google Play Product ID'yi seçin

### 5.3 Entitlements Oluşturma
1. "Entitlements" sekmesine gidin
2. "Add Entitlement" butonuna tıklayın
3. **Entitlement ID**: `premium_access`
4. **Display Name**: "Premium Access"
5. **Description**: "Access to premium features"

## 💻 6. Kod Entegrasyonu

### 6.1 RevenueCat Service Güncelleme
`lib/app/core/services/revenue_cat_service.dart` dosyasında API key'i güncelleyin:

```dart
class RevenueCatService {
  static const String _apiKey = 'YOUR_ACTUAL_REVENUECAT_API_KEY'; // Buraya gerçek API key'i yapıştırın
  
  // ... mevcut kod
}
```

### 6.2 Main.dart'ta Initialize
`lib/main.dart` dosyasında RevenueCat'i initialize edin:

```dart
import 'package:ginly/app/core/services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // RevenueCat initialize
  await RevenueCatService.initialize();
  
  runApp(MyApp());
}
```

### 6.3 Payment Plans Widget Güncelleme
`lib/app/features/payment/ui/widgets/payment_plans_widget.dart` dosyasında:

```dart
import 'package:ginly/app/core/services/revenue_cat_service.dart';

// ... mevcut kod

CustomGradientButton(
  title: AppLocalizations.of(context).subscribeNow,
  onTap: () async {
    // Seçili plana göre purchase yap
    final productId = _getSelectedProductId();
    final result = await RevenueCatService.purchaseProduct(productId);
    
    if (result != null) {
      // Başarılı purchase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription successful!')),
      );
    } else {
      // Başarısız purchase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed. Please try again.')),
      );
    }
  },
  isFilled: true,
),

String _getSelectedProductId() {
  switch (_selectedPlanIndex) {
    case 0:
      return 'weekly_plan';
    case 1:
      return 'monthly_plan';
    case 2:
      return 'yearly_plan';
    default:
      return 'yearly_plan';
  }
}
```

## 🧪 7. Test Etme

### 7.1 Test Cihazı Kurulumu
1. Fiziksel Android cihaz kullanın (emulator'da billing çalışmaz)
2. Google Play Store'a giriş yapın
3. Test hesabı oluşturun

### 7.2 Test Purchase
1. Uygulamayı test cihazında çalıştırın
2. Payment screen'e gidin
3. Bir plan seçin ve "Subscribe Now" butonuna tıklayın
4. Google Play billing dialog'u açılmalı
5. Test purchase yapın

### 7.3 Test Account
1. Google Play Console'da "Setup" > "License testing" sekmesine gidin
2. Test email adreslerini ekleyin
3. Bu hesaplarla test purchase yapın

## 🚨 8. Hata Ayıklama

### 8.1 Yaygın Hatalar

#### "Billing unavailable"
- Test cihazında Google Play Store güncel olmalı
- Internet bağlantısı kontrol edin
- Billing permission AndroidManifest.xml'de olmalı

#### "Product not found"
- Google Play Console'da product'lar "Active" olmalı
- Product ID'ler RevenueCat'te doğru eşleşmeli
- Test account ile giriş yapılmış olmalı

#### "Purchase failed"
- RevenueCat API key doğru olmalı
- Network bağlantısı kontrol edin
- Log'ları kontrol edin

### 8.2 Debug Logları
RevenueCat debug loglarını görmek için:

```dart
await Purchases.setLogLevel(LogLevel.debug);
```

## 📊 9. Analytics ve Monitoring

### 9.1 RevenueCat Dashboard
- Purchase metrics
- Revenue tracking
- User analytics
- Churn analysis

### 9.2 Google Play Console
- Sales reports
- Subscription metrics
- User acquisition
- Revenue analytics

## 🔒 10. Güvenlik

### 10.1 Server-Side Validation
- Purchase'ları server'da validate edin
- Receipt verification yapın
- Fraud detection implement edin

### 10.2 User Authentication
- Firebase Auth ile user ID'yi RevenueCat'e gönderin
- Anonymous user'ları handle edin

## 📱 11. Production Deployment

### 11.1 Final Checklist
- [ ] API key production'da güncellendi
- [ ] Product'lar Google Play'de "Active"
- [ ] RevenueCat'te product mapping tamamlandı
- [ ] Test purchase'lar başarılı
- [ ] Error handling implement edildi
- [ ] Analytics tracking aktif

### 11.2 Release
1. Google Play Console'da app'i review için gönderin
2. RevenueCat Dashboard'da metrics'leri izleyin
3. Production purchase'ları test edin

## 📞 12. Destek

### 12.1 RevenueCat Support
- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [RevenueCat Community](https://community.revenuecat.com/)
- [RevenueCat Support](https://www.revenuecat.com/support/)

### 12.2 Google Play Support
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Google Play Billing](https://developer.android.com/google/play/billing)

## 🎉 13. Sonuç

Bu rehberi takip ederek GINLY uygulamasına başarılı bir şekilde RevenueCat entegrasyonu yapabilirsiniz. 

**Önemli Notlar:**
- Test cihazında mutlaka test edin
- API key'leri güvenli tutun
- Production'da error handling'i implement edin
- Analytics'i aktif tutun

Başarılar! 🚀
