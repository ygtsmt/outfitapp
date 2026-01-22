import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/app/features/closet/services/closet_analysis_service.dart';

@injectable
class ClosetUseCase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  ClosetUseCase({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  // ==================== MODEL METHODS ====================

  Future<List<ModelItem>> getUserModelItems() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('models')
          .get();

      final modelsList = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              return ModelItem.fromMap(data);
            } catch (e) {
              log('Error parsing model item: $e');
              return null;
            }
          })
          .whereType<ModelItem>()
          .toList();

      log('Model items count: ${modelsList.length}');
      return modelsList;
    } catch (e) {
      log("getUserModelItems error: $e");
      return [];
    }
  }

  Future<String> uploadModelImage(File imageFile) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final ref = storage.ref().child(
          "model_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      log('uploadModelImage error: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  Future<EventStatus> addModelItem(ModelItem item) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('models')
          .doc(item.id)
          .set(item.toMap());

      log('Model item added successfully');
      return EventStatus.success;
    } catch (e) {
      log('addModelItem error: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus> deleteModelItem(String itemId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('models')
          .doc(itemId)
          .delete();

      log('Model item deleted successfully');
      return EventStatus.success;
    } catch (e) {
      log('deleteModelItem error: $e');
      return EventStatus.failure;
    }
  }

  // ==================== CLOSET METHODS ====================

  Future<List<WardrobeItem>> getUserClosetItems() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('closet')
          .get();

      final closetList = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              return WardrobeItem.fromMap(data);
            } catch (e) {
              log('Error parsing closet item: $e');
              return null;
            }
          })
          .whereType<WardrobeItem>()
          .toList();

      log('Closet items count: ${closetList.length}');
      return closetList;
    } catch (e) {
      log("getUserClosetItems error: $e");
      return [];
    }
  }

  Future<String> uploadClosetImage(File imageFile) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final ref = storage.ref().child(
          "closet_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      log('uploadClosetImage error: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  /// Upload transparent (background-removed) image bytes to Firebase Storage
  /// Returns the Firebase Storage URL of the uploaded transparent image
  Future<String> uploadTransparentClosetImage(List<int> imageBytes) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final ref = storage.ref().child(
          "closet_images/$userId/${DateTime.now().millisecondsSinceEpoch}.png");

      final uploadTask = await ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/png'),
      );
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      log('uploadTransparentClosetImage error: $e');
      throw Exception('Error uploading transparent image: $e');
    }
  }

  /// Delete an image from Firebase Storage by its download URL
  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
      log('Image deleted from storage: $imageUrl');
    } catch (e) {
      log('deleteImageFromStorage error: $e');
      // Don't throw - if delete fails, it's not critical
    }
  }

  Future<EventStatus> addClosetItem(WardrobeItem item) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('closet')
          .doc(item.id)
          .set(item.toMap());

      log('Closet item added successfully');

      // Update aggregated stats
      try {
        GetIt.I<WardrobeAnalysisService>()
            .updateAggregatedStats(userId, item, isAdd: true);
      } catch (e) {
        log('Error updating stats on add: $e');
      }

      return EventStatus.success;
    } catch (e) {
      log('addClosetItem error: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus> updateClosetItem(WardrobeItem item) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('closet')
          .doc(item.id)
          .update(item.toMap());

      log('Closet item updated successfully');

      // Recalculate stats fully on update (since we don't know old values to decrement)
      try {
        GetIt.I<WardrobeAnalysisService>().recalculateAndSaveStats(userId);
      } catch (e) {
        log('Error updating stats on update: $e');
      }

      return EventStatus.success;
    } catch (e) {
      log('updateClosetItem error: $e');
      return EventStatus.failure;
    }
  }
}
