# Xcode Apple Sign-In Setup Guide

## 🚨 Önemli: Xcode'da Apple Sign-In Capability'sini Ekleyin

Apple Sign-In'in çalışması için Xcode'da capability'yi eklemeniz gerekiyor. İşte adım adım rehber:

### 1. Xcode'u Açın
```bash
open ios/Runner.xcworkspace
```

### 2. Runner Target'ını Seçin
1. Xcode'da sol panelde **Runner** projesini seçin
2. **Runner** target'ını seçin (mavi ikon)

### 3. Signing & Capabilities Sekmesine Gidin
1. **Signing & Capabilities** sekmesine tıklayın
2. **+ Capability** butonuna tıklayın

### 4. Apple Sign-In'i Ekleyin
1. Arama kutusuna "Sign In with Apple" yazın
2. **Sign In with Apple**'ı seçin
3. **Add** butonuna tıklayın

### 5. Doğrulayın
- **Sign In with Apple** capability'sinin eklendiğini görün
- **Team** ve **Bundle Identifier**'ın doğru olduğundan emin olun

## 🔧 Simulator'da Test Etme

### Simulator'da Apple Sign-In Test
1. iOS Simulator'da uygulamayı çalıştırın
2. Login ekranına gidin
3. Apple butonuna tıklayın
4. Apple Sign-In dialog'u açılmalı

### Simulator'da Apple ID Oluşturma
1. Simulator'da **Settings** > **Sign in to your iPhone**
2. **Don't have an Apple ID or forgot it?** seçin
3. **Create Apple ID** seçin
4. Test için bir Apple ID oluşturun

## 📱 Gerçek Cihazda Test

### Gerçek Cihazda Test
1. Gerçek bir iOS cihazında uygulamayı çalıştırın
2. Apple ID ile giriş yapmayı deneyin
3. Firebase Console'da kullanıcının oluşturulduğunu kontrol edin

## 🆘 Sorun Giderme

### Yaygın Hatalar ve Çözümleri

#### 1. "Sign in with Apple is not configured"
**Çözüm**: Xcode'da Apple Sign-In capability'sini ekleyin

#### 2. "The operation couldn't be completed"
**Çözüm**: 
- Simulator'da Apple ID oluşturun
- Gerçek cihazda test edin

#### 3. "Invalid client"
**Çözüm**: 
- Firebase Console'da Apple provider ayarlarını kontrol edin
- Service ID'nin doğru olduğundan emin olun

#### 4. Build Hatası
**Çözüm**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

## 📋 Kontrol Listesi

- [ ] Xcode'da Apple Sign-In capability'si eklendi
- [ ] Bundle Identifier doğru
- [ ] Team seçimi doğru
- [ ] Simulator'da Apple ID var
- [ ] Firebase Console'da Apple provider etkin
- [ ] Apple Developer Console'da capability etkin

## 🎯 Sonraki Adımlar

1. **Xcode'da capability'yi ekleyin** (yukarıdaki adımları takip edin)
2. **Simulator'da test edin**
3. **Gerçek cihazda test edin**
4. **Firebase Console ayarlarını tamamlayın**
5. **Apple Developer Console ayarlarını yapın**

## 💡 İpucu

Apple Sign-In capability'si eklendikten sonra, uygulama yeniden build edilmelidir. Bu yüzden:

```bash
flutter clean
flutter pub get
flutter run
```

komutlarını çalıştırın. 