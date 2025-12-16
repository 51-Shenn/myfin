import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveEmail(String email);
  Future<String?> getSavedEmail();
  Future<void> clearSavedEmail();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String _cachedEmailKey = 'CACHED_EMAIL';

  @override
  Future<void> saveEmail(String email) async {
    await sharedPreferences.setString(_cachedEmailKey, email);
  }

  @override
  Future<String?> getSavedEmail() async {
    return sharedPreferences.getString(_cachedEmailKey);
  }

  @override
  Future<void> clearSavedEmail() async {
    await sharedPreferences.remove(_cachedEmailKey);
  }
}
