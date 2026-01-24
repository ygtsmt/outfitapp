# Comby - Yapay Zeka Destekli Moda Asistanı

Bu döküman, Comby projesinin amacını, kullanılan yapay zeka teknolojilerini ve temel uygulama akışlarını özetlemektedir.

## 1. Projenin Amacı
Comby, kullanıcıların gardıroplarını dijitalleştirmelerine yardımcı olan, yapay zeka kullanarak kişisel stil analizi yapan ve akıllı kombin önerileri sunan modern bir mobil moda asistanıdır. Uygulamanın temel hedefi, "bugün ne giysem?" sorusuna veriye dayalı ve kişiselleştirilmiş yanıtlar üretmektir.

## 2. Kullanılan Yapay Zeka Modelleri
Projede Google Gemini modelleri ve Fal AI API'ları entegre edilmiştir:

*   **Google Gemini 3 Flash (Preview):**
    *   **Kullanım Alanı:** Kıyafet analizleri (renk, kumaş, kategori belirleme), "Moda Eleştirisi" (Fashion Critique) metinleri ve "Stil DNA" analizlerinin oluşturulması.
    *   **Neden:** Hızlı yanıt süresi ve görsel anlama yeteneği için tercih edilmiştir.
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

### E. Sanal Deneme (Virtual Try-on)
*   **Önizleme:** Kullanıcının kendi fotoğrafı üzerinde, seçtiği kıyafetin nasıl duracağını görmesini sağlayan görsel oluşturma akışıdır.

## 4. Teknik Altyapı
*   **Framework:** Flutter (Mobile)
*   **Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions)
*   **Ödeme Sistemi:** RevenueCat (Abonelik ve Kredi Modelini yönetir)
*   **Bağımlılık Yönetimi:** Injectable & GetIt (Dependency Injection)

---
*Bu dosya projenin teknik ve fonksiyonel kapsamını anlamak için hazırlanmıştır.*
