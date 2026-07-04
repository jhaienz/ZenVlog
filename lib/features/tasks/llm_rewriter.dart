import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'task_template.dart';

/// Opt-in flavor layer (ADR-0005): rewrites a task description for the
/// exact spot/weather/time. Cosmetic only — task type, duration, and
/// requirements always come from the curated library, and the curated
/// text is always the fallback on any model failure.
///
/// Model provisioning is user-driven from Settings: paste a .task model
/// URL (e.g. Gemma3 1B int4 from HuggingFace litert-community), download
/// once, inference runs fully on-device via MediaPipe.
class LlmRewriter {
  static const _storage = FlutterSecureStorage();
  static const enabledKey = 'llm_enabled';
  static const modelInstalledKey = 'llm_model_installed';

  static InferenceModel? _model;

  static Future<bool> isEnabled() async =>
      await _storage.read(key: enabledKey) == 'true';

  static Future<void> setEnabled(bool value) =>
      _storage.write(key: enabledKey, value: '$value');

  static Future<bool> isModelInstalled() async =>
      await _storage.read(key: modelInstalledKey) == 'true';

  /// Downloads and activates a .task model. [onProgress] gets 0–100.
  static Future<void> downloadModel(
    String url, {
    String? token,
    void Function(double percent)? onProgress,
  }) async {
    var builder = FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.task,
    ).fromNetwork(url, token: token);
    if (onProgress != null) {
      builder = builder.withProgress((p) => onProgress(p.toDouble()));
    }
    await builder.install();
    await _storage.write(key: modelInstalledKey, value: 'true');
    _model = null; // reload with the new model on next rewrite
  }

  static Future<String> rewrite(
    TaskTemplate template, {
    required String spotName,
    required String timeOfDay,
  }) async {
    if (!await isEnabled() || !await isModelInstalled()) {
      return template.description;
    }
    try {
      _model ??= await FlutterGemma.getActiveModel(maxTokens: 512);
      final session = await _model!.createSession(temperature: 0.7);
      try {
        await session.addQueryChunk(Message.text(
          text: 'Rewrite this mindfulness task for someone at "$spotName" '
              'in the $timeOfDay. Keep the same activity and duration. '
              'One or two sentences, calm tone, no preamble:\n'
              '${template.description}',
          isUser: true,
        ));
        final out = (await session.getResponse()).trim();
        return out.isEmpty ? template.description : out;
      } finally {
        await session.close();
      }
    } catch (_) {
      return template.description; // curated text on any model failure
    }
  }
}
