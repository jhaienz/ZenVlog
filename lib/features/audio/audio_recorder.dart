import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ZenAudioRecorder {
  final _recorder = AudioRecorder();
  bool _recording = false;

  bool get isRecording => _recording;

  Future<void> start() async {
    if (!await _recorder.hasPermission()) return;
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    _recording = true;
  }

  Future<String?> stop() async {
    if (!_recording) return null;
    final path = await _recorder.stop();
    _recording = false;
    return path;
  }

  void dispose() => _recorder.dispose();
}
