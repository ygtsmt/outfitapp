# Comby - Yapay Zeka Destekli Moda Asistanı

Bu döküman, Comby projesinin amacını, kullanılan yapay zeka teknolojilerini ve temel uygulama akışlarını özetlemektedir.

## 1. Projenin Amacı
Comby, kullanıcıların gardıroplarını dijitalleştirmelerine yardımcı olan, yapay zeka kullanarak kişisel stil analizi yapan ve akıllı kombin önerileri sunan modern bir mobil moda asistanıdır. Uygulamanın temel hedefi, "bugün ne giysem?" sorusuna veriye dayalı ve kişiselleştirilmiş yanıtlar üretmektir.

## 2. Kullanılan Yapay Zeka Modelleri
Projede Google Gemini modelleri ve Fal AI API'ları entegre edilmiştir:

*   **Google Gemini 3 Flash (Preview):**
    *   **Kullanım Alanı:** Kıyafet analizleri, Moda Eleştirisi, Stil DNA analizleri ve **AI Sohbet Asistanı (Agent)**.
    *   **Yetenekler:** Vision (Görsel Görme) yeteneği ile fotoğraf analizi yapabilir, kullanıcı ile sohbet edebilir ve çeşitli araçları (Tools) kullanabilir.
    *   **Neden:** Hızlı yanıt süresi, görsel anlama yeteneği ve Function Calling başarısı için tercih edilmiştir.
*   **Google Gemini 3 Pro (Fal AI üzerinden):**
    *   **Kullanım Alanı:** Sanal Deneme (Virtual Try-on) ve kıyafet düzenleme (Visual Edit) işlemleri.
    *   **Neden:** Karmaşık görsel düzenleme ve gerçekçi görüntü oluşturma kapasitesi yüksektir.

## 3. Temel Uygulama Akışları (App Flows)

### A. Akıllı Gardırop (Digital Closet)
*   **Fotoğraf Analizi:** Kullanıcı bir kıyafet fotoğrafı yüklediğinde, AI modeli kıyafeti otomatik olarak analiz eder; kategorisini (blazer, t-shirt vb.), baskın rengini, desenini ve kumaş türünü belirler.
*   **Otomatik Etiketleme:** Manuel veri girişini minimize ederek kıyafetleri veritabanında düzenli tutar.

### B. Moda Eleştirisi (Fashion Critique)
*   **Kombin Değerlendirme:** Kullanıcı üzerindeki kombinin fotoğrafını yükler.
*   **Skorlama ve Geri Bildirim:** AI, kombine 100 üzerinden bir puan verir ve Türkçe olarak yapıcı eleştirilerde bulunur (örn: "Renk uyumu harika ama bu ceketle daha ince bir kemer tercih edebilirsin").

### C. Stil DNA (Style DNA)
*   **Karakter Analizi:** Gardıroptaki parçaların genel tarzını (Casual, Streetwear, Elegant vb.) analiz ederek kullanıcının "Stil Kimliğini" oluşturur.
*   **Kişiselleştirilmiş Başlıklar:** Kullanıcıya "Minimalist Öncü" veya "Sokak Modası Ustası" gibi stil başlıkları atar.

### D. Kombin Önerileri ve Hava Durumu Entegrasyonu
*   **Şartlara Uygunluk:** Lokasyona bağlı hava durumu verilerini alarak (örn: yağmurlu, 15°C) dolaptaki uygun parçalardan kombinler önerir.
*   **AI Tasarım:** Mevcut kıyafetlerin yanına yakışacak parçaları görsel olarak önerir.

### E. AI Moda Asistanı (Smart Chat Agent)
Kullanıcının moda ile ilgili her türlü sorusuna yanıt veren, görsel algılama yeteneğine sahip interaktif bir asistandır.

*   **Doğal Dil Etkileşimi:** "Yarın Ankara'da hava yağmurlu, iş toplantısı için ne giymeliyim?" gibi karmaşık soruları anlayıp yanıtlayabilir.
*   **Görsel Analiz (Vision):** Sohbet ekranından gönderilen fotoğrafları (örn: bir ayakkabı veya kombin) analiz ederek yorumlar ve buna uygun öneriler sunar.
*   **Araç Kullanımı (Tool Calling):** Asistan, yanıt üretirken gerçek zamanlı verilere ve kullanıcı verilerine erişmek için şu araçları kullanır:
    *   `get_weather`: Belirtilen tarih ve konum için detaylı hava durumu verisi çeker (OpenWeatherMap entegrasyonu).
    *   `get_calendar_events`: Kullanıcının günlük programını ve etkinliklerini (Toplantı, Düğün vb.) analiz eder.
    *   `search_wardrobe`: Kullanıcının gardırobunda semantik arama yapar (örn: "mavi gömleklerimi göster").
    *   `check_color_harmony`: Seçilen parçaların renk uyumunu matematiksel ve estetik olarak puanlar.
    *   `generate_outfit_visual`: Fal AI (Gemini) kullanarak, gardıroptaki parçaların kullanıcı üzerinde nasıl duracağına dair gerçekçi görseller üretir.
*   **Kişiselleştirme:** Kullanıcının sevdiği/sevmediği renkleri ve stil tercihlerini öğrenir ve hafızasında tutar.

### F. Sanal Deneme (Virtual Try-on)
*   **Önizleme:** Kullanıcının kendi fotoğrafı üzerinde, seçtiği kıyafetin nasıl duracağını görmesini sağlayan görsel oluşturma akışıdır.

### G. Takvim Entegrasyonu (Context-Aware Styling)
*   **Etkinlik Bazlı Hazırlık:** Asistan, "Bugün ne giyeyim?" sorusuna karşılık kullanıcının takvimini (Google Calendar) kontrol eder. Eğer "Yatırımcı Sunumu" veya "Düğün" gibi özel bir etkinlik varsa, buna uygun (Business Formal, Abiye vb.) bir stil belirler.
*   **Zaman Yönetimi:** Etkinlik saatine ne kadar kaldığını hesaplayarak "15 dakikan var, hızlıca şu kombini yap" şeklinde pratik öneriler sunar.
*   **Çakışma Kontrolü:** Geçmiş etkinliklerde giyilen kıyafetleri hatırlayarak (Memory), aynı grupla yapılacak buluşmalarda "Bunu geçen sefer giymiştin, değiştirmek ister misin?" uyarısı yapar.

## 4. Teknik Altyapı
*   **Framework:** Flutter (Mobile)
*   **Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions)
*   **AI & ML:** Google Gemini Models, Fal AI (Image Generation)
*   **Hava Durumu:** OpenWeatherMap API
*   **Ödeme Sistemi:** RevenueCat (Abonelik ve Kredi Modelini yönetir)
*   **Bağımlılık Yönetimi:** Injectable & GetIt (Dependency Injection)

---
*Bu dosya projenin teknik ve fonksiyonel kapsamını anlamak için hazırlanmıştır.*
