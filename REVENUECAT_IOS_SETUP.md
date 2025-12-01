# 📱 RevenueCat iOS Entegrasyonu - Detaylı Kurulum Rehberi

Bu dokümantasyon, GINLY uygulamasına iOS için RevenueCat in-app purchase sisteminin nasıl entegre edileceğini adım adım açıklar.

## 🎯 **Gereksinimler**

- Apple Developer hesabı
- App Store Connect erişimi
- RevenueCat hesabı
- Xcode (en son sürüm)

## 🚀 **1. RevenueCat iOS Proje Kurulumu**

### 1.1 RevenueCat Dashboard'a Giriş
1. [RevenueCat Dashboard](https://app.revenuecat.com/) adresine gidin
2. Mevcut projenizi seçin veya yeni proje oluşturun
3. **iOS** platformunu seçin

### 1.2 iOS App Store Connect Entegrasyonu
1. **App Store Connect** sekmesine gidin
2. **Bundle ID**'yi girin: `com.yourcompany.ginly` (gerçek bundle ID'nizi kullanın)
3. **App Store Connect API Key** oluşturun:
   - App Store Connect → Users and Access → Keys
   - **Generate API Key** butonuna tıklayın
   - **App Manager** rolünü seçin
   - **Generate** butonuna tıklayın
   - `.p8` dosyasını indirin ve güvenli bir yerde saklayın

### 1.3 RevenueCat'e App Store Connect API Key Yükleme
1. RevenueCat Dashboard'a geri dönün
2. **App Store Connect** sekmesinde **Upload API Key** butonuna tıklayın
3. İndirdiğiniz `.p8` dosyasını yükleyin
4. **Key ID** ve **Issuer ID**'yi girin

## 🔑 **2. iOS Product ID'leri Oluşturma**

### 2.1 App Store Connect'te Products
1. **App Store Connect** → **My Apps** → **Ginly AI**
2. **Features** → **In-App Purchases**
3. **Create** butonuna tıklayın
4. **Auto-Renewable Subscription** seçin

### 2.2 Subscription Group Oluşturma
1. **Subscription Group** oluşturun: `ginly_subscriptions`
2. **Reference Name**: "Ginly AI Subscriptions"
3. **Group ID**: `ginly_subscriptions`

### 2.3 Subscription Plans Oluşturma
1. **Weekly Plan**:
   - **Product ID**: `ginly_weekly_plan`
   - **Reference Name**: "Weekly Plan"
   - **Subscription Duration**: 1 Week
   - **Price**: $4.99

2. **Monthly Plan**:
   - **Product ID**: `ginly_monthly_plan`
   - **Reference Name**: "Monthly Plan"
   - **Subscription Duration**: 1 Month
   - **Price**: $14.99

3. **Yearly Plan**:
   - **Product ID**: `ginly_yearly_plan`
   - **Reference Name**: "Yearly Plan"
   - **Subscription Duration**: 1 Year
   - **Price**: $99.99

## 📱 **3. iOS Uygulama Konfigürasyonu**

### 3.1 Info.plist Güncellemeleri
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v79kvwwj4g.skadnetwork</string>
    </dict>
</array>
<key>NSUserTrackingUsageDescription</key>
<string>Bu uygulama, size kişiselleştirilmiş reklamlar sunmak için reklam tanımlayıcı bilgilerini kullanır.</string>
```

### 3.2 RevenueCatService Güncellemesi
```dart
// Platform-specific API keys
static const String _androidApiKey = 'goog_PfQiIBdbkajdOPOvCtFgXAVVhuQ';
static const String _iosApiKey = 'appl_iskOhAaeCoaLtHnuQTitucvJCng'; // iOS için RevenueCat API key'i buraya gelecek
```

### 3.3 iOS API Key'i Alma
1. RevenueCat Dashboard → **Project Settings** → **API Keys**
2. **iOS** API key'ini kopyalayın
3. `_iosApiKey` değişkenine yapıştırın

## 🧪 **4. Test ve Doğrulama**

### 4.1 Sandbox Test
1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. Yeni test kullanıcısı oluşturun
3. iOS Simulator veya test cihazında test edin

### 4.2 RevenueCat Test
1. RevenueCat Dashboard'da **Debugger** sekmesini açın
2. Test cihazından purchase yapın
3. Event'leri gerçek zamanlı olarak izleyin

## 🔧 **5. iOS-Specific Özellikler**

### 5.1 Receipt Validation
```dart
// iOS için App Store receipt validation
static Future<bool> validateReceipt() async {
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    }
    return false;
  } catch (e) {
    debugPrint('❌ iOS receipt validation failed: $e');
    return false;
  }
}
```

### 5.2 Subscription Status
```dart
// iOS için subscription status kontrolü
static Future<Map<String, dynamic>> getIOSSubscriptionStatus() async {
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlements = customerInfo.entitlements.active;
      
      return {
        'isSubscribed': entitlements.isNotEmpty,
        'activeEntitlements': entitlements.keys.toList(),
        'expirationDate': entitlements.values.firstOrNull?.expirationDate?.toIso8601String() ?? '',
        'willRenew': entitlements.values.firstOrNull?.willRenew ?? false,
      };
    }
    return {};
  } catch (e) {
    debugPrint('❌ iOS subscription status check failed: $e');
    return {};
  }
}
```

## 🚨 **6. Hata Giderme**

### 6.1 Yaygın Hatalar
1. **"Configuration error"** → RevenueCat'te product ID'ler eksik
2. **"Invalid receipt"** → Sandbox test kullanıcısı ile test edin
3. **"Product not found"** → App Store Connect'te product'ları kontrol edin

### 6.2 Debug Logları
```dart
await Purchases.setLogLevel(LogLevel.debug);
```

## 📊 **7. Monitoring ve Analytics**

### 7.1 RevenueCat Dashboard
- **Revenue** → Subscription metrics
- **Users** → Active subscribers
- **Events** → Purchase events

### 7.2 App Store Connect
- **Sales and Trends** → Revenue analytics
- **App Analytics** → User engagement

## 🔒 **8. Güvenlik ve Compliance**

### 8.1 App Store Guidelines
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [In-App Purchase Guidelines](https://developer.apple.com/in-app-purchase/)

### 8.2 Privacy
- **App Tracking Transparency** (ATT) framework
- **SKAdNetwork** integration
- **User consent** management

## 📚 **9. Kaynaklar ve Destek**

### 9.1 Dokümantasyon
- [RevenueCat iOS Documentation](https://docs.revenuecat.com/docs/ios)
- [Apple In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)

### 9.2 Topluluk
- [RevenueCat Community](https://community.revenuecat.com/)
- [Apple Developer Forums](https://developer.apple.com/forums/)

## ✅ **10. Kontrol Listesi**

- [ ] RevenueCat iOS projesi oluşturuldu
- [ ] App Store Connect API key yüklendi
- [ ] Product ID'ler App Store Connect'te oluşturuldu
- [ ] RevenueCat'te product mapping tamamlandı
- [ ] iOS API key RevenueCatService'e eklendi
- [ ] Info.plist güncellemeleri yapıldı
- [ ] Sandbox test kullanıcısı oluşturuldu
- [ ] Test purchase'ları başarılı
- [ ] Receipt validation çalışıyor
- [ ] Subscription status kontrolü çalışıyor

Bu rehberi takip ederek GINLY uygulamasına başarılı bir şekilde iOS RevenueCat entegrasyonu yapabilirsiniz.
