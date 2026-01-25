import "package:dio/dio.dart";
import "package:injectable/injectable.dart";
import 'package:firebase_storage/firebase_storage.dart';

@module
@singleton
abstract class DioModule {
  @singleton
  Dio dio() {
    // Hackathon için basit timeout yapılandırması
    // 3-5 kullanıcı için yeterli
    return Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 60),
    ));
  }
}

@module
@singleton
abstract class RegisterModule {
  @singleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;
}
