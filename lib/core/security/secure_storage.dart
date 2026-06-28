
// ─────────────────────────────────────────────────────────────────────────────
// FILE 2: secure_storage.dart
// ─────────────────────────────────────────────────────────────────────────────
 
/// يحفظ التوكن في Keychain (iOS) أو Keystore المشفر (Android)
/// بدلاً من SharedPreferences الذي يحفظ نصاً عادياً غير مشفر
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // AES-256 على Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock, // AES-256 على Android
    ),
  );

  static const _keyToken       = 'jwt_token';
  static const _keyTokenSavedAt = 'jwt_saved_at';


  Future<void> saveToken(String token) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(
        key: _keyTokenSavedAt,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ]);
  }


  Future<String?> readToken() => _storage.read(key: _keyToken);

  Future<DateTime?> readTokenSavedAt() async {
    final raw = await _storage.read(key: _keyTokenSavedAt);
    if (raw == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(raw));
  }


  Future<void> deleteToken() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyTokenSavedAt),
    ]);
  }

  Future<void> deleteAll() => _storage.deleteAll();


  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }
}