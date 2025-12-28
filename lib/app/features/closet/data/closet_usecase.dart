import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginfit/app/features/closet/models/closet_item_model.dart';
import 'package:ginfit/app/features/closet/models/model_item_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:injectable/injectable.dart';

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

      final snapshot = await firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      final modelsList = data?['models'] as List<dynamic>? ?? [];

      log('Model items count: ${modelsList.length}');

      return modelsList
          .map((itemJson) {
            try {
              final map = Map<String, dynamic>.from(itemJson);
              return ModelItem.fromMap(map);
            } catch (e) {
              log('Error parsing model item: $e');
              return null;
            }
          })
          .whereType<ModelItem>()
          .toList();
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

      final userDocRef = firestore.collection('users').doc(userId);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        await userDocRef.set({'models': []});
      }

      final data = docSnapshot.data();
      final List<dynamic> modelsList = data?['models'] ?? [];

      modelsList.add(item.toMap());

      await userDocRef.update({'models': modelsList});

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

      final userDocRef = firestore.collection('users').doc(userId);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) return EventStatus.failure;

      final data = docSnapshot.data();
      final List<dynamic> modelsList = data?['models'] ?? [];

      final updatedList = modelsList.where((itemMap) {
        final map = Map<String, dynamic>.from(itemMap);
        return map['id'] != itemId;
      }).toList();

      await userDocRef.update({'models': updatedList});

      log('Model item deleted successfully');
      return EventStatus.success;
    } catch (e) {
      log('deleteModelItem error: $e');
      return EventStatus.failure;
    }
  }

  // ==================== CLOSET METHODS ====================

  Future<List<ClosetItem>> getUserClosetItems() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      final closetList = data?['closet'] as List<dynamic>? ?? [];

      log('Closet items count: ${closetList.length}');

      return closetList
          .map((itemJson) {
            try {
              final map = Map<String, dynamic>.from(itemJson);
              return ClosetItem.fromMap(map);
            } catch (e) {
              log('Error parsing closet item: $e');
              return null;
            }
          })
          .whereType<ClosetItem>()
          .toList();
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

  Future<EventStatus> addClosetItem(ClosetItem item) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      final userDocRef = firestore.collection('users').doc(userId);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        // Kullanıcı dokümanı yoksa oluştur
        await userDocRef.set({'closet': []});
      }

      final data = docSnapshot.data();
      final List<dynamic> closetList = data?['closet'] ?? [];

      // Yeni item'ı listeye ekle
      closetList.add(item.toMap());

      // Firestore'a güncelle
      await userDocRef.update({'closet': closetList});

      log('Closet item added successfully');
      return EventStatus.success;
    } catch (e) {
      log('addClosetItem error: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus> updateClosetItem(ClosetItem item) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      final userDocRef = firestore.collection('users').doc(userId);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        return EventStatus.failure;
      }

      final data = docSnapshot.data();
      final List<dynamic> closetList = data?['closet'] ?? [];

      // Item'ı güncelle (aynı ID'ye sahip olanı bul ve değiştir)
      final updatedList = closetList.map((itemMap) {
        final map = Map<String, dynamic>.from(itemMap);
        if (map['id'] == item.id) {
          return item.toMap();
        }
        return itemMap;
      }).toList();

      // Firestore'a güncelle
      await userDocRef.update({'closet': updatedList});

      log('Closet item updated successfully');
      return EventStatus.success;
    } catch (e) {
      log('updateClosetItem error: $e');
      return EventStatus.failure;
    }
  }
}
