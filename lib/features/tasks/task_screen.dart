import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../audio/audio_recorder.dart';
import '../explore/spot.dart';
import '../journal/journal_provider.dart';
import '../journey/journey_provider.dart';
import '../persona/persona_provider.dart';
import 'task.dart';
import 'task_provider.dart';
import 'task_template.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final Spot spot;
  const TaskScreen({super.key, required this.spot});
  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  TaskTemplate? _selected;
  Task? _assigned;
  bool _inProgress = false;
  int _elapsed = 0;
  Timer? _timer;
  final _recorder = ZenAudioRecorder();

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaNotifierProvider).value;
    if (persona == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final suggestionsAsync =
        ref.watch(taskSuggestionsProvider(widget.spot, persona));

    return Scaffold(
      appBar: AppBar(title: const Text('Your Micro-Task')),
      body: suggestionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (templates) => _selected == null
            ? _SuggestionList(templates: templates, onSelect: _accept)
            : _TaskInProgress(
                template: _selected!,
                elapsed: _elapsed,
                inProgress: _inProgress,
                onStart: _startTask,
                onComplete: _completeTask,
              ),
      ),
    );
  }

  Future<void> _accept(TaskTemplate template) async {
    final journey = ref.read(journeyNotifierProvider).value;
    if (journey == null) return;
    final task = await ref
        .read(taskNotifierProvider(journey.id).notifier)
        .assign(template.id, journey.id, widget.spot.osmId);
    setState(() {
      _selected = template;
      _assigned = task;
    });
  }

  void _startTask() {
    setState(() {
      _inProgress = true;
      _elapsed = 0;
    });
    if (_selected!.type == 'sound') _recorder.start();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _elapsed++));
  }

  Future<void> _completeTask() async {
    _timer?.cancel();
    String? filePath;
    if (_selected!.type == 'sound') filePath = await _recorder.stop();

    final journey = ref.read(journeyNotifierProvider).value;
    if (_assigned != null && journey != null) {
      await ref
          .read(taskNotifierProvider(journey.id).notifier)
          .complete(_assigned!, captureFilePath: filePath);
      await ref.read(journalNotifierProvider.notifier).add(
            type: _selected!.type == 'sound' ? 'audio' : 'text',
            content: filePath ?? 'Completed: ${_selected!.title}',
            journeyId: journey.id,
            lat: widget.spot.lat,
            lng: widget.spot.lng,
            spotName: widget.spot.name,
          );
    }
    if (mounted) context.pop();
  }
}

class _SuggestionList extends StatelessWidget {
  final List<TaskTemplate> templates;
  final void Function(TaskTemplate) onSelect;
  const _SuggestionList({required this.templates, required this.onSelect});

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (_, i) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(templates[i].title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A3A2A))),
                const SizedBox(height: 4),
                Text(templates[i].description,
                    style: const TextStyle(color: Color(0xFF1A3A2A))),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => onSelect(templates[i]),
                    child: const Text('Accept Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _TaskInProgress extends StatelessWidget {
  final TaskTemplate template;
  final int elapsed;
  final bool inProgress;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  const _TaskInProgress({
    required this.template,
    required this.elapsed,
    required this.inProgress,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(
                inProgress && template.type == 'sound'
                    ? 'Recording...'
                    : template.title,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('${elapsed}s / ${template.durationSeconds}s',
                style:
                    const TextStyle(color: Color(0xFFD4A853), fontSize: 24)),
            const SizedBox(height: 16),
            Text(template.description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (inProgress)
              const Text('Take a deep breath. Let the sounds around you emerge.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Color(0xFFD4A853))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: inProgress ? onComplete : onStart,
                child: Text(inProgress ? 'Complete Task' : 'Start Task'),
              ),
            ),
          ],
        ),
      );
}
