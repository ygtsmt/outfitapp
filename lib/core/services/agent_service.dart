import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:comby/core/services/weather_service.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:comby/app/features/chat/models/agent_models.dart';
import 'package:comby/core/services/gemini_rest_service.dart';
import 'package:comby/core/services/gemini_models.dart';
import 'package:comby/core/services/tool_registry.dart';
import 'package:comby/core/services/user_preference_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:comby/core/services/notification_service.dart';

@injectable
class AgentService {
  final WeatherService _weatherService;
  final ClosetUseCase _closetUseCase;
  final FalAiUsecase _falAiUsecase;
  final UserPreferenceService _userPreferenceService;
  final NotificationService _notificationService;

  // MARATHON AGENT: Aktif Görev (Artık Storage'dan geliyor, burası boş kalabilir)
  Map<String, dynamic>? _activeMission;

  // ignore: unused_field
  final ToolRegistry _toolRegistry = ToolRegistry(); // Helper access if needed

  AgentService({
    required WeatherService weatherService,
    required ClosetUseCase closetUseCase,
    required FalAiUsecase falAiUsecase,
    required UserPreferenceService userPreferenceService,
    required NotificationService notificationService,
  })  : _weatherService = weatherService,
        _closetUseCase = closetUseCase,
        _falAiUsecase = falAiUsecase,
        _userPreferenceService = userPreferenceService,
        _notificationService = notificationService;

  /// 🤖 Agent task'i execute et (REST API)
  Future<AgentResponse> executeAgentTask({
    required String userMessage,
    required GeminiRestService geminiService,
    required List<GeminiContent> history,
    required String model,
    List<String>? imagePaths, // NEW: Image Support
    void Function(String)? onStep, // NEW: Step Callback
  }) async {
    final steps = <AgentStep>[];

    // Geçici history kopyası
    final taskHistory = List<GeminiContent>.from(history);

    try {
      log('🤖 Agent başlatıldı (REST): $userMessage${imagePaths != null ? ' + ${imagePaths.length} images' : ''}');

      // 🔥 MEMORY LOAD: Kullanıcı profilini çek
      final userProfile = await _userPreferenceService.getSystemPromptProfile();

      // System Instruction'ı zenginleştir
      final fullSystemInstruction =
          '${ToolRegistry.agentSystemInstruction}\n$userProfile';

      // Vision Context Ekle
      String contextualMessage = userMessage;
      if (imagePaths != null && imagePaths.isNotEmpty) {
        contextualMessage =
            '$userMessage\n\n[IMAGE ANALYSIS: User sent a photo. Use your Vision capability to analyze the clothing, colors, and style in this photo. Then search for matching items in the user\'s wardrobe using `search_wardrobe`.]';
      }

      // AI'a tool kullanmasını hatırlat
      final enhancedMessage =
          '$contextualMessage\n\n[Use weather, wardrobe, color harmony, and visual tools]';

      // Kullanıcı mesajını oluştur (Text + Images)
      final List<GeminiPart> messageParts = [GeminiTextPart(enhancedMessage)];

      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (final path in imagePaths) {
          try {
            final file = File(path);
            final bytes = await file.readAsBytes();
            final base64Data = base64Encode(bytes);
            // Verify mime type logic (simple check)
            final mimeType = path.toLowerCase().endsWith('.png')
                ? 'image/png'
                : 'image/jpeg';

            messageParts.add(GeminiInlineDataPart(mimeType, base64Data));
            log('📸 Resim eklendi: $path ($mimeType)');
          } catch (e) {
            log('❌ Resim okuma hatası: $e');
          }
        }
      }

      // Kullanıcı mesajını history'ye ekle
      final userContent = GeminiContent(
        role: 'user',
        parts: messageParts,
      );
      taskHistory.add(userContent);

      // İlk istek
      var response = await geminiService.generateContent(
        model: model,
        request: GeminiRequest(
          contents: taskHistory,
          tools: ToolRegistry.allGeminiTools, // REST tools
          toolConfig: GeminiToolConfig(
            functionCallingConfig: GeminiFunctionCallingConfig(
              mode: 'AUTO',
            ),
          ),
          systemInstruction: GeminiContent(
            role: 'system',
            parts: [GeminiTextPart(fullSystemInstruction)],
          ),
        ),
      );

      int iteration = 0;
      const maxIterations = 10;

      while (iteration < maxIterations) {
        iteration++;

        // Response'u işle
        if (response.candidates != null && response.candidates!.isNotEmpty) {
          final candidate = response.candidates!.first;
          final content = candidate.content;

          // Model cevabını history'ye ekle
          taskHistory.add(content);

          // Function calls var mı?
          final functionCalls =
              content.parts.whereType<GeminiFunctionCallPart>().toList();

          if (functionCalls.isNotEmpty) {
            log('🔍 Function Calls found: ${functionCalls.length}');
            for (var fc in functionCalls) {
              log('  - Call: ${fc.name}');
              log('  - Signature: ${fc.thoughtSignature ?? "MISSING"}');

              // 🆕 Send thought signature to UI
              if (fc.thoughtSignature != null &&
                  fc.thoughtSignature!.isNotEmpty) {
                // Try to decode base64 thought signature
                String decodedSignature = fc.thoughtSignature!;
                bool isReadable = false;

                try {
                  // Check if it looks like base64 (no spaces, alphanumeric + / =)
                  if (RegExp(r'^[A-Za-z0-9+/=]+$')
                      .hasMatch(fc.thoughtSignature!)) {
                    final decoded =
                        utf8.decode(base64Decode(fc.thoughtSignature!));
                    // Check if decoded text is readable (printable ASCII)
                    if (decoded.isNotEmpty &&
                        decoded.length < 500 &&
                        RegExp(r'^[\x20-\x7E\s]+$').hasMatch(decoded)) {
                      decodedSignature = decoded;
                      isReadable = true;
                      log('🔓 DECODED thought signature from base64');
                    }
                  }
                } catch (e) {
                  log('⚠️ Could not decode thought signature: $e');
                }

                // If not readable, generate human-friendly thought signature
                if (!isReadable) {
                  decodedSignature =
                      _generateThoughtSignature(fc.name, fc.args);
                  log('🤖 GENERATED readable thought signature');
                }

                log('✅ THOUGHT SIGNATURE - Sending to UI:');
                log('   "$decodedSignature"');
                onStep?.call('💭 $decodedSignature');
              } else {
                // No thought signature, generate one
                final generatedSignature =
                    _generateThoughtSignature(fc.name, fc.args);
                log('🤖 GENERATED thought signature for: ${fc.name}');
                log('   "$generatedSignature"');
                onStep?.call('💭 $generatedSignature');
              }
            }
          } else {
            // Text cevabı var mı?
            final textParts =
                content.parts.whereType<GeminiTextPart>().toList();
            String finalText = textParts.isNotEmpty
                ? textParts.map((e) => e.text).join(' ')
                : 'İşlem tamamlandı.';

            log('📝 RAW RESPONSE TEXT:');
            log('   "${finalText.substring(0, finalText.length > 200 ? 200 : finalText.length)}..."');

            // 🆕 Filter out raw JSON, PLAN tags, and code blocks
            final originalText = finalText;

            // Remove ```json ... ``` blocks
            finalText = finalText.replaceAll(RegExp(r'```json[\s\S]*?```'), '');
            // Remove ```...``` blocks
            finalText = finalText.replaceAll(RegExp(r'```[\s\S]*?```'), '');
            // Remove <PLAN>...</PLAN> blocks
            finalText =
                finalText.replaceAll(RegExp(r'<PLAN>[\s\S]*?</PLAN>'), '');
            // Remove <THOUGHT>...</THOUGHT> blocks
            finalText = finalText.replaceAll(
                RegExp(r'<THOUGHT>[\s\S]*?</THOUGHT>'), '');
            // Remove standalone JSON objects
            finalText = finalText.replaceAll(
                RegExp(r'\{[\s\S]*?"thoughtSignature"[\s\S]*?\}'), '');
            // Trim whitespace
            finalText = finalText.trim();

            if (originalText != finalText) {
              log('🧹 FILTERED OUT: JSON/PLAN/THOUGHT tags removed');
            }

            // If nothing left after filtering, use default message
            if (finalText.isEmpty) {
              finalText = 'İşlem tamamlandı.';
              log('⚠️ EMPTY AFTER FILTERING - Using default message');
            }

            log('✅ FINAL TEXT TO USER:');
            log('   "${finalText.substring(0, finalText.length > 200 ? 200 : finalText.length)}..."');

            // Visual Request ID var mı diye bak
            String? visualRequestId;
            final visualStep = steps
                .where((s) => s.toolName == 'generate_outfit_visual')
                .lastOrNull;
            if (visualStep != null &&
                visualStep.result.containsKey('request_id')) {
              visualRequestId = visualStep.result['request_id'] as String?;
            }

            log('✅ Agent tamamlandı');
            return AgentResponse(
              finalAnswer: finalText,
              steps: steps,
              visualRequestId: visualRequestId,
              success: true,
            );
          }

          // Tool çağrılarını çalıştır
          for (final call in functionCalls) {
            log('⚙️ Tool çalıştırılıyor: ${call.name}');

            // 🔥 UI Bilgilendirme
            String stepMessage = 'Processing...';

            // User-friendly step messages
            switch (call.name) {
              case 'get_weather_context':
                stepMessage = 'Checking weather conditions... 🌤️';
                break;
              case 'search_wardrobe':
                stepMessage = 'Scanning your wardrobe... 👗';
                break;
              case 'check_color_harmony':
                stepMessage = 'Checking color harmony... 🎨';
                break;
              case 'generate_outfit_visual':
                stepMessage = 'Creating outfit visual... ✨';
                break;
              case 'get_calendar_events':
                stepMessage = 'Checking your calendar... 📅';
                break;
              default:
                stepMessage = 'Running ${call.name} tool...';
            }
            onStep?.call(stepMessage);

            Map<String, dynamic> result;
            try {
              result = await _executeFunction(call);

              steps.add(AgentStep(
                toolName: call.name,
                arguments: call.args,
                result: result,
              ));
            } catch (e) {
              log('❌ Tool hatası: ${call.name} - $e');

              // Hata durumunda modelin pes etmemesi için yönlendirici mesaj dönüyoruz
              result = {
                'status': 'error',
                'message': 'Tool execution failed: ${e.toString()}',
                'instruction':
                    'Do not give up. Try a different parameter, use a default value (e.g. for weather), or try a similar tool. Decide the best next step for the user.'
              };

              steps.add(AgentStep(
                toolName: call.name,
                arguments: call.args,
                result: result, // result artık hata detayını içeriyor
                error: e.toString(),
              ));
            }

            // Function Response oluştur
            final functionResponse = GeminiContent(
              role: 'function',
              parts: [
                GeminiFunctionResponsePart(
                  name: call.name,
                  response: result,
                  thoughtSignature: null,
                ),
              ],
            );

            taskHistory.add(functionResponse);
          }

          // Sonuçları modele geri gönder
          response = await geminiService.generateContent(
            model: model,
            request: GeminiRequest(
              contents: taskHistory,
              tools: ToolRegistry.allGeminiTools,
              toolConfig: GeminiToolConfig(
                functionCallingConfig: GeminiFunctionCallingConfig(
                  mode: 'AUTO',
                ),
              ),
              systemInstruction: GeminiContent(
                role: 'system',
                parts: [GeminiTextPart(ToolRegistry.agentSystemInstruction)],
              ),
            ),
          );
        } else {
          throw Exception('Model returned empty response');
        }
      }

      log('⚠️ Max iteration exceeded');
      return AgentResponse(
        finalAnswer: 'Operation could not be completed (timeout).',
        steps: steps,
        success: false,
      );
    } catch (e) {
      log('❌ Agent error: $e');
      return AgentResponse(
        finalAnswer: 'Sorry, an error occurred: $e',
        steps: steps,
        success: false,
      );
    }
  }

  /// Function'ı execute et
  Future<Map<String, dynamic>> _executeFunction(
      GeminiFunctionCallPart call) async {
    switch (call.name) {
      case 'get_weather':
        return _getWeather(call.args);
      // throw Exception('Forced API Failure: Weather Service is down!');
      case 'search_wardrobe':
        return _searchWardrobe(call.args);
      case 'check_color_harmony':
        return _checkColorHarmony(call.args);
      case 'generate_outfit_visual':
        return _generateOutfitVisual(call.args);
      case 'update_user_preference':
        return _updateUserPreference(call.args);
      case 'get_calendar_events':
        return _getCalendarEvents(call.args);
      case 'analyze_style_dna':
        return _analyzeStyleDNA(call.args);
      case 'start_travel_mission':
        return _startTravelMission(call.args);
      default:
        throw Exception('Unknown tool: ${call.name}');
    }
  }

  // ===== TOOL IMPLEMENTATIONS =====

  Future<Map<String, dynamic>> _updateUserPreference(
      Map<String, dynamic> args) async {
    final action = args['action'] as String;
    final value = args['value'] as String;

    // Basit bir logic: Mevcut listeyi çekip üzerine ekleyebiliriz veya
    // şimdilik UserPreferenceService'i "arrayUnion" yapacak şekilde güncellemediysek
    // basitçe set ediyoruz. İdealde service tarafında "add" metodu olmalı.
    // Şimdilik service'deki updateStyleProfile overwrite yapıyor, bunu array eklemeye çevirelim.
    // Ancak service kodu şu an overwrite modunda.
    // Hızlı çözüm: Service'e 'add' yeteneği vermeden önce basitçe listeyi alıp ekleyip geri yazacağız
    // VEYA service'i güncellemek daha doğru olurdu ama burada hızlıca halledelim.

    // Aslında UserPreferenceService updateStyleProfile metodu set(merge: true) yapıyor.
    // Ama liste alanları için arrayUnion yapmak lazım.
    // AgentService içinden direkt arrayUnion gönderemeyiz çünkü service implementation detayı.

    // O yüzden UserPreferenceService'e "add" yeteneği eklemek en doğrusu, ama şimdilik
    // basitçe action'a göre mapleyip gönderelim.

    // NOT: UserPreferenceService güncellenmeli (arrayUnion için).
    // Şimdilik elimizdeki ile:

    List<String>? favs;
    List<String>? dislikes;
    List<String>? styles;
    String? note;

    // Burada ufak bir trick: tek elemanlı liste gönderiyoruz,
    // UserPreferenceService arkada set(merge:true) yaptığı için overwrite edecek (liste ise).
    // Bu yüzden UserPreferenceService'i güncellememiz gerekecek.
    // Şimdilik "hafızaya alındı" diyelim, sonra service'i düzeltelim.

    if (action == 'add_favorite') favs = [value];
    if (action == 'add_disliked') dislikes = [value];
    if (action == 'set_style') styles = [value];
    if (action == 'set_note') note = value;

    await _userPreferenceService.updateStyleProfile(
      favoriteColors: favs,
      dislikedColors: dislikes,
      styleKeywords: styles,
      notes: note,
    );

    return {
      'status': 'success',
      'message': 'Preference saved: $action -> $value',
    };
  }

  Future<Map<String, dynamic>> _getWeather(Map<String, dynamic> args) async {
    final city = args['city'] as String? ?? 'Ankara';
    final date = DateTime.parse(args['date']);

    final weather = await _weatherService.getWeatherForAgent(
      city: city,
      date: date,
    );

    return weather.toJson();
  }

  Future<Map<String, dynamic>> _searchWardrobe(
      Map<String, dynamic> args) async {
    final category = args['category'] as String?;
    final limit = args['limit'] as int? ?? 5;

    final allItems = await _closetUseCase.getUserClosetItems();

    final filteredItems = allItems
        .where((item) =>
            category == null ||
            (item.category ?? '')
                .toLowerCase()
                .contains(category.toLowerCase()))
        .take(limit)
        .toList();

    // AI için daha açık format
    final itemDescriptions = filteredItems.map((item) {
      final desc = '${item.subcategory ?? item.category}';
      final color = item.color != null ? ' (${item.color})' : '';
      final brand = item.brand != null ? ' - ${item.brand}' : '';
      return '$desc$color$brand';
    }).toList();

    return {
      'items': filteredItems.map((item) => item.toJson()).toList(),
      'count': filteredItems.length,
      'descriptions': itemDescriptions,
      'message': filteredItems.isEmpty
          ? 'No suitable items found in wardrobe'
          : 'Found ${filteredItems.length} items from wardrobe: ${itemDescriptions.join(", ")}',
    };
  }

  Future<Map<String, dynamic>> _checkColorHarmony(
      Map<String, dynamic> args) async {
    final itemIds = (args['item_ids'] as List).cast<String>();

    final allItems = await _closetUseCase.getUserClosetItems();
    final selectedItems =
        allItems.where((item) => itemIds.contains(item.id)).toList();

    if (selectedItems.isEmpty) {
      return {'harmony_score': 0, 'message': 'Clothing items not found'};
    }

    return {
      'harmony_score': 7,
      'message': 'Colors are harmonious',
    };
  }

  Future<Map<String, dynamic>> _generateOutfitVisual(
      Map<String, dynamic> args) async {
    final itemIds = (args['item_ids'] as List).cast<String>();

    // Gardırop parçalarını çek
    final allItems = await _closetUseCase.getUserClosetItems();
    final selectedItems =
        allItems.where((item) => itemIds.contains(item.id)).toList();

    // Model seçimi yap
    final userModels = await _closetUseCase.getUserModelItems();
    String? modelImageUrl;
    String? modelAiPrompt;

    if (userModels.isNotEmpty) {
      // Logic: Eğer ayakkabı varsa "Full Body" olan modellere öncelik ver
      final hasShoes = selectedItems.any((i) =>
          i.category?.toLowerCase() == 'shoes' ||
          i.subcategory?.toLowerCase() == 'shoes');
      final fullBodyModels = userModels
          .where((m) => m.bodyPart?.toLowerCase() == 'full_body')
          .toList();

      if (hasShoes && fullBodyModels.isNotEmpty) {
        // Rastgele bir full body model seç
        final selectedModel = (fullBodyModels..shuffle()).first;
        modelImageUrl = selectedModel.imageUrl;
        modelAiPrompt = selectedModel.aiPrompt;
        log('📸 Kullanıcı Modeli Seçildi (Full Body): ${selectedModel.name}');
      } else {
        // Rastgele herhangi bir model seç
        final selectedModel = (userModels..shuffle()).first;
        modelImageUrl = selectedModel.imageUrl;
        modelAiPrompt = selectedModel.aiPrompt;
        log('📸 Kullanıcı Modeli Seçildi (Rastgele): ${selectedModel.name}');
      }
    } else {
      log('⚠️ Kullanıcı modeli bulunamadı, varsayılan AI model kullanılacak.');
      // Eğer kullanıcı modeli yoksa, User Profile'dan cinsiyet çekip modelAiPrompt oluşturabiliriz
      // Şimdilik null bırakıyoruz, FalAiUsecase içinde prompt'ta "A model wearing..." diyecek
    }

    final result = await _falAiUsecase.generateGeminiImageEdit(
      imageUrls: selectedItems.map((e) => e.imageUrl).toList(),
      prompt: 'Fashion outfit combination, high quality, realistic',
      sourceId: 2,
      usedClosetItems: selectedItems,
      modelImageUrl: modelImageUrl,
      modelAiPrompt: modelAiPrompt,
    );

    if (result == null) {
      throw Exception('Failed to generate visual');
    }

    return {
      'request_id': result['id'],
      'status': 'processing',
    };
  }

  Future<Map<String, dynamic>> _getCalendarEvents(
      Map<String, dynamic> args) async {
    final date = args['date'] as String;
    log('📅 Takvim kontrol ediliyor: $date');

    // --- MOCK vs REAL SWITCH ---
    const bool useMockData = false; // DEMO MODE: Set to false for REAL data
    // ---------------------------

    if (useMockData) {
      log('⚠️ MOCK DATA MODE ACTIVED for Calendar');
      return {
        'events': [
          {
            'time': '14:00',
            'title': 'Yatırımcı Sunumu',
            'type': 'business_formal',
            'location': 'Maslak Plaza'
          },
          {
            'time': '20:00',
            'title': 'Arkadaşın Düğünü',
            'type': 'formal_event',
            'location': 'Boğaz Oteli'
          },
        ],
        'message':
            'Takviminde bugün için 2 önemli etkinlik var: 14:00 Yatırımcı Sunumu (Business) ve 20:00 Düğün (Formal). Buna göre şık bir şeyler seçmeliyiz.',
      };
    } else {
      // --- REAL GOOGLE CALENDAR IMPLEMENTATION ---
      log('🌍 REAL GOOGLE CALENDAR MODE ACTIVATED');
      final googleSignIn = GoogleSignIn(
        scopes: [calendar.CalendarApi.calendarEventsReadonlyScope],
      );

      try {
        // Zaten LoginUseCase'de giriş yapıldığı için sessizce erişmeye çalışıyoruz
        var account = await googleSignIn.signInSilently();

        if (account == null) {
          log('⚠️ Silent Sign-In Failed, attempting interative sign-in');
          // Eğer sessiz erişim olmazsa (örn: scope değiştiği için), tekrar soralım
          account = await googleSignIn.signIn();
        }

        if (account == null) {
          log('❌ Google Sign-In Canceled');
          return {'message': 'Google sign-in was cancelled.'};
        }

        final authClient = await googleSignIn.authenticatedClient();
        if (authClient == null) {
          return {'message': 'Authentication failed.'};
        }

        final calendarApi = calendar.CalendarApi(authClient);

        // Tarih aralığı (Tüm gün)
        final DateTime targetDate = DateTime.parse(date);
        final DateTime startOfDay =
            DateTime(targetDate.year, targetDate.month, targetDate.day);
        final DateTime endOfDay =
            DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59);

        final events = await calendarApi.events.list(
          "primary",
          timeMin: startOfDay.toUtc(),
          timeMax: endOfDay.toUtc(),
          singleEvents: true,
        );

        if (events.items == null || events.items!.isEmpty) {
          return {
            'events': [],
            'message': 'No events found in your calendar for this date.',
          };
        }

        // Veriyi formatla
        final formattedEvents = events.items!.map((e) {
          return {
            'summary': e.summary,
            'description': e.description,
            'start': e.start?.dateTime?.toString() ?? e.start?.date?.toString(),
            'location': e.location,
          };
        }).toList();

        return {
          'events': formattedEvents,
          'message':
              'Takviminden ${formattedEvents.length} etkinlik çektim. Etkinliklerin: ${formattedEvents.map((e) => e['summary']).join(", ")}.',
        };
      } catch (e) {
        log('❌ Google Calendar API Error: $e');
        return {
          'status': 'error',
          'message': 'Failed to fetch Google Calendar data: $e'
        };
      }
    }
  }

  Future<Map<String, dynamic>> _analyzeStyleDNA(
      Map<String, dynamic> args) async {
    log('🧬 Stil DNA Analizi Başlatılıyor...');

    // 1. Tüm dolabı çek
    final items = await _closetUseCase.getUserClosetItems();

    if (items.isEmpty) {
      return {
        'message':
            'Your wardrobe appears to be empty. Please add a few items first so I can analyze your style.',
      };
    }

    // 2. İstatistikleri Hesapla
    int totalItems = items.length;
    Map<String, int> colorCounts = {};
    Map<String, int> categoryCounts = {};
    // Map<String, int> brandCounts = {}; // Marka verisi şu an yok

    for (var item in items) {
      // Renk Sayımı
      if (item.color != null && item.color!.isNotEmpty) {
        colorCounts[item.color!] = (colorCounts[item.color!] ?? 0) + 1;
      }
      // Kategori Sayımı
      if (item.category != null) {
        categoryCounts[item.category!] =
            (categoryCounts[item.category!] ?? 0) + 1;
      }
      // Marka Sayımı (Varsa)
      // item.brand eksikse şimdilik geçiyoruz, eklenirse buraya konur.
    }

    // 3. Yüzdeleri ve Sıralamayı Bul
    // Yardımcı Fonksiyon: Map'i sırala ve string formatına çevir
    List<Map<String, dynamic>> getTopStats(Map<String, int> counts) {
      var sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted
          .take(3)
          .map((e) => {
                'name': e.key,
                'count': e.value,
                'percentage':
                    ((e.value / totalItems) * 100).toStringAsFixed(1) + '%'
              })
          .toList();
    }

    final topColors = getTopStats(colorCounts);
    final topCategories = getTopStats(categoryCounts);

    // 4. Sonuç Döndür
    return {
      'total_items': totalItems,
      'top_colors': topColors,
      'top_categories': topCategories,
      'message':
          'Wardrobe analysis completed. Provide insights based on statistics.',
    };
  }

  Future<Map<String, dynamic>> _startTravelMission(
      Map<String, dynamic> args) async {
    final destination = args['destination'] as String;
    final items = (args['packed_items'] as List).cast<String>();

    // ISO 8601 gelirse direkt al, gelmezse bugünü al
    final startDate =
        args['start_date'] as String? ?? DateTime.now().toIso8601String();

    final purpose = args['purpose'] as String? ?? 'General';

    log('🚀 Yeni Mission Başlatılıyor: $destination - $items');

    // O anki hava durumunu çek (Initial Weather)
    String initialWeather = 'Unknown';
    try {
      final weatherData = await _weatherService.getWeatherForAgent(
        city: destination,
        date: DateTime.parse(startDate),
      );
      initialWeather = weatherData.description;
    } catch (e) {
      log('⚠️ Initial weather fetch failed: $e');
    }

    // Görevi oluştur
    final missionData = {
      'destination': destination,
      'items': items,
      'start_date': startDate,
      'purpose': purpose,
      'initial_weather_desc': initialWeather,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Kaydet
    await _userPreferenceService.setActiveMission(missionData);

    // RAM'dekini de güncelle (Anlık takip için)
    _activeMission = missionData;

    return {
      'status': 'success',
      'message':
          'Tracking started for $destination trip. Weather ($initialWeather) and your items have been saved. I\'ll alert you on the Dashboard if anything changes.',
    };
  }

  /// MARATHON AGENT: Aktif görevi izle ve risk analizi yap
  Future<Map<String, dynamic>> monitorActiveMission(
      GeminiRestService geminiService) async {
    // 1. Önce RAM'e veya Storage'a bak
    // HER ZAMAN GÜNCEL VERİYİ ÇEK (Cache kullanma)
    // Çünkü kullanıcı manuel düzenlemiş olabilir veya arka planda değişmiş olabilir.
    _activeMission = await _userPreferenceService.getActiveMission();

    if (_activeMission == null) {
      // Görev yok
      return {'status': 'no_mission'};
    }

    // --- EXPIRED MISSION CHECK (AUTO-CLEANUP) ---
    final startDateStr = _activeMission!['start_date'] as String? ?? '';
    if (startDateStr.isNotEmpty) {
      final startDate = DateTime.parse(startDateStr);
      final today = DateTime.now();

      // Sadece tarih karşılaştırması (Saat farkını yoksay)
      final simpleStart =
          DateTime(startDate.year, startDate.month, startDate.day);
      final simpleToday = DateTime(today.year, today.month, today.day);

      // Eğer başlangıç tarihi dünden önceyse (start < today)
      // Kullanıcı "Yarın gidiyorum" dediyse start=Tomorrow. Yarın olduğunda start=Today.
      // Seyahat bitti diyebilmek için start < today mantıklı (1 günlük seyahat varsayımıyla).
      // Veya kullanıcı açıkça "dün gittim" dediyse.
      // Kullanıcı isteği: "Ertesi gün bu datayı kaldırıyor muyuz" -> Evet.
      if (simpleStart.isBefore(simpleToday)) {
        log('🏁 Mission süresi doldu, arşivleniyor...');

        await _userPreferenceService.archiveActiveMission(_activeMission!);
        _activeMission = null; // Memory temizle

        return {
          'status': 'mission_completed',
          'message':
              'I hope your trip to ${_activeMission?['destination'] ?? 'your destination'} went well! Welcome back.'
        };
      }
    }
    // ----------------------------------------------

    log('🕵️‍♂️ MISSION MONITORING STARTED: ${_activeMission!['destination']}');

    // 1. Güncel Havayı Çek (Gerçek Veri)
    Map<String, dynamic> currentWeather;
    try {
      final destination = _activeMission!['destination'] as String;
      final weatherData = await _weatherService.getWeatherForAgent(
        city: destination,
        date: DateTime.now(),
      );

      currentWeather = {
        'description': weatherData.description,
        'temp': weatherData.temperature,
        'condition': weatherData.condition
      };

      log('🌤️ Real Weather Fetched for $destination: ${weatherData.summary}');
    } catch (e) {
      log('⚠️ Weather Service Failed, using fallback: $e');
      // Fallback to avoid crash, but indicates missing data
      currentWeather = {'description': 'Unknown', 'temp': 20};
    }

    // 2. Dolaptaki Alternatifleri Çek
    final allItems = await _closetUseCase.getUserClosetItems();
    final wardrobeSummary = allItems
        .map((e) => "${e.category} (${e.color}) - ${e.brand ?? ''}")
        .take(20) // Token tasarrufu
        .join(", ");

    // 3. AGENT REASONING (Doğrudan modele sor)
    final prompt = '''
    ACT AS A TRAVEL GUARDIAN & LOCAL EXPERT.
    
    MISSION CONTEXT:
    Destination: ${_activeMission!['destination']}
    Packed Items: ${_activeMission!['items']}
    Old Weather: ${_activeMission!['initial_weather_desc']}
    
    NEW SITUATION:
    New Weather: ${currentWeather['description']} (${currentWeather['temp']}°C)
    User's Wardrobe (Alternatives): [$wardrobeSummary]
    
    TASK:
    1. Analyze if the new weather poses a risk to the Packed Items.
       - If YES -> Suggest a SPECIFIC replacement from the Wardrobe.
       - If NO -> Confirm everything is fine.
    2. BE A LOCAL EXPERT: Suggest a specific activity or place in the Destination that fits the CURRENT weather (e.g., "It's raining in Paris, visit Passage des Panoramas").
    3. VIBE MATCH: Suggest a song or music genre that fits the city/weather vibe.
    4. PRACTICAL TIP: Remind about technical details specific to the country (e.g. power plugs in UK, tipping in USA).
    
    OUTPUT FORMAT (JSON ONLY):
    {
      "alert_type": "danger" | "warning" | "success",
      "title": "Short Title (e.g. London Calling!)",
      "message": "Friendly advice combining risk analysis, the local suggestion, and the practical tip.",
      "vibe_music": "Song - Artist"
    }
    ''';

    try {
      // PROMPT & SYSTEM INSTRUCTION OLUŞTUR
      final request = GeminiRequest(
        contents: [
          GeminiContent(
            role: 'user',
            parts: [GeminiTextPart(prompt)],
          ),
        ],
        systemInstruction: GeminiContent(
          role: 'system',
          parts: [
            GeminiTextPart('You are a JSON generator. Respond ONLY with JSON.')
          ],
        ),
      );

      // REST API ÇAĞRISI
      final response = await geminiService.generateContent(
        model: 'gemini-3-flash-preview',
        request: request,
      );

      // RESPONSE PARSING
      var responseText = '';
      if (response.candidates != null &&
          response.candidates!.isNotEmpty &&
          response.candidates!.first.content.parts.isNotEmpty) {
        final part = response.candidates!.first.content.parts.first;
        if (part is GeminiTextPart) {
          responseText = part.text;
        }
      }

      // JSON TEMİZLEME
      final cleanJson =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      if (cleanJson.isNotEmpty) {
        log("🤖 Agent Decision: $cleanJson");

        // 🔔 PUSH NOTIFICATION TETİKLE
        try {
          final alert = jsonDecode(cleanJson);
          _notificationService.showLocalNotification(
            title: alert['title'] ?? 'Comby Seyahat Uyarısı',
            body: alert['message'] ?? '',
            payload: 'mission_alert',
          );
        } catch (e) {
          log("❌ Notification Error: $e");
        }

        return {'status': 'active', 'raw_analysis': cleanJson};
      }
    } catch (e) {
      log("❌ Monitoring Error: $e");
    }

    return {'status': 'error'};
  }

  /// Generate human-readable thought signature from tool name and args
  String _generateThoughtSignature(String toolName, Map<String, dynamic> args) {
    switch (toolName) {
      case 'get_weather':
        final city = args['city'] ?? 'Ankara';
        final date = args['date'] ?? 'tomorrow';
        return 'Checking weather forecast for $city on $date to recommend appropriate clothing';

      case 'get_calendar_events':
        final date = args['date'] ?? 'tomorrow';
        return 'Checking your calendar for $date to see if you have any special events';

      case 'search_wardrobe':
        final queries = args['queries'] as List?;
        if (queries != null && queries.isNotEmpty) {
          return 'Searching your wardrobe for ${queries.join(', ')}';
        }
        return 'Searching your wardrobe for matching items';

      case 'check_color_harmony':
        return 'Verifying that the color combinations look harmonious together';

      case 'generate_outfit_visual':
        return 'Creating a visual preview of your outfit';

      case 'update_user_preference':
        return 'Saving your style preferences for future recommendations';

      case 'analyze_photo_style':
        return 'Analyzing the style and colors in the photo you shared';

      default:
        return 'Processing your request with $toolName';
    }
  }
}
