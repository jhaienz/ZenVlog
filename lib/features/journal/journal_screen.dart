import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_entry.dart';
import 'journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Journal')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No entries yet'))
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (_, i) => _EntryTile(entry: entries[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTextEntry(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTextEntry(BuildContext context, WidgetRef ref) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _TextEntryDialog(),
    );
    if (text != null && text.isNotEmpty) {
      await ref
          .read(journalNotifierProvider.notifier)
          .add(type: 'text', content: text);
    }
  }
}

class _EntryTile extends StatelessWidget {
  final JournalEntry entry;
  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(_iconFor(entry.type), color: const Color(0xFFD4A853)),
        title: Text(
          entry.type == 'text' ? entry.content : entry.type.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: entry.spotName == null
            ? null
            : Text(entry.spotName!, style: const TextStyle(fontSize: 12)),
        trailing: Text(
          '${entry.createdAt.day}/${entry.createdAt.month} '
          '${entry.createdAt.hour}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 11),
        ),
      );

  IconData _iconFor(String type) => switch (type) {
        'audio' => Icons.mic,
        'photo' => Icons.photo,
        'sketch' => Icons.draw,
        _ => Icons.notes,
      };
}

class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog();
  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('New Entry'),
        content: TextField(
          controller: _ctrl,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Your reflection...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, _ctrl.text),
              child: const Text('Save')),
        ],
      );
}
