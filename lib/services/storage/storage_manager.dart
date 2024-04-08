import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static FlutterSecureStorage get storage => _storage;

  // prevent class instantiation
  SecureStorageManager._privateConstructor();
}
