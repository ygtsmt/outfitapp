import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer';

@lazySingleton
class MockDataService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MockDataService(this._firestore, this._auth);

  /// Copies mock data from global collections to the user's private collections
  Future<void> copyMockDataToUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to load mock data');
    }

    try {
      log('🚀 Starting Mock Data Load for user: ${user.uid}');

      // 1. Copy Closet Items
      final mockClosetSnapshot =
          await _firestore.collection('mock-closet-item').get();

      log('📦 Found ${mockClosetSnapshot.docs.length} mock closet items');

      final closetBatch = _firestore.batch();
      for (var doc in mockClosetSnapshot.docs) {
        // Create a new ID for the user's copy to avoid conflicts if run multiple times
        // Or keep original ID? Let's generate new ID but keep data
        final newItemRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('closet')
            .doc(); // Auto-ID

        // Get data and update createdAt to now
        final data = doc.data();
        data['id'] = newItemRef.id;
        data['createdAt'] = FieldValue.serverTimestamp();

        closetBatch.set(newItemRef, data);
      }
      await closetBatch.commit();
      log('✅ Closet items copied successfully');

      // 2. Copy Model Items
      final mockModelSnapshot =
          await _firestore.collection('mock-model-item').get();

      log('📸 Found ${mockModelSnapshot.docs.length} mock model items');

      final modelBatch = _firestore.batch();
      for (var doc in mockModelSnapshot.docs) {
        final newItemRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('models')
            .doc(); // Auto-ID

        final data = doc.data();
        data['id'] = newItemRef.id;
        data['createdAt'] = FieldValue.serverTimestamp();

        modelBatch.set(newItemRef, data);
      }
      await modelBatch.commit();
      log('✅ Model items copied successfully');
    } catch (e) {
      log('❌ Error loading mock data: $e');
      throw e;
    }
  }
}
