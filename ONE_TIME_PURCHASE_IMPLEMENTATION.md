# 🚀 One-Time Purchase Implementation Guide

## 📱 **RevenueCat Dashboard Yapılacakları:**

### **1. Products Ekleme:**
- **Product Type:** `Consumable` (tüketilebilir - tekrar satın alınabilir)
- **Product IDs (Platform Bağımsız):**
  - `ginly_starter_credit` (iOS & Android)
  - `ginly_extra_credit` (iOS & Android)
  - `ginly_boost_credit` (iOS & Android)
  - `ginly_mega_credit` (iOS & Android)

### **2. Offerings Oluşturma:**
- **Offering Name:** `credit_packages`
- **Packages:** Her kredi paketi için ayrı package oluştur
- **Display Name:** "Ginly Starter", "Ginly Extra", "Ginly Boost", "Ginly Mega"

### **3. Platform Bağımsız Avantajları:**
- **Tek Product ID:** Her platform için aynı ID
- **Kolay Yönetim:** RevenueCat'te tek product
- **Daha Az Hata:** Platform karışıklığı yok
- **Temiz Kod:** Platform kontrolü gerekmez

### **4. Pricing (Bütçe Dostu):**
- **Ginly Starter (25 Kredi):** \$1.99 - Çok düşük fiyat ile başlangıç
- **Ginly Extra (75 Kredi):** \$4.99 - Orta seviye paket
- **Ginly Boost (200 Kredi):** \$9.99 - Popüler paket
- **Ginly Mega (500 Kredi):** \$19.99 - Premium paket

## 🔧 **Flutter Kod Yapılacakları:**

### **1. RevenueCatService Güncelleme:**
- `purchaseOneTimeProduct()` method'u ekle
- `getOneTimeProductDetails()` method'u ekle
- Platform bazlı product ID mapping

### **2. Payment Models:**
- `OneTimeProduct` model'i oluştur
- `OneTimePurchaseState` enum'u ekle

### **3. UI Components:**
- `CreditPackagesWidget` oluştur
- `CreditPackageCard` oluştur
- Subscription kontrolü ile görünürlük

### **4. Business Logic:**
- Subscription kullanıcıları için ekstra kredi satın alma
- Non-subscription kullanıcıları için gizleme
- Kredi ekleme sistemi

## 📊 **Kullanıcı Kategorileri:**

### **Free Users:**
- Sadece reklam izleyerek kredi kazanır
- One-time purchase görmez

### **Subscription Users:**
- Reklam izleyerek kredi kazanır
- Ekstra kredi paketleri satın alabilir
- Premium özellikler

## 💰 **Bütçe Dostu Yaklaşım:**

### **Free Trial Olmadan:**
- **Ginly Starter:** \$1.99 ile çok düşük fiyat
- Kullanıcılar risk almadan deneyebilir
- Düşük bariyer ile giriş yapabilir

### **Consumable Ürünler:**
- Krediler tüketildikten sonra tekrar satın alınabilir
- Her kullanımda kredi azalır
- Kullanıcılar ihtiyaç duydukça tekrar alabilir
- Sürekli gelir modeli

### **Kademeli Fiyatlandırma:**
- Starter: \$1.99 (25 kredi) - Giriş seviyesi
- Extra: \$4.99 (75 kredi) - Orta seviye
- Boost: \$9.99 (200 kredi) - Popüler
- Max: \$19.99 (500 kredi) - Premium

## 🎯 **Sonuç:**
- **Bütçe dostu:** \$1.99 ile başlangıç
- **Free trial yok:** Maliyet düşük
- **Kademeli artış:** Kullanıcılar yavaş yavaş yükselir
- **Consumable ürünler:** Tekrar tekrar satın alınabilir
- **Subscription kullanıcıları için ek gelir**
- **Free kullanıcıları subscription'a yönlendirme**
- **Daha iyi kullanıcı deneyimi**
- **Sürekli gelir modeli**

---

**Not:** Bu guide'ı takip ederek hem iOS hem Android için one-time purchase sistemi kurulacak.
