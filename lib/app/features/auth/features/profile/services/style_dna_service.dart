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

  Future<Map<String, dynamic>> analyzeStyle() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      // 1. Check for valid cached data
      final cacheDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('style_dna')
          .doc('current')
          .get();

      if (cacheDoc.exists) {
        final data = cacheDoc.data();
        if (data != null && data['last_updated'] != null) {
          final lastUpdated = (data['last_updated'] as Timestamp).toDate();
          final difference = DateTime.now().difference(lastUpdated).inDays;

          // If cache is less than 7 days old, use it
          if (difference < 7) {
            return {
              'scores': Map<String, int>.from(data['scores'] ?? {}),
              'analysis': data['analysis'] ?? '',
              'title': data['title'] ?? '',
            };
          }
        }
      }

      // 2. Fetch Wardrobe Items (No cache or expired)
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
              "Henüz yeterli veri yok. Dolabına daha fazla parça ekleyerek stil analizini güçlendirebilirsin.",
          'title': "Stil Kaşifi"
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
  "analysis": "Describe the user's overall style persona in 2-3 sentences using a friendly, sincere, and engaging Turkish tone. Do NOT mention specific brands or product names (e.g. Caterpillar, Nike). Focus on the 'vibe', color palette, and general aesthetic (e.g. 'Dolabındaki toprak tonları ve rahat kesimler, doğallıktan yana olduğunu gösteriyor.').",
  "title": "A cool, 1-2 word style title in Turkish (e.g. 'Minimalist Öncü', 'Sokak Modası', 'Vintage Ruh', 'Sportif Şık')."
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
        'analysis': "Veri işlenirken hata oluştu.",
        'title': "Stil Kaşifi"
      };
    }
  }
}
