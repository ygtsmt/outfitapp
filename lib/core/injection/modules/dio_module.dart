import "package:dio/dio.dart";
import "package:injectable/injectable.dart";
import 'package:firebase_storage/firebase_storage.dart';

@module
@singleton
abstract class DioModule {
  @singleton
  Dio dio() => Dio();
}

@module
@singleton
abstract class RegisterModule {
  @singleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;
}
