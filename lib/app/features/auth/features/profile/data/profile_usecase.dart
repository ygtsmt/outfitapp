import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginfit/app/features/auth/features/profile/data/models/user_model.dart';
import 'package:ginfit/core/data_sources/local_data_source/secure_data_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:image/image.dart' as img;

@injectable
class ProfileUseCase {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;
  final SecureDataStorage secureDataStorage;

  ProfileUseCase({
    required this.auth,
    required this.googleSignIn,
    required this.firestore,
    required this.secureDataStorage,
  });

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          /*      // Silinmiş kullanıcıları kontrol et
          if (data['deleted'] == true) {
            return null; // Silinmiş kullanıcı için null döndür
          } */

          var userProfile = UserProfile.fromJson(data);
          if (userProfile.photoURL != null &&
              userProfile.photoURL!.contains('=s96-c')) {
            userProfile.photoURL =
                userProfile.photoURL!.replaceFirst('=s96-c', '=s512-c');
          }
          log(userProfile.displayName ?? 's');
          return userProfile;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
      await secureDataStorage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid != null) {
        // Firestore'da veriyi silmek yerine "deleted" olarak işaretle
        await firestore.collection('users').doc(uid).update({
          'deleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'profile_info.displayName': AppLocalizations.current.deletedUser,
          'profile_info.photoURL': null,
        });
      }

      // Firebase Auth'dan kullanıcıyı tamamen sil
      await auth.currentUser?.delete();
      await googleSignIn.signOut();
      await secureDataStorage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      var credential = EmailAuthProvider.credential(
          email: user!.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfileImageUrl(String photoUrl) async {
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      await firestore.collection('users').doc(uid).update({
        'profile_info.photoURL': photoUrl,
      });
    } else {
      throw Exception('Profile photo changed error!');
    }
  }

  Future<File> compressImage(File file) async {
    final rawImage = img.decodeImage(await file.readAsBytes());
    final resized = img.copyResize(rawImage!, width: 600); // veya 800
    final compressed = File(file.path)
      ..writeAsBytesSync(img.encodeJpg(resized, quality: 80));
    return compressed;
  }

  Future<String?> updateProfilePhoto(File imageFile) async {
    try {
      final userId = auth.currentUser!.uid;
      final FirebaseStorage storage = FirebaseStorage.instance;
      final ref = storage.ref().child('profile_images').child('$userId.jpg');
      try {
        final compressedImage = await compressImage(imageFile);
        final bytes = await compressedImage.readAsBytes();
        await ref.putData(bytes);
      } on FirebaseException catch (e) {
        log('Firebase exception: ${e.message}');
        rethrow;
      } catch (e) {
        log('General exception: $e');
        rethrow;
      }
      final imageUrl = await ref.getDownloadURL();
      log(imageUrl);
      await firestore
          .collection('users')
          .doc(userId)
          .update({'profile_info.photoURL': imageUrl});

      return imageUrl;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid != null) {
        await firestore.collection('users').doc(uid).update({
          'profile_info.displayName': newUsername,
        });
      } else {
        throw Exception('Username update error!');
      }
    } catch (e) {
      rethrow;
    }
  }
}
