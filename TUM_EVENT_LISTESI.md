# 📊 TÜM EVENT LİSTESİ (80+ Event)

## ✅ ŞU AN YERLEŞTIRILMIŞ OLANLAR

### 1. APP BAŞLANGIÇ (1)
- ✅ `app_opened` - main.dart

### 2. SPLASH (8)
- ✅ `splash_started`
- ✅ `splash_progress` (6 aşama: initialization, bloc_data_fetch, theme_loaded, language_loaded, ads_initialized, revenuecat_initialized, completed)
- ✅ `splash_completed`
- ✅ `splash_error`

### 3. LOGIN EKRANI (7)
- ✅ `login_screen_viewed`
- ✅ `login_screen_exited`
- ✅ `login_attempt_started`
- ✅ `login_success`
- ✅ `session_linked_to_user` (otomatik)
- ✅ `login_failed`
- ❌ `login_button_clicked` - HENÜZ YERLEŞTİRİLMEDİ

### 4. SIGNUP EKRANI (6)
- ✅ `signup_screen_viewed`
- ✅ `signup_screen_exited`
- ✅ `signup_attempt_started`
- ✅ `signup_success`
- ✅ `signup_failed`
- ❌ `signup_button_clicked` - HENÜZ YERLEŞTİRİLMEDİ

### 5. HOME EKRANI (2)
- ✅ `home_screen_reached`
- ❌ `tab_changed` - HENÜZ YERLEŞTİRİLMEDİ

---

## ❌ HENÜZ YERLEŞTİRİLMEYENLER (65+ Event)

### 🎯 TEMPLATE EVENTS (8 event) - ÖNEMLİ!
```
❌ template_clicked
   Ne zaman: Template listesinde bir template'e tıklayınca
   Data: {templateId, templateName}
   
❌ template_detail_viewed
   Ne zaman: Template detay ekranı açılınca
   Data: {templateId, templateName}
   
❌ template_photo_uploaded
   Ne zaman: Template'e foto yüklenince
   Data: {templateId, photoSource: 'camera' veya 'gallery'}
   
❌ template_generate_started
   Ne zaman: Generate butonuna basınca
   Data: {templateId, templateName}
   
❌ template_generate_completed
   Ne zaman: Generate işlemi bitince
   Data: {templateId, durationSeconds}
   
❌ template_generate_failed
   Ne zaman: Generate hata verince
   Data: {templateId, error}
   
❌ template_screen_exited
   Ne zaman: Template ekranından çıkınca
   Data: {templateId, durationSeconds, generated: true/false}
```

### 📸 TEXT TO IMAGE EVENTS (3 event)
```
❌ text_to_image_started
   Data: {promptLength, hasPrompt}
   
❌ text_to_image_completed
   Data: {durationSeconds}
   
❌ text_to_image_failed
   Data: {error}
```

### 🎥 VIDEO GENERATE EVENTS (3 event)
```
❌ video_generate_started
   Data: {source: 'text_to_video', 'image_to_video', etc.}
   
❌ video_generate_completed
   Data: {durationSeconds}
   
❌ video_generate_failed
   Data: {error}
```

### ⚡ REALTIME AI EVENTS (3 event)
```
❌ realtime_ai_started
   
❌ realtime_ai_photo_taken
   
❌ realtime_ai_completed
   Data: {durationSeconds}
```

### 📚 LIBRARY EVENTS (4 event)
```
❌ library_viewed
   
❌ library_item_clicked
   Data: {itemType: 'image' or 'video', itemId}
   
❌ library_item_shared
   Data: {itemType, shareMethod: 'instagram', 'whatsapp', etc.}
   
❌ library_item_deleted
   Data: {itemType}
```

### 💳 PAYMENT EVENTS (6 event) - ÖNEMLİ!
```
❌ payment_screen_viewed
   Data: {source: 'credit_banner', 'settings', 'feature_blocked', etc.}
   
❌ payment_plan_selected
   Data: {planId, planName, price}
   
❌ payment_started
   Data: {planId, planName}
   
❌ payment_completed
   Data: {planId, planName, price}
   
❌ payment_failed
   Data: {planId, error}
   
❌ payment_cancelled
   Data: {planId}
```

### 👤 PROFILE EVENTS (4 event)
```
❌ profile_viewed
   
❌ profile_edited
   Data: {field: 'name', 'email', 'photo', etc.}
   
❌ logout_clicked
   
❌ logout_completed
```

### 🔘 BUTTON CLICKS (1 event) - GENEL
```
❌ button_clicked
   Data: {buttonName, screen}
   Kullanım: Önemli butonlara manuel ekleyebiliriz
```

### 📝 FORM INTERACTIONS (2 event)
```
❌ form_field_focused
   Data: {fieldName, screen}
   
❌ form_submitted
   Data: {formName, success}
```

### 🚨 ERROR TRACKING (2 event)
```
❌ error_shown
   Data: {errorMessage, screen, action}
   
❌ network_error
   Data: {endpoint, error}
```

### ⭐ FEATURE USAGE (2 event)
```
❌ feature_accessed
   Data: {featureName}
   
❌ feature_blocked
   Data: {featureName, reason: 'no_credit', 'premium_only', etc.}
```

### 🎓 ONBOARDING EVENTS (4 event)
```
❌ onboarding_started
   
❌ onboarding_step_viewed
   Data: {step, stepName}
   
❌ onboarding_completed
   
❌ onboarding_skipped
   Data: {atStep}
```

### 🎯 CUSTOM EVENTS (2 event)
```
✅ screen_view - HER EKRAN İÇİN
   Data: {screenName}
   
✅ custom_event - İSTEDİĞİMİZ HER ŞEY İÇİN
   Data: {istediğin her şey}
```

---

## 📊 ÖNCELİK SIRASI - HANGİLERİ EKLEMELİYİZ?

### 🔥 YÜKSEK ÖNCELİK (Kesinlikle ekle)
1. ✅ **Template Events (8)** - Kullanıcılar ne yapıyor görmek için
2. ✅ **Payment Events (6)** - Para kaybetmeyelim!
3. ✅ **Tab Changed** - Hangi özelliği kullanıyorlar
4. ✅ **Feature Blocked** - Neden premium almıyorlar

### ⚠️ ORTA ÖNCELİK (İyi olur)
5. **Text to Image / Video Generate** - Özellik kullanımı
6. **Library Events** - İçerik paylaşımı
7. **Profile Events** - Kullanıcı aktivitesi
8. **Realtime AI** - Özellik kullanımı

### 💡 DÜŞÜK ÖNCELİK (Sonra ekleriz)
9. **Form Field Focused** - Çok detaylı
10. **Button Clicked** - Manuel eklenmeli
11. **Onboarding** - Onboarding varsa
12. **Error Tracking** - Crashlytics'te zaten var

---

## 💬 SORULAR

Hangi kategorileri eklememizi istersin?

**Örnek cevap**:
- "Template, Payment ve Tab Changed ekle" 
- "Sadece Template ve Payment yeterli"
- "Hepsini ekle!"
- "Template, Payment, Feature Blocked ekle"

Sen söyle, ben sadece istediklerini yerleştireyim! 🎯

