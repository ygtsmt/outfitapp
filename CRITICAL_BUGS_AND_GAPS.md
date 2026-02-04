# 🐛 Comby - Kalan Kritik Bug ve Eksikler

**Tarih:** 4 Şubat 2026  
**Amaç:** Hackathon demo'su ve production için kalan sorunları tespit etmek

> ✅ **Tamamlanan kritik görevler** [COMPLETED_CRITICAL_BUGS.md](./COMPLETED_CRITICAL_BUGS.md) dosyasına taşındı.

---

## 🟡 ORTA ÖNCELİKLİ SORUNLAR

### 5. **API Rate Limits Kontrolü Yok**
**Dosya:** `lib/app/features/fal_ai/data/fal_ai_usecase.dart`

**Sorun:**
- Fal.AI API limiti aşıldığında uygulama crash olabilir
- Gemini API quota kontrolü yok
- OpenWeatherMap free tier limiti (60 call/min)

**Çözüm:**
- [ ] API call counter ekle
- [ ] Rate limit aşımında kullanıcıya bilgi ver
- [ ] Retry mechanism ekle (exponential backoff)

**Öncelik:** 🟡 ORTA  
**Tahmini Süre:** 3 saat  
**Etki:** Demo sırasında API limiti aşımı riski

---

### 6. **Live Stylist - Bağlantı Kopması Handling**
**Dosya:** `lib/app/features/live_stylist/cubit/live_stylist_cubit.dart`

**Sorun:**
- WebSocket bağlantısı koptuğunda otomatik reconnect yok
- Kullanıcı manuel olarak yeniden başlatmak zorunda

**Çözüm:**
- [ ] Auto-reconnect logic ekle
- [ ] Connection status indicator ekle
- [ ] Graceful degradation (bağlantı yoksa text-only mode)

**Öncelik:** 🟡 ORTA  
**Tahmini Süre:** 2 saat  
**Etki:** Kullanıcı deneyimi

---

### 7. **Gardırop Boş Olduğunda UX**
**Dosya:** `lib/core/services/agent_service.dart` (Line 404-407)

**Sorun:**
```dart
'message': filteredItems.isEmpty
    ? 'Gardıroptan uygun parça bulunamadı'
    : '...'
```

Gardırop boşsa agent sadece "bulunamadı" diyor, kullanıcıya yönlendirme yok.

**Çözüm:**
- [ ] Boş gardırop durumunda onboarding'e yönlendir
- [ ] "Hemen kıyafet ekle" butonu göster
- [ ] Örnek kıyafetlerle demo mode sun

**Öncelik:** 🟡 ORTA  
**Tahmini Süre:** 1 saat  
**Etki:** İlk kullanıcı deneyimi

---

### 8. **Virtual Try-On - Model Yoksa Fallback**
**Dosya:** `lib/core/services/agent_service.dart` (Line 464-468)

**Sorun:**
```dart
} else {
  log('⚠️ Kullanıcı modeli bulunamadı, varsayılan AI model kullanılacak.');
  // Eğer kullanıcı modeli yoksa, User Profile'dan cinsiyet çekip modelAiPrompt oluşturabiliriz
  // Şimdilik null bırakıyoruz
}
```

Kullanıcı kendi fotoğrafını yüklemediyse Virtual Try-on çalışmıyor.

**Çözüm:**
- [ ] Default model library ekle (erkek/kadın)
- [ ] Kullanıcıya "Kendi fotoğrafını yükle" prompt'u göster
- [ ] Generic model ile deneme yap

**Öncelik:** 🟡 ORTA  
**Tahmini Süre:** 2 saat  
**Etki:** Feature kullanılabilirliği

---

## 🟢 DÜŞÜK ÖNCELİKLİ İYİLEŞTİRMELER

### 9. **Performance - Image Optimization**
**Sorun:**
- Gardırop fotoğrafları optimize edilmeden yükleniyor
- Live Stylist frame rate düşük olabilir

**Çözüm:**
- [ ] Image compression ekle
- [ ] Lazy loading uygula
- [ ] Frame sampling rate'i optimize et

**Öncelik:** 🟢 DÜŞÜK  
**Tahmini Süre:** 3 saat

---

### 10. **Analytics ve Logging**
**Sorun:**
- Kullanıcı davranışları track edilmiyor
- Crash reporting yok
- Tool calling success rate bilinmiyor

**Çözüm:**
- [ ] Firebase Analytics ekle
- [ ] Crashlytics entegre et
- [ ] Custom event tracking

**Öncelik:** 🟢 DÜŞÜK  
**Tahmini Süre:** 2 saat

---

### 11. **Offline Mode**
**Sorun:**
- İnternet yoksa uygulama tamamen kullanılamaz
- Cached data yok

**Çözüm:**
- [ ] Gardırop verilerini local cache'le
- [ ] Offline mode indicator ekle
- [ ] "Bağlantı gerekli" mesajı göster

**Öncelik:** 🟢 DÜŞÜK  
**Tahmini Süre:** 4 saat

---

## 📋 DEMO ÖNCESİ YAPILACAKLAR LİSTESİ

### ✅ Minimum Viable Demo - **TAMAMLANDI**
- [x] ⭐ Syntax error düzeltildi
- [x] ⭐ System instruction İngilizce'ye çevir
- [x] ⭐ Tool descriptions İngilizce'ye çevir
- [x] ⭐ Live Agent instruction İngilizce
- [ ] **ŞİMDİ:** Test - İngilizce konuşma senaryosu (30 dk)

### Recommended Demo (7-8 saat)
- [ ] API rate limit kontrolü (3 saat) 🟡
- [ ] Live Stylist reconnect logic (2 saat) 🟡
- [ ] Error messages İngilizce (2 saat) 🟡

### Ideal Demo (12+ saat)
- [ ] Boş gardırop UX (1 saat) 🟡
- [ ] Virtual Try-on fallback (2 saat) 🟡
- [ ] Image optimization (3 saat) 🟢

---

## 🎯 ÖNERİLEN EYLEM PLANI

### ✅ Bugün (4 Şubat) - Kritik Görevler **TAMAMLANDI**

### **ŞİMDİ: Test** (30 dk - 1 saat)
- [ ] İngilizce konuşma testi
- [ ] Tool calling testi
- [ ] Live Stylist testi

### Yarın (5 Şubat) - Opsiyonel İyileştirmeler
1. **Error Messages İngilizce** (2 saat) - Opsiyonel
2. **API Rate Limit Kontrolü** (1 saat) - Önerilen

---

## 🚨 KRİTİK UYARILAR

1. ✅ ~~Dil Sorunu~~ **ÇÖZÜLDİ!**

2. **API Limitleri:** Demo sırasında Fal.AI veya Gemini limiti aşılırsa crash olur. Test sırasında dikkat et.

3. **Live Stylist Stability:** Bağlantı koparsa kullanıcı deneyimi bozulur. Test ederken kontrol et.

4. **Boş Gardırop:** Jüri yeni hesap açarsa gardırop boş olacak. Demo için örnek data hazırla.

---
