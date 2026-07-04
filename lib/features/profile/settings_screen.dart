import 'package:flutter/material.dart';
import '../tasks/llm_rewriter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _llmEnabled = false;
  bool _modelInstalled = false;
  double? _downloadPercent;
  String? _downloadError;
  final _urlCtrl = TextEditingController(
      text: 'https://huggingface.co/litert-community/Gemma3-1B-IT/'
          'resolve/main/gemma3-1b-it-int4.task');
  final _tokenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    LlmRewriter.isEnabled().then((v) {
      if (mounted) setState(() => _llmEnabled = v);
    });
    LlmRewriter.isModelInstalled().then((v) {
      if (mounted) setState(() => _modelInstalled = v);
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Richer task descriptions'),
            subtitle: Text(_modelInstalled
                ? 'On-device AI rewrites task text for your exact spot.'
                : 'Needs the model below. Curated descriptions are used '
                    'until it is downloaded.'),
            value: _llmEnabled,
            onChanged: (v) {
              LlmRewriter.setEnabled(v);
              setState(() => _llmEnabled = v);
            },
          ),
          if (_llmEnabled) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('On-device model',
                  style: TextStyle(
                      color: Color(0xFFD4A853),
                      fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Downloads once (~550MB), then runs fully offline. '
                'Gemma models need a free HuggingFace token after '
                'accepting the license.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                    labelText: 'Model URL (.task)',
                    border: OutlineInputBorder()),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                    labelText: 'HuggingFace token (optional)',
                    border: OutlineInputBorder()),
                obscureText: true,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _downloadPercent != null
                  ? Column(
                      children: [
                        LinearProgressIndicator(
                            value: _downloadPercent! / 100,
                            color: const Color(0xFFD4A853),
                            backgroundColor: const Color(0xFF243D30)),
                        const SizedBox(height: 4),
                        Text('${_downloadPercent!.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _download,
                        icon: const Icon(Icons.download),
                        label: Text(_modelInstalled
                            ? 'Model installed — re-download'
                            : 'Download model'),
                      ),
                    ),
            ),
            if (_downloadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Download failed: $_downloadError',
                    style: const TextStyle(color: Colors.redAccent)),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _download() async {
    setState(() {
      _downloadPercent = 0;
      _downloadError = null;
    });
    try {
      final token = _tokenCtrl.text.trim();
      await LlmRewriter.downloadModel(
        _urlCtrl.text.trim(),
        token: token.isEmpty ? null : token,
        onProgress: (p) {
          if (mounted) setState(() => _downloadPercent = p);
        },
      );
      if (mounted) {
        setState(() {
          _modelInstalled = true;
          _downloadPercent = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadPercent = null;
          _downloadError = '$e';
        });
      }
    }
  }
}
