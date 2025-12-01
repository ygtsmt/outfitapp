# 🔄 Paket Adı Değişikliği Rehberi

## ✅ Otomatik Tamamlanan İşlemler

Aşağıdaki değişiklikler **otomatik olarak yapıldı**:

### Android
- ✅ `android/app/build.gradle.kts` → `namespace` ve `applicationId` güncellendi
- ✅ **Eski**: `com.ginly.app` → **Yeni**: `com.ginowl.ginlyai`

### iOS  
- ✅ `ios/Runner.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER` güncellendi
- ✅ **Eski**: `com.ginly.app` → **Yeni**: `com.ginowl.ginlyai`

---

## 🔧 Manuel Yapılması Gereken İşlemler

### 1. 🔥 Firebase Yapılandırması

#### A. Firebase Console'da Yeni App Ekleme

**🌐 Firebase Console**: https://console.firebase.google.com/

1. **Projen**: `disciplify-26970` açın
2. **Project Settings** → **General** sekmesi
3. **Your apps** bölümünde **Add app** butonuna tıklayın

#### B. Android App Ekleme

1. **Android** ikonuna tıklayın
2. **Package name**: `com.ginowl.ginlyai` yazın
3. **App nickname**: `Ginly AI` (isteğe bağlı)
4. **SHA-1 signing certificate**: Mevcut keystore'unuzdan alın
5. **Register app** butonuna tıklayın
6. **google-services.json** dosyasını indirin
7. İndirilen dosyayı `android/app/google-services.json` ile değiştirin

#### C. iOS App Ekleme

1. **iOS** ikonuna tıklayın  
2. **Bundle ID**: `com.ginowl.ginlyai` yazın
3. **App nickname**: `Ginly AI` (isteğe bağlı)
4. **App Store ID**: Henüz yok (boş bırakın)
5. **Register app** butonuna tıklayın
6. **GoogleService-Info.plist** dosyasını indirin
7. İndirilen dosyayı `ios/Runner/GoogleService-Info.plist` ile değiştirin

---

### 2. 🔐 Google Sign-In Yapılandırması

#### A. Google Cloud Console

**🌐 Google Cloud Console**: https://console.cloud.google.com/

1. **Proje**: `disciplify-26970` seçin
2. **APIs & Services** → **Credentials**
3. **OAuth 2.0 Client IDs** bölümünde mevcut client'ları kontrol edin

#### B. Android OAuth Client

1. **Android** client'ını bulun
2. **Package name**: `com.ginowl.ginlyai` olarak güncelleyin
3. **SHA-1 fingerprint**'i keystore'unuzdan alıp ekleyin

```bash
# SHA-1 fingerprint almak için:
keytool -list -v -keystore your-keystore-file.jks -alias your-key-alias
```

#### C. iOS OAuth Client

1. **iOS** client'ını bulun
2. **Bundle ID**: `com.ginowl.ginlyai` olarak güncelleyin

---

### 3. 🍎 Apple Sign-In Yapılandırması

#### A. Apple Developer Console

**🌐 Apple Developer**: https://developer.apple.com/account/

1. **Certificates, Identifiers & Profiles** → **Identifiers**
2. **App IDs** bölümünde yeni App ID oluşturun:
   - **Bundle ID**: `com.ginowl.ginlyai`
   - **Description**: `Ginly AI`
   - **Capabilities**: `Sign In with Apple` seçin

#### B. Service ID Oluşturma

1. **Services IDs** bölümünde **+** butonuna tıklayın
2. **Identifier**: `com.ginowl.ginlyai.service`
3. **Description**: `Ginly AI Service`
4. **Configure** butonuna tıklayın
5. **Primary App ID**: Yukarıda oluşturduğunuz App ID'yi seçin

---

### 4. 📦 App Store Connect

#### A. Yeni App Oluşturma

**🌐 App Store Connect**: https://appstoreconnect.apple.com/

1. **My Apps** → **+** butonuna tıklayın
2. **New App** seçin
3. **Bundle ID**: `com.ginowl.ginlyai` seçin
4. **SKU**: Benzersiz bir SKU girin
5. **App Name**: `Ginly AI` veya istediğiniz isim

---

### 5. 🔑 Keystore ve Signing

#### A. Debug Keystore

Debug için varsayılan keystore kullanılabilir, değişiklik gerekmez.

#### B. Release Keystore

Eğer yeni keystore oluşturacaksanız:

```bash
keytool -genkey -v -keystore ginlyai-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ginlyai
```

#### C. key.properties Güncellemesi

`android/key.properties` dosyasını güncelleyin:

```properties
storePassword=your_store_password
keyPassword=your_key_password  
keyAlias=ginlyai
storeFile=../ginlyai-release-key.jks
```

---

### 6. 🏪 Play Store Console

#### A. Yeni App Oluşturma

**🌐 Play Console**: https://play.google.com/console/

1. **All apps** → **Create app**
2. **App name**: `Ginly AI`
3. **Default language**: Türkçe veya İngilizce
4. **App or game**: App
5. **Free or paid**: Seçiminize göre

#### B. App Bundle Upload

Yeni paket adıyla build aldıktan sonra:

```bash
flutter build appbundle --release
```

---

### 7. 🔄 Build ve Test

#### A. Clean Build

```bash
# Flutter cache temizle
flutter clean
flutter pub get

# Android
cd android && ./gradlew clean && cd ..

# iOS  
cd ios && rm -rf Pods/ Podfile.lock && pod install && cd ..
```

#### B. Test Build

```bash
# Debug build test
flutter run

# Release build test
flutter build apk --release
flutter build ios --release
```

---

### 8. 📋 Kontrol Listesi

Tüm işlemler tamamlandıktan sonra kontrol edin:

- [ ] Firebase Console'da yeni app'ler eklenmiş
- [ ] `google-services.json` ve `GoogleService-Info.plist` güncellenmiş
- [ ] Google Sign-In OAuth client'ları güncellenmiş
- [ ] Apple Developer'da App ID oluşturulmuş
- [ ] App Store Connect'te app oluşturulmuş
- [ ] Play Console'da app oluşturulmuş
- [ ] Debug build çalışıyor
- [ ] Release build çalışıyor
- [ ] Google Sign-In test edilmiş
- [ ] Apple Sign-In test edilmiş
- [ ] Firebase Auth çalışıyor
- [ ] Firebase Storage çalışıyor
- [ ] Firebase Firestore çalışıyor

---

### 9. 🚨 Önemli Notlar

#### ⚠️ Veri Kaybı Riski

- **Eski app verileriniz yeni app'e taşınmaz**
- **Kullanıcılar yeni app'i indirmek zorunda**
- **Firebase projelerini birleştirme mümkün değil**

#### 🔄 Migration Stratejisi

Eğer mevcut kullanıcılarınız varsa:
1. **Soft launch**: Yeni app'i beta olarak yayınlayın
2. **Data export**: Eski Firebase'den veri export edin
3. **Import**: Yeni Firebase'e import edin
4. **User communication**: Kullanıcıları bilgilendirin

#### 🔐 Güvenlik

- **API Keys**: Yeni app için yeni API key'ler kullanın
- **OAuth Secrets**: Yeni client secret'lar oluşturun
- **Keystore**: Güvenli yerde saklayın ve backup alın

---

### 10. 📞 Destek

Sorun yaşarsanız:

1. **Firebase Support**: https://firebase.google.com/support/
2. **Google Cloud Support**: https://cloud.google.com/support/
3. **Apple Developer Support**: https://developer.apple.com/support/
4. **Flutter Docs**: https://docs.flutter.dev/deployment/

---

## 🎉 Başarıyla Tamamlandığında

Tüm işlemler bittiğinde:

- ✅ Yeni paket adıyla app çalışacak
- ✅ Play Store'a yeni app olarak yükleyebileceksiniz
- ✅ App Store'a yeni app olarak submit edebileceksiniz
- ✅ Tüm Firebase özellikleri çalışacak
- ✅ Google ve Apple Sign-In çalışacak

**Not**: Bu işlem geri alınamaz, bu yüzden tüm adımları dikkatli takip edin!
