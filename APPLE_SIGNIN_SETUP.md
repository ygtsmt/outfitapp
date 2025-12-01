# Apple Sign-In Setup Guide

Bu rehber, Flutter uygulamanızda Apple Sign-In'i Firebase ile entegre etmek için gerekli adımları içerir.

## 1. Firebase Console Ayarları

### 1.1 Apple Sign-In Provider'ı Etkinleştirin
1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin
3. **Authentication** > **Sign-in method** bölümüne gidin
4. **Apple** provider'ını etkinleştirin
5. **Service ID**'yi kaydedin (örnek: `com.ginowl.ginlyai.signin`)

### 1.2 Apple Developer Console Ayarları
1. [Apple Developer Console](https://developer.apple.com/account/)'a gidin
2. **Certificates, Identifiers & Profiles** > **Identifiers** bölümüne gidin
3. Uygulamanızın App ID'sini seçin
4. **Sign In with Apple** capability'sini etkinleştirin
5. **Services IDs** bölümünde yeni bir Service ID oluşturun:
   - **Description**: Ginly Apple Sign-In
   - **Identifier**: `com.ginowl.ginlyai.signin` (Firebase'de kullandığınız Service ID)
   - **Domains and Subdomains**: Firebase domain'inizi ekleyin
   - **Return URLs**: Firebase'den aldığınız return URL'yi ekleyin

### 1.3 Private Key Oluşturma
1. Apple Developer Console'da **Keys** bölümüne gidin
2. **+** butonuna tıklayın
3. **Sign In with Apple**'ı seçin
4. Key'i indirin ve güvenli bir yerde saklayın
5. **Key ID**'yi not edin

## 2. iOS Proje Ayarları

### 2.1 Xcode'da Apple Sign-In Capability'sini Ekleyin
1. Xcode'da `ios/Runner.xcworkspace` dosyasını açın
2. **Runner** target'ını seçin
3. **Signing & Capabilities** sekmesine gidin
4. **+ Capability** butonuna tıklayın
5. **Sign In with Apple**'ı ekleyin

### 2.2 Info.plist Güncellemeleri
Aşağıdaki ayarları `ios/Runner/Info.plist` dosyasına ekleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.793286859298-edjsvaqntppgldlrjkhsj2kds7kc2j8a</string>
    </array>
  </dict>
</array>
```

## 3. Firebase Console'da Apple Provider Ayarları

Firebase Console'da Apple provider ayarlarını şu şekilde yapılandırın:

- **Service ID**: `com.ginowl.ginlyai.signin`
- **Apple Team ID**: Apple Developer Team ID'niz
- **Key ID**: Oluşturduğunuz private key'in ID'si
- **Private Key**: İndirdiğiniz .p8 dosyasının içeriği

## 4. Test Etme

### 4.1 Simulator'da Test
1. iOS Simulator'da uygulamayı çalıştırın
2. Login ekranında Apple butonuna tıklayın
3. Apple Sign-In dialog'u açılmalı

### 4.2 Gerçek Cihazda Test
1. Gerçek bir iOS cihazında uygulamayı çalıştırın
2. Apple ID ile giriş yapmayı deneyin
3. Firebase Authentication'da kullanıcının oluşturulduğunu kontrol edin

## 5. Sorun Giderme

### 5.1 Yaygın Hatalar
- **"Sign in with Apple is not configured"**: Apple Developer Console'da capability'nin etkin olduğundan emin olun
- **"Invalid client"**: Service ID'nin doğru olduğundan emin olun
- **"Invalid key"**: Private key'in doğru formatta olduğundan emin olun

### 5.2 Debug İpuçları
- Firebase Console'da Authentication > Users bölümünü kontrol edin
- Xcode console'da hata mesajlarını kontrol edin
- Apple Developer Console'da certificate ve key'lerin geçerli olduğundan emin olun

## 6. Production Deployment

### 6.1 App Store Connect
1. App Store Connect'te uygulamanızı yapılandırın
2. **App Information** > **Sign In with Apple** bölümünde gerekli ayarları yapın

### 6.2 TestFlight
1. TestFlight'ta Apple Sign-In'i test edin
2. Gerçek Apple ID'lerle test yapın

## 7. Kod İncelemesi

Uygulamanızda Apple Sign-In şu şekilde çalışır:

1. **LoginBloc**: Apple Sign-In event'ini handle eder
2. **LoginUseCase**: Apple Sign-In işlemini gerçekleştirir
3. **Firebase**: Apple'dan gelen credential'ları doğrular
4. **User Creation**: Başarılı giriş sonrası kullanıcı oluşturulur

## 8. Güvenlik Notları

- Private key'i asla kod içinde saklamayın
- Service ID'yi güvenli tutun
- Apple Developer Console'da düzenli olarak certificate'ları kontrol edin
- Firebase Security Rules'ı uygun şekilde yapılandırın

## 9. Destek

Herhangi bir sorunla karşılaşırsanız:
1. Firebase Console loglarını kontrol edin
2. Apple Developer Console'da certificate durumunu kontrol edin
3. Xcode console'da hata mesajlarını inceleyin
4. Flutter doctor ile environment'ı kontrol edin 