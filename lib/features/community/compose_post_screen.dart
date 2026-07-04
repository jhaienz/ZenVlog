import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _photo;

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
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo, size: 18),
                  label: Text(_photo == null ? 'Add photo' : 'Change photo'),
                ),
                if (_photo != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _photo = null),
                  ),
              ],
            ),
            if (_photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_photo!,
                    height: 140, width: double.infinity, fit: BoxFit.cover),
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

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked != null) setState(() => _photo = File(picked.path));
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
            mediaFile: _photo,
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
