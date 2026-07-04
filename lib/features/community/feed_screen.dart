import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import 'feed_provider.dart';
import 'post.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ZenVlog Feed'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
              Tab(text: 'Nearby'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FeedList(tab: FeedTab.forYou),
            _FeedList(tab: FeedTab.following),
            _FeedList(tab: FeedTab.nearby),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(kComposePostRoute),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _FeedList extends ConsumerWidget {
  final FeedTab tab;
  const _FeedList({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(feedNotifierProvider(tab));
    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load feed: $e', textAlign: TextAlign.center),
        ),
      ),
      data: (posts) => posts.isEmpty
          ? const Center(child: Text('No posts yet'))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => _PostCard(post: posts[i]),
            ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.placeName != null)
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFFD4A853), size: 14),
                    const SizedBox(width: 4),
                    Text(post.placeName!,
                        style: const TextStyle(
                            color: Color(0xFF1A3A2A),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              const SizedBox(height: 8),
              Text(post.content,
                  style: const TextStyle(color: Color(0xFF1A3A2A))),
              if (post.mediaUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.mediaUrl!,
                      height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '@${post.userId} · ${_timeAgo(post.createdAt)}',
                style:
                    const TextStyle(color: Color(0xFF1A3A2A), fontSize: 12),
              ),
            ],
          ),
        ),
      );

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
