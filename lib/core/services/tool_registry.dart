import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:comby/core/services/gemini_models.dart';

/// Gemini Function Calling için tool tanımları
class ToolRegistry {
  /// REST API uyumlu toollar
  static List<GeminiTool> get allGeminiTools => [
        GeminiTool(functionDeclarations: [
          _getWeatherRest,
          _searchWardrobeRest,
          _checkColorHarmonyRest,
          _generateOutfitVisualRest,
          _updatePreferenceRest,
        ]),
      ];

  /// Paketi kullanan legacy tool'lar (diğer özellikler için)
  static List<Tool> get allTools => [
        Tool(functionDeclarations: [
          getWeatherDeclaration,
          searchWardrobeDeclaration,
          checkColorHarmonyDeclaration,
          generateOutfitVisualDeclaration,
        ]),
      ];

  // REST API Definitions
  static GeminiFunctionDeclaration get _getWeatherRest =>
      GeminiFunctionDeclaration(
        name: 'get_weather',
        description: 'Belirtilen şehir ve tarih için hava durumu bilgisi al.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'city': {
              'type': 'STRING',
              'description':
                  'Şehir adı (örn: Ankara, Istanbul). Kullanıcı belirtmediyse "Ankara" kullan.'
            },
            'date': {
              'type': 'STRING',
              'description':
                  'Tarih MUTLAKA YYYY-MM-DD formatında olmalı. Bugün ${DateTime.now().toString().split(' ')[0]}. "Yarın" ise bugünden +1 gün hesapla. Örnek: 2026-01-29'
            },
          },
          'required': ['city', 'date'],
        },
      );

  static GeminiFunctionDeclaration get _searchWardrobeRest =>
      GeminiFunctionDeclaration(
        name: 'search_wardrobe',
        description:
            'Kullanıcının gardırobundan TEK BİR kombin için uygun kıyafetleri bul. Tool MUTLAKA "descriptions" alanındaki kıyafetleri kullanmalısın - hayali kıyafet önerme!',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'category': {
              'type': 'STRING',
              'description':
                  'Kategori: "top" (üst), "bottom" (alt), "outerwear" (dış giyim), "shoes" (ayakkabı), "accessories" (aksesuar). Boş bırakılırsa tüm kategoriler.'
            },
            'season': {
              'type': 'STRING',
              'description':
                  'Mevsim filtresi: "winter" (kış), "summer" (yaz), "spring_fall" (ilkbahar/sonbahar), "all" (tüm mevsimler). Hava durumuna göre seç.'
            },
            'weather_condition': {
              'type': 'STRING',
              'description':
                  'Hava durumu: "rainy" (yağmurlu), "sunny" (güneşli), "cold" (soğuk), "hot" (sıcak). Hava durumu API\'sinden gelen bilgiye göre.'
            },
            'limit': {
              'type': 'INTEGER',
              'description':
                  'Maksimum kaç parça döndürülsün (varsayılan: 5, tek kombin için yeterli)'
            },
          },
        },
      );

  static GeminiFunctionDeclaration get _checkColorHarmonyRest =>
      GeminiFunctionDeclaration(
        name: 'check_color_harmony',
        description:
            'Seçilen kıyafetlerin renk uyumunu kontrol et ve uyum skoru ver (0-10 arası).',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'item_ids': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description':
                  'Kontrol edilecek kıyafet ID\'leri (search_wardrobe\'dan dönen ID\'ler)'
            },
          },
          'required': ['item_ids'],
        },
      );

  static GeminiFunctionDeclaration get _updatePreferenceRest =>
      GeminiFunctionDeclaration(
        name: 'update_user_preference',
        description:
            'Kullanıcının stil tercihlerini güncelle veya yeni bir bilgi öğrenince kaydet. Örneğin kullanıcı "Siyah severim" derse bunu kaydet.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'action': {
              'type': 'STRING',
              'description':
                  'İşlem türü: "add_favorite" (sevdiği renk/parça ekle), "add_disliked" (sevmediği ekle), "set_style" (tarz anahtar kelimesi ekle), "set_note" (genel not ekle).'
            },
            'value': {
              'type': 'STRING',
              'description':
                  'Eklenecek değer. Örn: "siyah", "neon renkler", "minimalist", "yünlü giymez".'
            },
          },
          'required': ['action', 'value'],
        },
      );

  static GeminiFunctionDeclaration get _generateOutfitVisualRest =>
      GeminiFunctionDeclaration(
        name: 'generate_outfit_visual',
        description:
            'Seçilen kıyafetlerden AI ile kombin görseli oluştur. Fal AI kullanarak gerçekçi görsel üret.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'item_ids': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description':
                  'Kombin oluşturulacak kıyafet ID\'leri (en az 2, en fazla 5 parça)'
            },
            'weather_context': {
              'type': 'STRING',
              'description':
                  'Hava durumu bilgisi (örn: "15°C, güneşli"). Görsel oluştururken kullanılır.'
            },
          },
          'required': ['item_ids'],
        },
      );

  /// 1. Hava Durumu Tool
  static FunctionDeclaration get getWeatherDeclaration => FunctionDeclaration(
        'get_weather',
        'Belirtilen şehir ve tarih için hava durumu bilgisi al. Kullanıcı "yarın", "bugün" gibi ifadeler kullanırsa tarihi hesapla.',
        Schema(
          SchemaType.object,
          properties: {
            'city': Schema(
              SchemaType.string,
              description:
                  'Şehir adı (örn: Ankara, Istanbul). Kullanıcı belirtmediyse "Ankara" kullan.',
            ),
            'date': Schema(
              SchemaType.string,
              description:
                  'Tarih (YYYY-MM-DD formatında). "yarın" ise bugünden +1 gün, "bugün" ise bugünün tarihi.',
            ),
          },
          requiredProperties: ['city', 'date'],
        ),
      );

  /// 2. Gardırop Arama Tool
  static FunctionDeclaration get searchWardrobeDeclaration =>
      FunctionDeclaration(
        'search_wardrobe',
        'Kullanıcının gardırobundan TEK BİR kombin için uygun kıyafetleri bul. Tool MUTLAKA "descriptions" alanındaki kıyafetleri kullanmalısın - hayali kıyafet önerme!',
        Schema(
          SchemaType.object,
          properties: {
            'category': Schema(
              SchemaType.string,
              description:
                  'Kategori: "top" (üst), "bottom" (alt), "outerwear" (dış giyım), "shoes" (ayakkabı), "accessories" (aksesuar). Boş bırakılırsa tüm kategoriler.',
            ),
            'season': Schema(
              SchemaType.string,
              description:
                  'Mevsim filtresi: "winter" (kış), "summer" (yaz), "spring_fall" (ilkbahar/sonbahar), "all" (tüm mevsimler). Hava durumuna göre seç.',
            ),
            'weather_condition': Schema(
              SchemaType.string,
              description:
                  'Hava durumu: "rainy" (yağmurlu), "sunny" (güneşli), "cold" (soğuk), "hot" (sıcak). Hava durumu API\'sinden gelen bilgiye göre.',
            ),
            'limit': Schema(
              SchemaType.integer,
              description:
                  'Maksimum kaç parça döndürülsün (varsayılan: 5, tek kombin için yeterli)',
            ),
          },
        ),
      );

  /// 3. Renk Uyumu Kontrolü Tool
  static FunctionDeclaration get checkColorHarmonyDeclaration =>
      FunctionDeclaration(
        'check_color_harmony',
        'Seçilen kıyafetlerin renk uyumunu kontrol et ve uyum skoru ver (0-10 arası).',
        Schema(
          SchemaType.object,
          properties: {
            'item_ids': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
              description:
                  'Kontrol edilecek kıyafet ID\'leri (search_wardrobe\'dan dönen ID\'ler)',
            ),
          },
          requiredProperties: ['item_ids'],
        ),
      );

  /// 4. Görsel Oluşturma Tool
  static FunctionDeclaration get generateOutfitVisualDeclaration =>
      FunctionDeclaration(
        'generate_outfit_visual',
        'Seçilen kıyafetlerden AI ile kombin görseli oluştur. Fal AI kullanarak gerçekçi görsel üret.',
        Schema(
          SchemaType.object,
          properties: {
            'item_ids': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
              description:
                  'Kombin oluşturulacak kıyafet ID\'leri (en az 2, en fazla 5 parça)',
            ),
            'weather_context': Schema(
              SchemaType.string,
              description:
                  'Hava durumu bilgisi (örn: "15°C, güneşli"). Görsel oluştururken kullanılır.',
            ),
          },
          requiredProperties: ['item_ids'],
        ),
      );

  // System Instructions
  static String get agentSystemInstruction => '''
Sen "Comby" adında, profesyonel, dost canlısı ve zevkli bir stil danışmanısın.
Görevin: Kullanıcının "ne giysem" sorularına, hava durumu, gardırop içeriği ve renk uyumu kurallarını dikkate alarak en şık kombin önerisini sunmak.

KURALLAR:
1. HAVA DURUMU: Önce MUTLAKA `get_weather` ile hava durumunu kontrol et. Asla tahmin yürütme.
2. GARDIROP: Hava durumuna uygun kategorileri (örn: yağmurluysa bot/mont) belirle ve `search_wardrobe` ile gardıropta ara. Asla gardıropta olmayan bir parça önerme.
3. RENK UYUMU: Seçtiğin parçaların uyumunu `check_color_harmony` ile test et.
4. GÖRSEL: En son, seçtiğin parçalarla `generate_outfit_visual` kullanarak bir kombin görseli oluştur ve kullanıcıya sun.
5. HAFIZA (ÖNEMLİ): Kullanıcı sana tarzı, sevdiği/sevmediği renkler veya özel istekleri hakkında bir şey söylerse (örn: "X rengini severim", "Y tarzını giymem"), MUTLAKA `update_user_preference` tool'unu kullanarak bunu kaydet. Kullanıcının "bunu kaydet" demesini bekleme, sen proaktif ol.
6. VIBE MATCHER (FOTOĞRAF ANALİZİ): Eğer kullanıcı bir fotoğraf gönderip "bunu yap", "buna benzer" derse:
   a. Vision yeteneğinle fotoğraftaki kıyafetleri (tür, renk, tarz) analiz et.
   b. `search_wardrobe` kullanarak kullanıcının dolabında bu parçalara EN YAKIN olanları ara. Birebir aynısı yoksa alternatif (örn: deri ceket yoksa kot ceket) bul.
   c. Bulduğun parçalarla `generate_outfit_visual` yap.
   d. Cevabında "Fotoğraftaki X yerine senin Y parçanı seçtim çünkü..." şeklinde açıklama yap.
7. SELF-CORRECTION (HATA TOLERANSI): Eğer bir tool hata verirse veya boş sonuç dönerse ASLA pes etme ve kullanıcıya "hata oldu" deme.
   a. Hava durumu hatası: "Mevsim normallerine göre..." diyerek tahminde bulun.
   b. Gardırop boş/hata: Genel moda kurallarına göre (örn: "Siyah bir pantolon her zaman kurtarıcıdır") öneri yap.
   c. Amacın her ne olursa olsun kullanıcıya bir "çözüm" sunmak.
8. CEVAP FORMATI: Son cevabını verirken samimi ol, neden bu parçaları seçtiğini anlat. Tool çıktılarını (hava durumu, bulunan parçalar) yorumlayarak sun.

Eğer kullanıcı sadece "merhaba" derse, kendini tanıt ve ona nasıl yardımcı olabileceğini (hava durumu ve gardırobuna göre kombin yapabileceğini) ve tarzını öğrenmek istediğini söyle.
''';
}
