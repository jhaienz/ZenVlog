import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_env.dart';
import '../../core/auth/auth_service.dart';
import 'post.dart';
part 'feed_provider.g.dart';

enum FeedTab { forYou, following, nearby }

/// Dev builds have no Supabase — feed is an in-memory fake so the whole
/// community flow is testable without API keys.
final _devPosts = <Post>[
  Post(
    id: 'dev-1',
    userId: 'maya',
    content: 'Found a silent clearing above the rice terraces. '
        'Recorded five minutes of nothing but wind.',
    placeName: 'Hidden Ridge',
    latFuzzy: 13.62,
    lngFuzzy: 123.19,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Post(
    id: 'dev-2',
    userId: 'rohan',
    content: 'Stone stacking by the creek. Harder than it looks.',
    placeName: 'Creekside Hollow',
    latFuzzy: 13.65,
    lngFuzzy: 123.21,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Post(
    id: 'dev-3',
    userId: 'aiko',
    content: 'Sunrise start. Trail to myself the whole way up.',
    placeName: 'Old Forest Path',
    latFuzzy: 13.58,
    lngFuzzy: 123.27,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

@riverpod
class FollowsNotifier extends _$FollowsNotifier {
  @override
  Future<Set<String>> build() async {
    if (isDev) return {};
    final res = await Supabase.instance.client
        .from('follows')
        .select('following_id')
        .eq('follower_id', AuthService.userId);
    return res.map((e) => e['following_id'] as String).toSet();
  }

  Future<void> toggle(String userId) async {
    final current = state.value ?? {};
    final following = current.contains(userId);
    if (!isDev) {
      final client = Supabase.instance.client;
      if (following) {
        await client
            .from('follows')
            .delete()
            .eq('follower_id', AuthService.userId)
            .eq('following_id', userId);
      } else {
        await client.from('follows').insert(
            {'follower_id': AuthService.userId, 'following_id': userId});
      }
    }
    state = AsyncData(following
        ? (current.toSet()..remove(userId))
        : (current.toSet()..add(userId)));
    ref.invalidate(feedNotifierProvider(FeedTab.following));
  }
}

@riverpod
class FeedNotifier extends _$FeedNotifier {
  @override
  Future<List<Post>> build(FeedTab tab) async {
    if (isDev) {
      // ponytail: dev fake feed; Following filters by local follow set
      if (tab == FeedTab.following) {
        final follows = await ref.watch(followsNotifierProvider.future);
        return _devPosts.reversed
            .where((p) => follows.contains(p.userId))
            .toList();
      }
      return _devPosts.reversed.toList();
    }
    return _fetchPosts(tab);
  }

  Future<List<Post>> _fetchPosts(FeedTab tab) async {
    final client = Supabase.instance.client;
    switch (tab) {
      case FeedTab.forYou:
        final res = await client
            .from('posts')
            .select()
            .order('created_at', ascending: false)
            .limit(30);
        return res.map(Post.fromJson).toList();

      case FeedTab.following:
        if (!AuthService.isSignedIn) return [];
        final followedRes = await client
            .from('follows')
            .select('following_id')
            .eq('follower_id', AuthService.userId);
        final followedIds =
            followedRes.map((e) => e['following_id'] as String).toList();
        if (followedIds.isEmpty) return [];
        final res = await client
            .from('posts')
            .select()
            .inFilter('user_id', followedIds)
            .order('created_at', ascending: false)
            .limit(30);
        return res.map(Post.fromJson).toList();

      case FeedTab.nearby:
        // ponytail: recency-ordered geo-tagged posts; st_dwithin RPC when
        // nearby needs real distance filtering
        final res = await client
            .from('posts')
            .select()
            .not('lat_fuzzy', 'is', null)
            .order('created_at', ascending: false)
            .limit(30);
        return res.map(Post.fromJson).toList();
    }
  }

  Future<void> createPost({
    required String content,
    required String placeName,
    required double exactLat,
    required double exactLng,
    File? mediaFile,
  }) async {
    // Fuzzy: 2 decimal places ~ 1km. Exact coords never sent.
    final post = Post(
      id: '',
      userId: AuthService.userId,
      content: content,
      placeName: placeName,
      latFuzzy: double.parse(exactLat.toStringAsFixed(2)),
      lngFuzzy: double.parse(exactLng.toStringAsFixed(2)),
      createdAt: DateTime.now(),
    );

    if (isDev) {
      _devPosts.add(post);
      ref.invalidateSelf();
      return;
    }

    if (!AuthService.isSignedIn) throw Exception('Sign in required to post');

    String? mediaUrl;
    if (mediaFile != null) {
      final client = Supabase.instance.client;
      final path =
          'posts/${AuthService.userId}/${DateTime.now().millisecondsSinceEpoch}';
      await client.storage.from('post-media').upload(path, mediaFile);
      mediaUrl = client.storage.from('post-media').getPublicUrl(path);
    }

    await Supabase.instance.client.from('posts').insert({
      ...post.toJson(),
      if (mediaUrl != null) 'media_url': mediaUrl,
    });
    ref.invalidateSelf();
  }
}
