import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(
        // clientId: '339980816419-dl1cgrs4dbaoc2od21thd11a5aivaq67.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

  @lazySingleton
  http.Client get httpClient => http.Client();

  @lazySingleton
  String get baseUrl => ApiConstants.baseUrl;
}
