import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'task_template.dart';

/// Opt-in flavor layer (ADR-0005): rewrites a task description for the
/// exact spot/weather/time. Cosmetic only — task type, duration, and
/// requirements always come from the curated library.
///
/// ponytail: on-device LLM not integrated — flutter_gemma needs manual
/// model provisioning (HF token + ~650MB download) and the current test
/// device is low-RAM. The seam + settings toggle exist; wire a model
/// here when one is worth shipping. Curated text is always the fallback.
class LlmRewriter {
  static const _storage = FlutterSecureStorage();
  static const enabledKey = 'llm_enabled';

  static Future<bool> isEnabled() async =>
      await _storage.read(key: enabledKey) == 'true';

  static Future<void> setEnabled(bool value) =>
      _storage.write(key: enabledKey, value: '$value');

  static Future<String> rewrite(
    TaskTemplate template, {
    required String spotName,
    required String timeOfDay,
  }) async {
    // No model integrated: curated description verbatim.
    return template.description;
  }
}
