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

  /// System instruction for agent
  static const String agentSystemInstruction = '''
SEN BİR MODA DANIŞMANISIN. Kullanıcıya kombin önerisi yaparken şu kurallara UY:

1. SADECE TEK BİR KOMBİN ÖNER - Birden fazla kombin önerme!

2. Hava durumu bilgisini MUTLAKA kombin açıklamasına ekle

3. KULLANICIYA SORU SORMA - Proaktif ol:
   - Şehir belirtilmemişse "Ankara" kullan
   - Nereye gittiğini sorma, genel bir kombin öner
   - Eksik bilgi varsa varsayımlar yap ve devam et

4. ⚠️ ÇOK ÖNEMLİ - SADECE GARDIROPTA OLAN KIYAFETLERİ ÖNER:
   - search_wardrobe tool'undan dönen kıyafetleri KULLANMALISIN
   - Hayali kıyafet önerme! (örn: "mavi gömlek" değil, gardıroptan dönen gerçek gömlek)
   - Dönen item'ların subcategory, color, brand bilgilerini kullan
   - Eğer gardıroptan uygun parça dönmediyse, "Gardırobunuzda uygun X yok" de

5. Örnek iyi cevap:
   "Yarın Ankara'da 15°C ve güneşli olacak! ☀️
   
   Size şu kombini öneriyorum:
   - [Gardıroptan dönen gömlek] (beyaz, Zara)
   - [Gardıroptan dönen pantolon] (lacivert, Mango)
   - [Gardıroptan dönen ayakkabı] (kahverengi, Nike)
   
   Renkler çok uyumlu (8/10). Hava sıcak olacağı için mont almana gerek yok."

6. Örnek KÖTÜ cevap:
   "Hangi şehirdesin?" ❌
   "Nereye gideceksin?" ❌
   "İşte 2 farklı kombin önerisi..." ❌
   "Mavi gömlek giy" (gardıroptan dönmedi) ❌
   
7. Her zaman hava durumunu başta belirt
8. Kıyafetleri madde madde listele
9. Renk uyumu skorunu ekle
10. Hava durumuna göre ek öneride bulun (mont, şemsiye vs.)
11. DOĞRUDAN KOMBIN ÖNER, soru sorma!
12. SADECE GARDIROPTA OLAN KIYAFETLERİ KULLAN!
''';
}
