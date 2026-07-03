import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/core/identity/local_identity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('getOrCreate returns non-empty UUID', () async {
    final id = await LocalIdentity.getOrCreate();
    expect(id, isNotEmpty);
    expect(id.length, 36); // UUID v4 length
  });

  test('getOrCreate returns same UUID on repeated calls', () async {
    final id1 = await LocalIdentity.getOrCreate();
    final id2 = await LocalIdentity.getOrCreate();
    expect(id1, equals(id2));
  });
}
