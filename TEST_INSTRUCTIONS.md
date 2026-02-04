# Comby Chat Features - Test Instructions

Bu dosya, son eklenen Chat özelliklerini (Karşılama Mesajı, Video Arama, Chat Geçmişi) test etmek için adımları içerir.

> [!IMPORTANT]
> Teste başlamadan önce kod üretimini tamamlamak için terminalde şu komutu çalıştırdığınızdan emin olun:
> `flutter pub run build_runner build --delete-conflicting-outputs`

## 1. Chat Karşılama Mesajı (Empty State)

**Amaç:** Chat boşken kullanıcının doğru karşılama mesajını görmesi.

**Adımlar:**
1.  Uygulamayı açın.
2.  Chat ekranına (veya Home ekranındaki Chat ikonuna tıklayarak) gidin.
3.  Eğer daha önce konuşma yaptıysanız "+" ikonuna basarak veya Geçmiş ekranından "Yeni Sohbet" diyerek ekranı temizleyin.
4.  **Beklenen:** Ekranda "ChatEmptyState" yerine Comby'den gelen bir mesaj baloncuğu görmelisiniz:
    *   *"Selam ben Comby! 👋 Hava durumuna göre harika bir kombin oluşturmaya ne dersin?..."*

## 2. Video Arama (Live Stylist)

**Amaç:** Kullanıcının Live Stylist özelliğine erişebilmesi.

**Adımlar:**
1.  Chat ekranını açın (Home Modal veya ana ekran).
2.  Sağ üst köşedeki **Video Kamera** ikonuna tıklayın.
3.  **Beklenen:** Uygulama `LiveStylistPage` sayfasına yönlenmelidir (Video görüşme ekranı açılmalıdır).

## 3. Chat Geçmişi (History)

**Amaç:** Sohbetlerin kaydedilmesi, listelenmesi ve geri yüklenebilmesi.

### A. Oturum Kaydetme
1.  Yeni bir sohbet başlatın.
2.  Bir mesaj gönderin (Örn: "Bugün hava nasıl?").
3.  Botun cevap vermesini bekleyin.
4.  Chat ekranını kapatın veya başka bir sekmeye geçin.
5.  **Beklenen:** Bu konuşma arka planda Firestore'a kaydedilmiş olmalıdır.

### B. Geçmişi Görüntüleme
1.  Chat ekranını tekrar açın.
2.  Sağ üstteki **Saat/Geçmiş** (History) ikonuna tıklayın.
3.  **Beklenen:** "Geçmiş Sohbetler" ekranı açılmalı ve az önce yaptığınız konuşma listede görünmelidir (Tarih ve Başlık ile).

### C. Sohbeti Geri Yükleme
1.  Geçmiş listesinden bir önceki sohbetinize tıklayın.
2.  **Beklenen:** Chat ekranına geri dönülmeli ve o sohbetin eski mesajları ("Bugün hava nasıl?" ve cevabı) ekrana yüklenmelidir.

### D. Yeni Sohbet Başlatma
1.  Chat ekranındayken veya Geçmiş ekranındayken **"+" (Ekle)** ikonuna tıklayın (Geçmiş ekranında sağ altta FAB butonu).
2.  **Beklenen:** Chat ekranı temizlenmeli ve sadece karşılama mesajı görünmelidir.

### E. Sohbet Silme
1.  Geçmiş ekranına gidin.
2.  Bir sohbeti sola doğru kaydırın (Swipe left) veya silme ikonuna tıklayın (varsa).
3.  **Beklenen:** Sohbet listeden silinmeli ve bir daha geri gelmemelidir.
