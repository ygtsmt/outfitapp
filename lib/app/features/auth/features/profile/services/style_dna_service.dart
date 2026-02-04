import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comby/core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

@singleton
class StyleDNAService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GenerativeModel _model;

  StyleDNAService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: geminiApiKey,
    );
  }

  Future<Map<String, dynamic>> analyzeStyle({bool forceRefresh = false}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      // 1. Check for cached data (unless force refresh)
      if (!forceRefresh) {
        final cacheDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('style_dna')
            .doc('current')
            .get();

        if (cacheDoc.exists && cacheDoc.data() != null) {
          final data = cacheDoc.data()!;
          // Return cached data regardless of age
          DateTime? lastUpdated;
          if (data['last_updated'] != null) {
            lastUpdated = (data['last_updated'] as Timestamp).toDate();
          }

          return {
            'scores': Map<String, int>.from(data['scores'] ?? {}),
            'analysis': data['analysis'] ?? '',
            'title': data['title'] ?? '',
            'last_updated': lastUpdated,
          };
        }
      }

      // 2. Fetch Wardrobe Items (No cache or force refresh)
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('closet')
          .get();

      if (snapshot.docs.isEmpty) {
        // ... (Default empty state) ...
        return {
          'scores': {
            'Casual': 60,
            'Classic': 40,
            'Sporty': 30,
            'Vintage': 20,
            'Minimal': 50,
          },
          'analysis':
              "Not enough data yet. You can strengthen your style analysis by adding more items to your wardrobe.",
          'title': "Style Explorer"
        };
      }

      // 3. Prepare Data Summary for AI
      StringBuffer closetSummary = StringBuffer();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        closetSummary.writeln(
            "- ${data['color']} ${data['subcategory'] ?? data['category']} (${data['brand'] ?? 'Unknown Brand'})");
      }

      // 4. Prompt Gemini
      final prompt = '''
Analyze the following wardrobe items and provide a style profile.

Wardrobe Items:
${closetSummary.toString()}

From the following list of 12 style categories, select the TOP 5 that best match the user's wardrobe:
['Streetwear', 'Elegant', 'Modern', 'Bohemian', 'Luxury', 'Edgy', 'Urban', 'Casual', 'Classic', 'Sporty', 'Vintage', 'Minimal']

Return ONLY a valid JSON object with the following structure:
{
  "scores": {
    "Category1": [0-100],
    "Category2": [0-100],
    "Category3": [0-100],
    "Category4": [0-100],
    "Category5": [0-100]
  },
  "analysis": "Describe the user's overall style persona in 2-3 sentences using a friendly, sincere, and engaging tone. Do NOT mention specific brands or product names (e.g. Caterpillar, Nike). Focus on the 'vibe', color palette, and general aesthetic (e.g. 'The earthy tones and relaxed cuts in your wardrobe show you lean towards natural style.').",
  "title": "A cool, 1-2 word style title in English (e.g. 'Minimalist Vanguard', 'Street Fashion', 'Vintage Soul', 'Sporty Chic')."
}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      // 5. Parse and Cache JSON
      final parsedData = _parseResponse(responseText);

      // Save to cache
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('style_dna')
          .doc('current')
          .set({
        ...parsedData,
        'last_updated': FieldValue.serverTimestamp(),
      });

      return parsedData;
    } catch (e) {
      print("Style DNA Analysis Failed: $e");
      return {
        'scores': {
          'Casual': 50,
          'Classic': 50,
          'Sporty': 50,
          'Vintage': 50,
          'Minimal': 50,
        },
        'analysis': "",
        'title': "Stil Yolcusu"
      };
    }
  }

  Map<String, dynamic> _parseResponse(String responseText) {
    try {
      String jsonText = responseText;
      if (jsonText.contains('```json')) {
        jsonText =
            jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (jsonText.contains('```')) {
        jsonText = jsonText.replaceAll('```', '').trim();
      }

      final Map<String, dynamic> json = jsonDecode(jsonText);

      // Ensure specific structure
      final scores = Map<String, int>.from(json['scores'] ?? {});
      final analysis = json['analysis']?.toString() ?? "Analiz bulunamadı.";
      final title = json['title']?.toString() ?? "Stil Sahibi";

      return {
        'scores': scores,
        'analysis': analysis,
        'title': title,
      };
    } catch (e) {
      print("Error parsing Style DNA JSON: $e");
      return {
        'scores': {
          'Casual': 50,
          'Classic': 50,
          'Sporty': 50,
          'Vintage': 50,
          'Minimal': 50,
        },
        'analysis': "Error occurred while processing data.",
        'title': "Stil Kaşifi"
      };
    }
  }
}
