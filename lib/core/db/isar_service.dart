import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> open(
    List<CollectionSchema<dynamic>> schemas, {
    String? directory,
  }) async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
    _instance = await Isar.open(schemas, directory: dir);
    return _instance!;
  }

  static Isar get instance {
    assert(_instance != null && _instance!.isOpen, 'Call IsarService.open() first');
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
