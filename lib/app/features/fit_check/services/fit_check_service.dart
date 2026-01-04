import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginfit/core/core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ginfit/app/features/fit_check/models/fit_check_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class FitCheckService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  late final GenerativeModel _geminiModel;

  // Using the same API key as other services for consistency

  FitCheckService(this._auth, this._firestore, this._storage) {
    _geminiModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
    );
  }

  /// Uploads the image to Firebase Storage and returns the download URL
  Future<String> uploadFitCheckImage(File imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final fileName = 'fit_check_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$userId/fit_checks/$fileName');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Analyzes the image using Gemini Vision to extract metadata
  Future<Map<String, dynamic>> analyzeFitCheckImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      const prompt = '''
      Analyze this outfit photo strictly for fashion analytics.
      Return ONLY a valid JSON object with the following fields:
      
      1. "colorPalette": A map where keys are color names (e.g., "Black", "Navy", "Beige") and values are their approximate percentage dominance in the outfit (0.0 to 1.0). Total should sum to roughly 1.0. Ignore background colors, focus on clothing.
      2. "overallStyle": A single string describing the style (e.g., "Casual", "Formal", "Streetwear", "Athleisure", "Business Casual", "Vintage", "Minimalist").
      3. "detectedItems": A list of strings naming the visible clothing items (e.g., ["Leather Jacket", "White T-Shirt", "Blue Jeans", "Sneakers"]).
      4. "aiDescription": A cheerful, short styling compliment or observation (max 1 sentence).
      
      Example JSON:
      {
        "colorPalette": {"Black": 0.6, "Red": 0.4},
        "overallStyle": "Streetwear",
        "detectedItems": ["Black Hoodie", "Red Joggers", "Sneakers"],
        "aiDescription": "Love the bold red and black contrast, looks very energetic!"
      }
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _geminiModel.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      return _parseJsonResponse(responseText);
    } catch (e) {
      // In case of error (e.g., safety block), return empty metadata but don't crash
      print('Gemini Analysis Error: $e');
      return {
        'colorPalette': <String, double>{},
        'overallStyle': 'Unknown',
        'detectedItems': <String>[],
        'aiDescription': 'Looking good!',
      };
    }
  }

  /// Saves the FitCheckLog to the user's sub-collection
  Future<void> saveFitCheck(FitCheckLog log) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fit_checks')
          .doc(log.id)
          .set(log.toMap());
    } catch (e) {
      throw Exception('Failed to save fit check: $e');
    }
  }

  /// Helper to parse JSON from Markdown code blocks
  Map<String, dynamic> _parseJsonResponse(String text) {
    try {
      String jsonString = text;
      if (jsonString.contains('```json')) {
        jsonString = jsonString.split('```json')[1].split('```')[0].trim();
      } else if (jsonString.contains('```')) {
        jsonString = jsonString.split('```')[1].split('```')[0].trim();
      }
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON Parse Error: $e');
      return {};
    }
  }

  /// Get recent fit checks
  Future<List<FitCheckLog>> getRecentFitChecks({int limit = 10}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('fit_checks')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => FitCheckLog.fromMap(doc.data())).toList();
  }

  /// Stream fit checks for a specific month
  Stream<List<FitCheckLog>> getFitChecksForMonthStream(DateTime month) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    // Calculate start and end of the month
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('fit_checks')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FitCheckLog.fromMap(doc.data()))
          .toList();
    });
  }

  /// Calculates the current streak of consecutive days with Fit Checks
  Future<int> calculateStreak() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    // improved query: fetch only needed fields (createdAt) and limited to recent past
    // However, for simplicity and strictness, we fetch recent 30 logs.
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('fit_checks')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final logs = snapshot.docs.map((doc) {
      final data = doc.data();
      return (data['createdAt'] as Timestamp).toDate();
    }).toList();

    if (logs.isEmpty) return 0;

    // Normalize dates to remove time
    final normalizedDates = logs
        .map((date) {
          return DateTime(date.year, date.month, date.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    if (normalizedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized =
        todayNormalized.subtract(const Duration(days: 1));

    // Check if streak is active (has entry for today or yesterday)
    if (!normalizedDates.contains(todayNormalized) &&
        !normalizedDates.contains(yesterdayNormalized)) {
      return 0;
    }

    int streak = 0;
    // Start checking from today (or yesterday if today is missing)
    DateTime checkDate = normalizedDates.contains(todayNormalized)
        ? todayNormalized
        : yesterdayNormalized;

    while (normalizedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
