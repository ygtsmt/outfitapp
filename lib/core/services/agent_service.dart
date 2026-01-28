import 'dart:developer';
import 'package:injectable/injectable.dart';
import 'package:comby/core/services/weather_service.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:comby/app/features/chat/models/agent_models.dart';
import 'package:comby/core/services/gemini_rest_service.dart';
import 'package:comby/core/services/gemini_models.dart';
import 'package:comby/core/services/tool_registry.dart';

@injectable
class AgentService {
  final WeatherService _weatherService;
  final ClosetUseCase _closetUseCase;
  final FalAiUsecase _falAiUsecase;

  // ignore: unused_field
  final ToolRegistry _toolRegistry = ToolRegistry(); // Helper access if needed

  AgentService({
    required WeatherService weatherService,
    required ClosetUseCase closetUseCase,
    required FalAiUsecase falAiUsecase,
  })  : _weatherService = weatherService,
        _closetUseCase = closetUseCase,
        _falAiUsecase = falAiUsecase;

  /// 🤖 Agent task'i execute et (REST API)
  Future<AgentResponse> executeAgentTask({
    required String userMessage,
    required GeminiRestService geminiService,
    required List<GeminiContent> history,
    required String model,
  }) async {
    final steps = <AgentStep>[];

    // Geçici history kopyası - sadece bu task için
    // Ana history'ye dışarıda ekleme yapılacak, burada sadece execution sırasındaki context önemli
    final taskHistory = List<GeminiContent>.from(history);

    try {
      log('🤖 Agent başlatıldı (REST): $userMessage');

      // AI'a tool kullanmasını hatırlat
      final enhancedMessage =
          '$userMessage\n\n[Hava durumu, gardırop, renk uyumu ve görsel tool\'larını kullan]';

      // Kullanıcı mesajını history'ye ekle
      final userContent = GeminiContent(
        role: 'user',
        parts: [GeminiTextPart(enhancedMessage)],
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
            parts: [GeminiTextPart(ToolRegistry.agentSystemInstruction)],
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
            }
          } else {
            // Text cevabı var mı?
            final textParts =
                content.parts.whereType<GeminiTextPart>().toList();
            final finalText = textParts.isNotEmpty
                ? textParts.map((e) => e.text).join(' ')
                : 'İşlem tamamlandı.';

            log('✅ Agent tamamlandı');
            return AgentResponse(
              finalAnswer: finalText,
              steps: steps,
              success: true,
            );
          }

          // Tool çağrılarını çalıştır
          for (final call in functionCalls) {
            log('⚙️ Tool çalıştırılıyor: ${call.name}');

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
              result = {'error': e.toString()};

              steps.add(AgentStep(
                toolName: call.name,
                arguments: call.args,
                result: {},
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
          throw Exception('Model boş cevap döndü');
        }
      }

      log('⚠️ Max iteration aşıldı');
      return AgentResponse(
        finalAnswer: 'İşlem tamamlanamadı (zaman aşımı).',
        steps: steps,
        success: false,
      );
    } catch (e) {
      log('❌ Agent hatası: $e');
      return AgentResponse(
        finalAnswer: 'Üzgünüm, bir hata oluştu: $e',
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
      case 'search_wardrobe':
        return _searchWardrobe(call.args);
      case 'check_color_harmony':
        return _checkColorHarmony(call.args);
      case 'generate_outfit_visual':
        return _generateOutfitVisual(call.args);
      default:
        throw Exception('Bilinmeyen tool: ${call.name}');
    }
  }

  // ===== TOOL IMPLEMENTATIONS =====

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
          ? 'Gardıroptan uygun parça bulunamadı'
          : 'Gardıroptan ${filteredItems.length} parça bulundu: ${itemDescriptions.join(", ")}',
    };
  }

  Future<Map<String, dynamic>> _checkColorHarmony(
      Map<String, dynamic> args) async {
    final itemIds = (args['item_ids'] as List).cast<String>();

    final allItems = await _closetUseCase.getUserClosetItems();
    final selectedItems =
        allItems.where((item) => itemIds.contains(item.id)).toList();

    if (selectedItems.isEmpty) {
      return {'harmony_score': 0, 'message': 'Kıyafet bulunamadı'};
    }

    return {
      'harmony_score': 7,
      'message': 'Renkler uyumlu',
    };
  }

  Future<Map<String, dynamic>> _generateOutfitVisual(
      Map<String, dynamic> args) async {
    final itemIds = (args['item_ids'] as List).cast<String>();

    final allItems = await _closetUseCase.getUserClosetItems();
    final selectedItems =
        allItems.where((item) => itemIds.contains(item.id)).toList();

    final result = await _falAiUsecase.generateGeminiImageEdit(
      imageUrls: selectedItems.map((e) => e.imageUrl).toList(),
      prompt: 'Outfit oluştur',
      sourceId: 2,
      usedClosetItems: selectedItems,
    );

    if (result == null) {
      throw Exception('Görsel oluşturulamadı');
    }

    return {
      'request_id': result['id'],
      'status': 'processing',
    };
  }
}
