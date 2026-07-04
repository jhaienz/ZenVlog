import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'feed_provider.dart';

class ComposePostScreen extends ConsumerStatefulWidget {
  final String? prefilledPlaceName;
  final double? lat;
  final double? lng;
  const ComposePostScreen(
      {super.key, this.prefilledPlaceName, this.lat, this.lng});

  @override
  ConsumerState<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends ConsumerState<ComposePostScreen> {
  final _contentCtrl = TextEditingController();
  bool _posting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share to Feed'),
        actions: [
          TextButton(
            onPressed: _posting ? null : _post,
            child: const Text('Post',
                style: TextStyle(color: Color(0xFFD4A853))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.prefilledPlaceName != null) ...[
              Row(children: [
                const Icon(Icons.location_on,
                    color: Color(0xFFD4A853), size: 16),
                const SizedBox(width: 4),
                Text(widget.prefilledPlaceName!,
                    style: const TextStyle(
                        color: Color(0xFFD4A853),
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              const Text('Approximate location shared (~1km)',
                  style: TextStyle(fontSize: 11)),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
            if (_posting) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _post() async {
    if (_contentCtrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    try {
      await ref
          .read(feedNotifierProvider(FeedTab.forYou).notifier)
          .createPost(
            content: _contentCtrl.text.trim(),
            placeName: widget.prefilledPlaceName ?? 'Unknown Place',
            exactLat: widget.lat ?? 0,
            exactLng: widget.lng ?? 0,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}
