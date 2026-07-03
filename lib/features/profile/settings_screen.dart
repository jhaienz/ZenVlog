import 'package:flutter/material.dart';
import '../tasks/llm_rewriter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _llmEnabled = false;

  @override
  void initState() {
    super.initState();
    LlmRewriter.isEnabled().then((v) {
      if (mounted) setState(() => _llmEnabled = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Richer task descriptions'),
            subtitle: const Text(
                'On-device AI rewrites task text for your exact spot. '
                'Coming soon — curated descriptions are used for now.'),
            value: _llmEnabled,
            onChanged: (v) {
              LlmRewriter.setEnabled(v);
              setState(() => _llmEnabled = v);
            },
          ),
        ],
      ),
    );
  }
}
