import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:comby/core/core.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 EKSTRA: Fotoğrafı hemen storage'a yükle ve user_uploaded_files listesine ekle
Future<void> _uploadToUserUploadedFiles(File imageFile) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Firebase Storage'a yükle
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child(
        "user_uploaded_files/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

    final bytes = await imageFile.readAsBytes();
    final uploadTask = await ref.putData(bytes);
    final url = await uploadTask.ref.getDownloadURL();

    // Firestore'da user_uploaded_files listesine ekle
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(userId).update({
      'user_uploaded_files': FieldValue.arrayUnion([url])
    });

    debugPrint(
        '✅ Profil fotoğrafı user_uploaded_files listesine eklendi: $url');
  } catch (e) {
    debugPrint('❌ user_uploaded_files yüklenirken hata: $e');
    // Hata olsa bile kullanıcı deneyimini etkilemesin
  }
}

class ProfileImageNetwork extends StatelessWidget {
  final String? url;
  const ProfileImageNetwork({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return state.profileImageUploadStatus == EventStatus.processing
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.baseColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                height: 100.h,
                width: 100.h,
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: context.baseColor,
                  size: 24.h,
                ),
              )
            : GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    // SAFE AREA DÜZELTMESİ: Crop işleminden önce system UI'ı ayarla
                    SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                        statusBarColor: Color(0xFF452D54),
                        statusBarIconBrightness: Brightness.light,
                        systemNavigationBarColor: Color(0xFF452D54),
                        systemNavigationBarIconBrightness: Brightness.light,
                        systemNavigationBarDividerColor: Color(0xFF452D54),
                      ),
                    );

                    // CROP işlemi
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: pickedFile.path,
                      compressFormat: ImageCompressFormat.jpg, // JPEG formatı
                      maxWidth: 2048, // Maksimum genişlik
                      maxHeight: 2048, // Maksimum yükseklik
                      uiSettings: cropperUiSettings,
                    );

                    // SAFE AREA DÜZELTMESİ: Crop işleminden sonra system UI'ı geri yükle
                    SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                        statusBarColor: Colors.white,
                        statusBarIconBrightness: Brightness.dark,
                        systemNavigationBarColor: Colors.white,
                        systemNavigationBarIconBrightness: Brightness.dark,
                      ),
                    );

                    if (croppedFile != null) {
                      final file = File(croppedFile.path);

                      // Mevcut profil fotosu güncelleme
                      getIt<ProfileBloc>().add(UpdateProfileImageEvent(file));

                      // 🔥 EKSTRA: Fotoğrafı hemen storage'a yükle ve user_uploaded_files listesine ekle
                      _uploadToUserUploadedFiles(file);
                    }
                  }
                },
                child: Container(
                  height: 100.h,
                  width: 100.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.baseColor,
                      width: 3.w,
                    ),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: CircleAvatar(
                    radius: 60.h,
                    backgroundImage: url != null && url!.isNotEmpty
                        ? NetworkImage(url!)
                        : null,
                    backgroundColor: context.baseColor,
                    child: url == null || url!.isEmpty
                        ? Text(
                            state.profileInfo?.displayName?.isNotEmpty == true
                                ? state.profileInfo!.displayName![0]
                                    .toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 32.h,
                              fontWeight: FontWeight.bold,
                              color: context.white,
                            ),
                          )
                        : null,
                  ),
                ),
              );
      },
    );
  }
}
