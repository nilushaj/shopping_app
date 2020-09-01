import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{

  // Create storage
  static final _storage = FlutterSecureStorage();

  //Read key from storage
  static Future<String> readValue(String key) async {
    return _storage.read(key: key);
  }

  //Read all values from storage
  static Future<Map<String, String>> readAllValues() async {
    return _storage.readAll();
  }

  //Delete key from storage
  static Future<void> deleteValue(String key) async {
    _storage.delete(key: key);
  }

  //Delete all keys from storage
  static Future<void> deleteAllValues() async {
    _storage.deleteAll();
  }

  //Write key value to storage
  static Future<void> writeValue(String key, dynamic value) async {
    _storage.write(key: key, value: value);
  }

}