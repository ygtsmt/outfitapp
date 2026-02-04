# Comby - Live AI Personal Fashion Assistant 👗✨

**Comby**, Google'ın en gelişmiş multimodel yapay zekası **Gemini 3 Flash** tarafından desteklenen, dünyanın ilk canlı multimodal moda asistanıdır. Sadece bir gardırop yöneticisi değil, dünyayı sizinle aynı anda gören ve yorumlayan canlı bir yol arkadaşıdır.

---

## 🌟 Öne Çıkan Özellikler

### 🤖 1. Live AI Stylist (Canlı Multimodal Asistan)
Kameranızı kendinize veya kıyafetlerinize doğrultun ve konuşmaya başlayın. Gemini 3, canlı kamera beslemesini (Live Video Feed) analiz ederek şu an ne giydiğinizi anlar ve size anlık tavsiyeler verir.
- **Düşük Gecikme (Low Latency):** Gemini 3 Flash'ın multimodal gücüyle gerçek zamanlı etkileşim.
- **Görsel Bağlam:** "Bu ceket altına hangi pantolonum uyar?" diye sorun, asistan hem ceketi görsün hem de dijital dolabınızda arama yapsın.

### 👚 2. Akıllı Gardırop (Multimodal Vision)
Kıyafetlerinizin fotoğraflarını çekin, Gemini gerisini halletsin.
- **Otomatik Analiz:** Kategori, renk, desen ve kumaş türünü anında tanımlar.
- **Profesyonel Görünüm:** Arka planı otomatik temizleyerek temiz bir katalog oluşturur.
- **Semantik Arama:** "Mavi gömleklerimi göster" veya "Kışlık elbiselerimi listele" gibi doğal dilde arama yapın.

### 🧠 3. Gelişmiş Agent Yetenekleri (Tool Calling)
Asistanınız sadece bir chatbot değildir; gerçek dünya araçlarını (Tools) kullanabilen bir ajandır:
- **Hava Durumu Entegrasyonu:** Yağmurlu günlerde size otomatik olarak şemsiye ve trençkot önerir.
- **Takvim Entegrasyonu:** Yarınki "İş Görüşmesi" veya "Doğum Günü Partisi" etkinliğinizi görür ve ona uygun kombin hazırlar.
- **Renk Uyumu Kontrolü:** Parçaların birbirine teorik olarak yakışıp yakışmadığını analiz eder.

### 🧬 4. Stil DNA ve Moda Eleştirisi
- **Kişilik Raporu:** Tüm gardırobunuzu analiz ederek sizin moda kimliğinizi (Style DNA) çıkarır.
- **Critique (Fit Check):** Kombininizin fotoğrafını atın, 100 üzerinden puan alın ve iyileştirme önerileri dinleyin.

---

## 🛠️ Teknik Altyapı

- **Mobile Framework:** Flutter (Dart)
- **State Management:** BLoC Pattern
- **AI Core:** Google Gemini 3 Flash (Primary) & Gemini Pro (via Fal.AI)
- **Backend:** Firebase (Firestore, Auth, Storage, Functions)
- **Monetization:** RevenueCat (Credit-based system)
- **APIs:** OpenWeatherMap, Google Calendar

---

## 🚀 Gemini 3 Hackathon Notları

Comby, Gemini 3'ün çekirdek yeteneklerini en iyi şekilde sergilemek için tasarlanmıştır:
1. **Multimodal Capabilities:** Ses, metin ve canlı video (frame-based) beslemesini aynı anda işleme.
2. **Function Calling (Tool Calling):** AI'ın dış dünyaya açılan kapıları (Hava durumu, Takvim, Arama).
3. **Complex Reasoning:** Gardırop envanteri + Hava durumu + Takvim etkinliği + Stil tercihlerini sentezleyerek tek bir akıllı öneri üretme.

---

## 🌏 Çoklu Dil Desteği
Comby, global kullanıcılar için **11 farklı dilde** (Türkçe, İngilizce, Arapça, Çince, vb.) tam RTL desteğiyle hizmet vermektedir.

---

## 👨‍💻 Kurulum ve Çalıştırma

1. Projeyi clone edin.
2. `.env` dosyasını oluşturun ve Gemini API anahtarınızı ekleyin.
3. `flutter pub get` komutunu çalıştırın.
4. `flutter run` ile uygulamayı başlatın.

---
*Comby - Build what's next in fashion tech with Gemini 3.*
