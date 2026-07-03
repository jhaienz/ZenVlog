import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class LocalIdentity {
  static const _key = 'zenvlog_local_uuid';
  static const _storage = FlutterSecureStorage();

  static Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _key);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await _storage.write(key: _key, value: id);
    return id;
  }

  static Future<String> get current async => getOrCreate();
}
