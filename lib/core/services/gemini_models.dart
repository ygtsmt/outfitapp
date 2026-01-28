import 'dart:convert';

/// Gemini REST API Request Model
class GeminiRequest {
  final List<GeminiContent> contents;
  final List<GeminiTool>? tools;
  final GeminiContent? systemInstruction;
  final GeminiToolConfig? toolConfig;

  GeminiRequest({
    required this.contents,
    this.tools,
    this.systemInstruction,
    this.toolConfig,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'contents': contents.map((e) => e.toJson()).toList(),
    };

    if (tools != null) {
      json['tools'] = tools!.map((e) => e.toJson()).toList();
    }

    if (systemInstruction != null) {
      json['systemInstruction'] = systemInstruction!.toJson();
    }

    if (toolConfig != null) {
      json['toolConfig'] = toolConfig!.toJson();
    }

    return json;
  }
}

class GeminiContent {
  final String role;
  final List<GeminiPart> parts;

  GeminiContent({required this.role, required this.parts});

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': parts.map((e) => e.toJson()).toList(),
      };
}

abstract class GeminiPart {
  Map<String, dynamic> toJson();
}

class GeminiTextPart extends GeminiPart {
  final String text;

  GeminiTextPart(this.text);

  @override
  Map<String, dynamic> toJson() => {'text': text};
}

class GeminiInlineDataPart extends GeminiPart {
  final String mimeType;
  final String data; // Base64 encoded

  GeminiInlineDataPart(this.mimeType, this.data);

  @override
  Map<String, dynamic> toJson() => {
        'inlineData': {
          'mimeType': mimeType,
          'data': data,
        }
      };
}

class GeminiFunctionCallPart extends GeminiPart {
  final String name;
  final Map<String, dynamic> args;
  final String? thoughtSignature;

  GeminiFunctionCallPart({
    required this.name,
    required this.args,
    this.thoughtSignature,
  });

  @override
  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'functionCall': {
        'name': name,
        'args': args,
      }
    };
    // SIBLING: thoughtSignature (camelCase per docs)
    if (thoughtSignature != null) {
      json['thoughtSignature'] = thoughtSignature;
    }
    return json;
  }
}

class GeminiFunctionResponsePart extends GeminiPart {
  final String name;
  final Map<String, dynamic> response;
  final String? thoughtSignature;

  GeminiFunctionResponsePart({
    required this.name,
    required this.response,
    this.thoughtSignature,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'functionResponse': {
        'name': name,
        'response': response,
      }
    };
    // NOT: thought_signature functionResponse içinde GÖNDERİLMEMELİ.
    // Sadece functionCall partında (model role) olmalı.
    return json;
  }
}

class GeminiTool {
  final List<GeminiFunctionDeclaration> functionDeclarations;

  GeminiTool({required this.functionDeclarations});

  Map<String, dynamic> toJson() => {
        'functionDeclarations':
            functionDeclarations.map((e) => e.toJson()).toList(),
      };
}

class GeminiFunctionDeclaration {
  final String name;
  final String description;
  final Map<String, dynamic>? parameters;

  GeminiFunctionDeclaration({
    required this.name,
    required this.description,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'description': description,
    };
    if (parameters != null) {
      json['parameters'] = parameters;
    }
    return json;
  }
}

class GeminiToolConfig {
  final GeminiFunctionCallingConfig functionCallingConfig;

  GeminiToolConfig({required this.functionCallingConfig});

  Map<String, dynamic> toJson() => {
        'functionCallingConfig': functionCallingConfig.toJson(),
      };
}

class GeminiFunctionCallingConfig {
  final String mode; // AUTO, ANY, NONE

  GeminiFunctionCallingConfig({required this.mode});

  Map<String, dynamic> toJson() => {'mode': mode};
}

class GeminiResponse {
  final List<GeminiCandidate>? candidates;
  final GeminiPromptFeedback? promptFeedback;

  GeminiResponse({this.candidates, this.promptFeedback});

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      candidates: (json['candidates'] as List?)
          ?.map((e) => GeminiCandidate.fromJson(e))
          .toList(),
      promptFeedback: json['promptFeedback'] != null
          ? GeminiPromptFeedback.fromJson(json['promptFeedback'])
          : null,
    );
  }
}

class GeminiCandidate {
  final GeminiContent content;
  final String? finishReason;
  final int? index;

  GeminiCandidate({
    required this.content,
    this.finishReason,
    this.index,
  });

  factory GeminiCandidate.fromJson(Map<String, dynamic> json) {
    return GeminiCandidate(
      content: GeminiContent(
        role: json['content']['role'] ?? 'model',
        parts: (json['content']['parts'] as List)
            .map((e) {
              if (e.containsKey('text')) {
                return GeminiTextPart(e['text']);
              } else if (e.containsKey('functionCall')) {
                final fc = e['functionCall'];

                // SIBLING CHECK: thought_signature part objesinin içinde (functionCall'un kardeşi)
                String? signature;
                if (e.containsKey('thoughtSignature')) {
                  signature = e['thoughtSignature'];
                } else if (e.containsKey('thought_signature')) {
                  signature = e['thought_signature'];
                }

                // Debug log
                if (signature != null) {
                  print('✅ Found thought_signature (sibling): $signature');
                } else {
                  print(
                      '❌ thought_signature MISSING (sibling check)! Part keys: ${e.keys.toList()}');
                  // Fallback: belki functionCall içindedir (bazı versiyonlarda)
                  if (fc is Map && fc.containsKey('thought_signature')) {
                    signature = fc['thought_signature'];
                    print(
                        '⚠️ Found inside functionCall (unexpected): $signature');
                  }
                }

                return GeminiFunctionCallPart(
                  name: fc['name'],
                  args: fc['args'],
                  thoughtSignature: signature,
                );
              }
              return GeminiTextPart(''); // Fallback
            })
            .toList()
            .cast<GeminiPart>(),
      ),
      finishReason: json['finishReason'],
      index: json['index'],
    );
  }
}

class GeminiPromptFeedback {
  // Add fields if needed
  GeminiPromptFeedback.fromJson(Map<String, dynamic> json);
}
