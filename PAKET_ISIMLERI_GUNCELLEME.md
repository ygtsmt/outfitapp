# 📦 Paket İsimleri Güncelleme Rehberi

## 🎯 **Yapılan Değişiklikler**

### **Eski Paket İsimleri:**
- `ginly_weekly` → `ginly_plus_weekly` (Plus)
- `ginly_monthly` → `ginly_pro_weekly` (Pro)
- `ginly_yearly` → `ginly_ultra_weekly` (Ultra)

### **Yeni Paket İsimleri:**
- **Plus** - 50 kredi/hafta - ₺50.00
- **Pro** - 150 kredi/hafta - ₺150.00  
- **Ultra** - 300 kredi/hafta - ₺300.00

## 🔧 **RevenueCat Dashboard Güncellemeleri**

### **1. Product ID'leri Güncelleme**
RevenueCat Dashboard → Products → Her ürün için:

```
Eski ID'ler:
- ginly_weekly (Weekly Plan)
- ginly_monthly (Monthly Plan)  
- ginly_yearly (Yearly Plan)

Yeni ID'ler:
- ginly_plus_weekly (Plus)
- ginly_pro_weekly (Pro)
- ginly_ultra_weekly (Ultra)
```

### **2. Product Names Güncelleme**
Her ürün için Display Name:

```
- ginly_plus_weekly → "Plus"
- ginly_pro_weekly → "Pro"
- ginly_ultra_weekly → "Ultra"
```

### **3. Product Descriptions Güncelleme**
Her ürün için Description:

```
- ginly_plus_weekly → "Haftalık 50 kredi paketi"
- ginly_pro_weekly → "Haftalık 150 kredi paketi"
- ginly_ultra_weekly → "Haftalık 300 kredi paketi"
```

### **4. Package Identifiers Güncelleme**
RevenueCat Dashboard → Offerings → default offering → Packages:

```
Eski:
- $rc_weekly (Weekly Plan)
- $rc_monthly (Monthly Plan)
- $rc_yearly (Yearly Plan)

Yeni:
- ginly_plus_weekly (Plus)
- ginly_pro_weekly (Pro)
- ginly_ultra_weekly (Ultra)
```

## 🏪 **Google Play Console Güncellemeleri**

### **1. Product ID'leri Güncelleme**
Google Play Console → Monetize → Products → In-app products:

```
Eski ID'ler:
- ginly_weekly (Weekly Plan)
- ginly_monthly (Monthly Plan)
- ginly_yearly (Yearly Plan)

Yeni ID'ler:
- ginly_plus_weekly (Plus)
- ginly_pro_weekly (Pro)
- ginly_ultra_weekly (Ultra)
```

### **2. Product Names Güncelleme**
Her ürün için Product name:

```
- ginly_plus_weekly → "Plus"
- ginly_pro_weekly → "Pro"
- ginly_ultra_weekly → "Ultra"
```

### **3. Product Descriptions Güncelleme**
Her ürün için Description:

```
- ginly_plus_weekly → "Haftalık 50 kredi paketi"
- ginly_pro_weekly → "Haftalık 150 kredi paketi"
- ginly_ultra_weekly → "Haftalık 300 kredi paketi"
```

## 📱 **Kod Güncellemeleri (Tamamlandı ✅)**

### **1. RevenueCatService**
- Product ID'ler güncellendi
- Fallback data Türkçe yapıldı
- Paket isimleri Türkçe yapıldı
- **Tüm paketler haftalık abonelik modeli**
- **Fiyat arttıkça daha çok kredi**: 50 → 150 → 300 kredi

### **2. PaymentPlansWidget**
- Product ID listesi güncellendi
- Fallback açıklamalar Türkçe yapıldı
- **Kredi miktarları güncellendi**: 50, 150, 300 kredi

### **3. PaymentPlanCard**
- "per week" yazısı kaldırıldı (tüm paketler haftalık)
- **Haftalık abonelik modeli**

## 🎯 **Yeni Haftalık Abonelik Sistemi**

### **Plus Paketi:**
- **Kredi**: 50 kredi/hafta
- **Fiyat**: ₺50.00
- **Özellik**: Başlangıç seviyesi

### **Pro Paketi:**
- **Kredi**: 150 kredi/hafta  
- **Fiyat**: ₺150.00
- **Özellik**: Orta seviye (3x kredi)

### **Ultra Paketi:**
- **Kredi**: 300 kredi/hafta
- **Fiyat**: ₺300.00
- **Özellik**: En üst seviye (6x kredi)

### **Kredi/Fiyat Oranı:**
- **Plus**: 1 kredi = ₺1.00
- **Pro**: 1 kredi = ₺1.00 (aynı oran)
- **Ultra**: 1 kredi = ₺1.00 (aynı oran)

**Not**: Tüm paketlerde kredi/fiyat oranı aynı, sadece miktar artıyor!

## ⚠️ **Önemli Notlar**

### **1. Test Hesabı Güncelleme**
Google Play Console'da test hesaplarını yeni product ID'ler ile güncelleyin.

### **2. RevenueCat Test**
RevenueCat Dashboard'da yeni product ID'ler ile test yapın.

### **3. Uygulama Test**
Uygulamayı test ederken yeni paket isimlerinin doğru göründüğünü kontrol edin.

## 🚀 **Test Adımları**

### **1. RevenueCat Test**
```
1. RevenueCat Dashboard'da yeni product ID'ler oluşturun
2. default offering'e yeni paketleri ekleyin
3. Test cihazında offerings'leri kontrol edin
```

### **2. Google Play Test**
```
1. Google Play Console'da yeni product ID'ler oluşturun
2. Test hesaplarını güncelleyin
3. Test cihazında satın alma işlemini test edin
```

### **3. Uygulama Test**
```
1. Uygulamayı çalıştırın
2. Payment screen'de yeni paket isimlerini kontrol edin
3. Satın alma işlemini test edin
4. Hata mesajlarını kontrol edin
```

## 📋 **Kontrol Listesi**

- [ ] RevenueCat Dashboard'da product ID'ler güncellendi
- [ ] Google Play Console'da product ID'ler güncellendi
- [ ] RevenueCat Dashboard'da package identifiers güncellendi
- [ ] Test hesapları yeni product ID'ler ile güncellendi
- [ ] Uygulamada yeni paket isimleri görünüyor
- [ ] Satın alma işlemi çalışıyor
- [ ] Hata mesajları kontrol edildi

## 🔍 **Hata Durumunda**

### **Yaygın Hatalar:**
1. **"No products found"** → Product ID'ler eşleşmiyor
2. **"Configuration error"** → RevenueCat'te product ID'ler eksik
3. **"Product not found"** → Google Play'de product ID'ler eksik

### **Çözüm:**
1. Product ID'lerin her yerde aynı olduğunu kontrol edin
2. RevenueCat ve Google Play Console'da eşleşmeyi kontrol edin
3. Test hesaplarını güncelleyin

---

**Not:** Tüm değişiklikler yapıldıktan sonra uygulamayı test etmeyi unutmayın! 🚀
