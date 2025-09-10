import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertest/services/local/secure_storage/secure_storage_const.dart';

class SecureStorageService {
  final _secureStorage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(encryptedSharedPreferences: true);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(
      key: SecureStorageConst.token,
      value: token,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String?> readToken() async {
    return _secureStorage.read(
      key: SecureStorageConst.token,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(
      key: SecureStorageConst.token,
      aOptions: _getAndroidOptions(),
    );
  }

  /// Delete all from secure storage
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
  }
}
