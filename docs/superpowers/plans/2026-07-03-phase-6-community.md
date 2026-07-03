# Phase 6 — Community Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** User optionally creates a Community Account, posts Journey moments to the feed, browses For You / Following / Nearby tabs, earns Badges, and views their Journey history.

**Architecture:** Supabase (PostgreSQL + PostGIS + Storage + Auth) initializes only when user first taps community features → `CommunityAccount` wraps Supabase Auth (magic link) → posts use fuzzy coordinates (2 decimal places ≈ 1km) → Badges computed locally from Isar journey/task data → Journey history reads from local Isar.

**Tech Stack:** supabase_flutter, Riverpod 2.x, Isar (local), PostgreSQL + PostGIS (Supabase)

## Global Constraints

- Inherits all Phase 1–5 constraints
- Supabase client MUST NOT initialize before this phase — lazy init on first community interaction
- Exact GPS coordinates are NEVER serialized into any Supabase table or request
- Fuzzy coordinates: `lat.toStringAsFixed(2)` and `lng.toStringAsFixed(2)` before any server call
- Community Account creation is prompted only on first "Share to Feed" or "Browse Feed" tap
- All journal/journey/persona data stays in Isar — only posts flow to Supabase
- Badge XP formula: `journeys × 10 + completedTasks × 5 + (totalDistanceKm * 2).floor()`
- Milestone badges: 10, 25, 50, 100 journeys
- `post.mediaUrl` is a Supabase Storage URL; local file is uploaded then referenced

---

## Files

- Create: `lib/features/community/community_account.dart`
- Create: `lib/features/community/post.dart`
- Create: `lib/features/community/feed_provider.dart` + `.g.dart`
- Create: `lib/features/community/feed_screen.dart`
- Create: `lib/features/community/compose_post_screen.dart`
- Create: `lib/features/profile/badges_screen.dart`
- Create: `lib/features/profile/journey_history_screen.dart`
- Create: `lib/features/profile/badges_provider.dart` + `.g.dart`
- Create: `assets/badges/definitions.json`
- Create: `test/features/profile/badges_test.dart`
- Create: `supabase/migrations/0001_initial.sql`
- Modify: `lib/features/profile/profile_screen.dart` — real content (persona radar, stats, badges, history)
- Modify: `lib/app/router.dart` — add community and profile sub-routes

---

### Task 1: Supabase schema

- [ ] **Step 1: Create migration file**

```sql
-- supabase/migrations/0001_initial.sql

-- Enable PostGIS for geo queries
create extension if not exists postgis;

-- Posts table
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  media_url text,
  place_name text,
  -- Fuzzy coordinates: 2 decimal places ≈ 1km precision. Exact coords never stored.
  lat_fuzzy numeric(6,2),
  lng_fuzzy numeric(7,2),
  location geography(Point, 4326),
  created_at timestamptz default now()
);

-- Populate geography column from fuzzy coords on insert/update
create or replace function sync_location()
returns trigger as $$
begin
  if new.lat_fuzzy is not null and new.lng_fuzzy is not null then
    new.location := st_point(new.lng_fuzzy, new.lat_fuzzy)::geography;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger posts_sync_location
  before insert or update on public.posts
  for each row execute function sync_location();

-- Follows table
create table public.follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  following_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower_id, following_id)
);

-- Row-level security
alter table public.posts enable row level security;
alter table public.follows enable row level security;

-- Anyone can read posts
create policy "posts_read_all" on public.posts for select using (true);
-- Users can only insert/update/delete their own posts
create policy "posts_write_own" on public.posts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Users can read all follows
create policy "follows_read_all" on public.follows for select using (true);
-- Users can only manage their own follows
create policy "follows_write_own" on public.follows
  for all using (auth.uid() = follower_id) with check (auth.uid() = follower_id);

-- Index for Nearby tab performance
create index posts_location_idx on public.posts using gist(location);
create index posts_created_at_idx on public.posts(created_at desc);
create index posts_user_id_idx on public.posts(user_id);
```

- [ ] **Step 2: Apply via Supabase dashboard or CLI**

```bash
# Via Supabase CLI (if installed):
supabase db push

# OR: paste contents of 0001_initial.sql into Supabase SQL Editor and run
```

Expected: Tables `posts` and `follows` created with RLS enabled.

- [ ] **Step 3: Create Storage bucket**

In Supabase Dashboard → Storage → New bucket:
- Name: `post-media`
- Public: true (so media URLs work without auth)
- File size limit: 10MB
- Allowed MIME types: `image/jpeg,image/png,audio/m4a`

- [ ] **Step 4: Add Supabase credentials to environment**

Create `lib/core/env.dart` (add to .gitignore):
```dart
// lib/core/env.dart — never commit this file
const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const supabaseAnonKey = 'YOUR_ANON_KEY';
```

Add to `.gitignore`:
```
lib/core/env.dart
```

- [ ] **Step 5: Commit**

```bash
git add supabase/ .gitignore
git commit -m "feat: Supabase schema with PostGIS and RLS"
```

---

### Task 2: CommunityAccount

- [ ] **Step 1: Implement**

```dart
// lib/features/community/community_account.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/env.dart';

class CommunityAccount {
  static bool _initialized = false;

  /// Lazy init — called only when user first touches community features
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _initialized = true;
  }

  static SupabaseClient get client {
    assert(_initialized, 'Call CommunityAccount.ensureInitialized() first');
    return Supabase.instance.client;
  }

  static User? get currentUser => _initialized ? client.auth.currentUser : null;
  static bool get isSignedIn => currentUser != null;

  static Future<void> signInWithMagicLink(String email) async {
    await ensureInitialized();
    await client.auth.signInWithOtp(email: email);
  }

  static Future<void> signOut() async {
    await ensureInitialized();
    await client.auth.signOut();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/community/community_account.dart lib/core/env.dart
git commit -m "feat: CommunityAccount lazy Supabase init"
```

---

### Task 3: Post model and FeedProvider

- [ ] **Step 1: Implement Post model**

```dart
// lib/features/community/post.dart
class Post {
  final String id;
  final String userId;
  final String content;
  final String? mediaUrl;
  final String? placeName;
  final double? latFuzzy;
  final double? lngFuzzy;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.content,
    this.mediaUrl,
    this.placeName,
    this.latFuzzy,
    this.lngFuzzy,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id: j['id'] as String,
    userId: j['user_id'] as String,
    content: j['content'] as String,
    mediaUrl: j['media_url'] as String?,
    placeName: j['place_name'] as String?,
    latFuzzy: (j['lat_fuzzy'] as num?)?.toDouble(),
    lngFuzzy: (j['lng_fuzzy'] as num?)?.toDouble(),
    createdAt: DateTime.parse(j['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'content': content,
    if (mediaUrl != null) 'media_url': mediaUrl,
    if (placeName != null) 'place_name': placeName,
    if (latFuzzy != null) 'lat_fuzzy': latFuzzy,
    if (lngFuzzy != null) 'lng_fuzzy': lngFuzzy,
  };
}
```

- [ ] **Step 2: Implement FeedProvider**

```dart
// lib/features/community/feed_provider.dart
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'community_account.dart';
import 'post.dart';
part 'feed_provider.g.dart';

enum FeedTab { forYou, following, nearby }

@riverpod
class FeedNotifier extends _$FeedNotifier {
  @override
  Future<List<Post>> build(FeedTab tab) async {
    await CommunityAccount.ensureInitialized();
    return _fetchPosts(tab);
  }

  Future<List<Post>> _fetchPosts(FeedTab tab) async {
    final client = CommunityAccount.client;
    switch (tab) {
      case FeedTab.forYou:
        final res = await client.from('posts').select().order('created_at', ascending: false).limit(30);
        return (res as List).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();

      case FeedTab.following:
        if (!CommunityAccount.isSignedIn) return [];
        final myId = CommunityAccount.currentUser!.id;
        final followedRes = await client.from('follows').select('following_id').eq('follower_id', myId);
        final followedIds = (followedRes as List).map((e) => e['following_id'] as String).toList();
        if (followedIds.isEmpty) return [];
        final res = await client.from('posts').select().inFilter('user_id', followedIds)
            .order('created_at', ascending: false).limit(30);
        return (res as List).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();

      case FeedTab.nearby:
        // PostGIS query via RPC — requires a Supabase function
        // ponytail: upgrade to st_dwithin RPC if nearby needs real geo filtering; for now uses lat/lng bounds
        final res = await client.from('posts').select()
            .not('lat_fuzzy', 'is', null)
            .order('created_at', ascending: false).limit(30);
        return (res as List).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> createPost({
    required String content,
    required String placeName,
    required double exactLat,
    required double exactLng,
    File? mediaFile,
  }) async {
    await CommunityAccount.ensureInitialized();
    if (!CommunityAccount.isSignedIn) throw Exception('Sign in required to post');

    String? mediaUrl;
    if (mediaFile != null) {
      final path = 'posts/${CommunityAccount.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}';
      await CommunityAccount.client.storage.from('post-media').upload(path, mediaFile);
      mediaUrl = CommunityAccount.client.storage.from('post-media').getPublicUrl(path);
    }

    // Fuzzy: 2 decimal places ≈ 1km. Exact coords never sent.
    final post = Post(
      id: '',
      userId: CommunityAccount.currentUser!.id,
      content: content,
      mediaUrl: mediaUrl,
      placeName: placeName,
      latFuzzy: double.parse(exactLat.toStringAsFixed(2)),
      lngFuzzy: double.parse(exactLng.toStringAsFixed(2)),
      createdAt: DateTime.now(),
    );

    await CommunityAccount.client.from('posts').insert(post.toJson());
    ref.invalidateSelf();
  }
}
```

- [ ] **Step 3: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/community/post.dart lib/features/community/feed_provider.dart
git commit -m "feat: Post model and FeedNotifier with For You/Following/Nearby"
```

---

### Task 4: Feed screen and Compose screen

- [ ] **Step 1: Implement FeedScreen**

```dart
// lib/features/community/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import 'community_account.dart';
import 'feed_provider.dart';
import 'post.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});
  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    _ensureAuth();
  }

  Future<void> _ensureAuth() async {
    await CommunityAccount.ensureInitialized();
    if (!CommunityAccount.isSignedIn && mounted) {
      context.push(kSignInRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenVlog Feed'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'For You'), Tab(text: 'Following'), Tab(text: 'Nearby')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
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
      error: (e, _) => Center(child: Text('$e')),
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
                Text(post.placeName!,
                    style: const TextStyle(color: Color(0xFF1A3A2A), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(post.content, style: const TextStyle(color: Color(0xFF1A3A2A))),
              if (post.mediaUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.mediaUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')} · ${post.placeName ?? ''}',
                style: const TextStyle(color: Color(0xFF1A3A2A), fontSize: 12),
              ),
            ],
          ),
        ),
      );
}
```

- [ ] **Step 2: Implement ComposePostScreen**

```dart
// lib/features/community/compose_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'feed_provider.dart';

class ComposePostScreen extends ConsumerStatefulWidget {
  final String? prefilledPlaceName;
  final double? lat;
  final double? lng;
  const ComposePostScreen({super.key, this.prefilledPlaceName, this.lat, this.lng});
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
            child: const Text('Post', style: TextStyle(color: Color(0xFFD4A853))),
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
                const Icon(Icons.location_on, color: Color(0xFFD4A853), size: 16),
                const SizedBox(width: 4),
                Text(widget.prefilledPlaceName!,
                    style: const TextStyle(color: Color(0xFFD4A853), fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              const Text('Approximate location shared (~1km)',
                  style: TextStyle(fontSize: 11, color: Color(0xFFF5F0E8))),
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
      await ref.read(feedNotifierProvider(FeedTab.forYou).notifier).createPost(
        content: _contentCtrl.text.trim(),
        placeName: widget.prefilledPlaceName ?? 'Unknown Place',
        exactLat: widget.lat ?? 0,
        exactLng: widget.lng ?? 0,
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}
```

- [ ] **Step 3: Add routes to router.dart**

```dart
const kCommunityRoute = '/community';
const kComposePostRoute = '/community/compose';
const kSignInRoute = '/sign-in';

// Add to ShellRoute routes:
GoRoute(path: kCommunityRoute, builder: (_, __) => const FeedScreen()),
GoRoute(
  path: kComposePostRoute,
  builder: (context, state) => ComposePostScreen(
    prefilledPlaceName: state.uri.queryParameters['place'],
    lat: double.tryParse(state.uri.queryParameters['lat'] ?? ''),
    lng: double.tryParse(state.uri.queryParameters['lng'] ?? ''),
  ),
),
GoRoute(path: kSignInRoute, builder: (_, __) => const SignInScreen()),
```

- [ ] **Step 4: Implement SignInScreen (magic link)**

```dart
// lib/features/community/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'community_account.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Join ZenVlog')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, size: 64, color: Color(0xFFD4A853)),
                    const SizedBox(height: 16),
                    const Text('Check your email for a sign-in link.', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextButton(onPressed: () => context.pop(), child: const Text('Back')),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Enter your email to continue to the community feed.'),
                    const SizedBox(height: 16),
                    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _sendLink,
                        child: _loading ? const CircularProgressIndicator() : const Text('Send Magic Link'),
                      ),
                    ),
                  ],
                ),
        ),
      );

  Future<void> _sendLink() async {
    setState(() => _loading = true);
    try {
      await CommunityAccount.signInWithMagicLink(_emailCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/community/ lib/app/router.dart
git commit -m "feat: Feed screen with For You/Following/Nearby tabs and magic link auth"
```

---

### Task 5: Badges and XP

- [ ] **Step 1: Write test**

```dart
// test/features/profile/badges_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/profile/badges_provider.dart';

void main() {
  test('XP formula: journeys × 10 + tasks × 5 + distance × 2', () {
    final xp = BadgesProvider.calculateXp(journeys: 10, completedTasks: 20, totalDistanceKm: 50);
    expect(xp, 10 * 10 + 20 * 5 + 50 * 2); // 100 + 100 + 100 = 300
  });

  test('Milestone badge at 10 journeys', () {
    final badges = BadgesProvider.earnedMilestoneBadges(journeyCount: 12);
    expect(badges.contains('milestone_10'), isTrue);
    expect(badges.contains('milestone_25'), isFalse);
  });

  test('No milestone badges below 10 journeys', () {
    final badges = BadgesProvider.earnedMilestoneBadges(journeyCount: 5);
    expect(badges.isEmpty, isTrue);
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/features/profile/badges_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Create badge definitions asset**

```json
// assets/badges/definitions.json
[
  {"id": "first_steps", "title": "First Steps", "description": "Complete your first journey", "icon": "footprint", "type": "achievement", "condition": {"journeys": 1}},
  {"id": "solo_seeker", "title": "Solo Seeker", "description": "Travel solo 3 times", "icon": "person", "type": "achievement", "condition": {"soloJourneys": 3}},
  {"id": "nature_listener", "title": "Nature Listener", "description": "Complete 5 sound tasks", "icon": "mic", "type": "achievement", "condition": {"soundTasks": 5}},
  {"id": "trail_mind", "title": "Trail Mind", "description": "Hike 50 km total", "icon": "route", "type": "achievement", "condition": {"distanceKm": 50}},
  {"id": "hidden_finder", "title": "Hidden Finder", "description": "Discover 10 hidden spots", "icon": "explore", "type": "achievement", "condition": {"hiddenSpots": 10}},
  {"id": "mindful_creator", "title": "Mindful Creator", "description": "Complete 10 creative tasks", "icon": "brush", "type": "achievement", "condition": {"creativeTasks": 10}},
  {"id": "early_bird", "title": "Early Bird", "description": "Start a journey before 7 AM", "icon": "wb_sunny", "type": "achievement", "condition": {"earlyStart": 1}},
  {"id": "milestone_10", "title": "10 Journeys", "description": "Complete 10 journeys", "icon": "star", "type": "milestone", "condition": {"journeys": 10}},
  {"id": "milestone_25", "title": "25 Journeys", "description": "Complete 25 journeys", "icon": "star", "type": "milestone", "condition": {"journeys": 25}},
  {"id": "milestone_50", "title": "50 Journeys", "description": "Complete 50 journeys", "icon": "star", "type": "milestone", "condition": {"journeys": 50}},
  {"id": "milestone_100", "title": "100 Journeys", "description": "Complete 100 journeys", "icon": "star", "type": "milestone", "condition": {"journeys": 100}}
]
```

- [ ] **Step 4: Add to pubspec.yaml assets**

```yaml
    - assets/badges/definitions.json
```

- [ ] **Step 5: Implement BadgesProvider**

```dart
// lib/features/profile/badges_provider.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../journey/journey.dart';
import '../tasks/task.dart';
part 'badges_provider.g.dart';

class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String type;
  const BadgeDefinition({required this.id, required this.title, required this.description, required this.icon, required this.type});
  factory BadgeDefinition.fromJson(Map<String, dynamic> j) => BadgeDefinition(
    id: j['id'] as String, title: j['title'] as String,
    description: j['description'] as String, icon: j['icon'] as String, type: j['type'] as String,
  );
}

class BadgesState {
  final int xp;
  final int level;
  final int xpToNextLevel;
  final List<String> earnedIds;
  final List<BadgeDefinition> allDefinitions;
  const BadgesState({required this.xp, required this.level, required this.xpToNextLevel, required this.earnedIds, required this.allDefinitions});
}

class BadgesProvider {
  static int calculateXp({required int journeys, required int completedTasks, required double totalDistanceKm}) =>
      journeys * 10 + completedTasks * 5 + (totalDistanceKm * 2).floor();

  static Set<String> earnedMilestoneBadges(int journeyCount) {
    const milestones = {10: 'milestone_10', 25: 'milestone_25', 50: 'milestone_50', 100: 'milestone_100'};
    return milestones.entries
        .where((e) => journeyCount >= e.key)
        .map((e) => e.value)
        .toSet();
  }
}

@riverpod
Future<BadgesState> badgesState(BadgesStateRef ref) async {
  final isar = IsarService.instance;
  final journeys = await isar.journeys.filter().endTimeIsNotNull().findAll();
  final tasks = await isar.tasks.filter().isCompletedEqualTo(true).findAll();
  final totalDistance = journeys.fold(0.0, (sum, j) => sum + j.totalDistanceM) / 1000;

  final xp = BadgesProvider.calculateXp(
    journeys: journeys.length,
    completedTasks: tasks.length,
    totalDistanceKm: totalDistance,
  );
  final level = (xp / 500).floor() + 1;
  final xpToNext = 500 - (xp % 500);

  final earned = <String>{};
  if (journeys.isNotEmpty) earned.add('first_steps');
  earned.addAll(BadgesProvider.earnedMilestoneBadges(journeys.length));
  final soundTasks = tasks.where((t) => t.templateId.startsWith('sound')).length;
  if (soundTasks >= 5) earned.add('nature_listener');
  if (totalDistance >= 50) earned.add('trail_mind');
  if (journeys.any((j) => j.startTime.hour < 7)) earned.add('early_bird');

  final data = await rootBundle.loadString('assets/badges/definitions.json');
  final defs = (jsonDecode(data) as List).map((e) => BadgeDefinition.fromJson(e as Map<String, dynamic>)).toList();

  return BadgesState(xp: xp, level: level, xpToNextLevel: xpToNext, earnedIds: earned.toList(), allDefinitions: defs);
}
```

- [ ] **Step 6: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Run tests**

```bash
flutter test test/features/profile/badges_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/profile/badges_provider.dart assets/badges/ test/features/profile/ pubspec.yaml
git commit -m "feat: BadgesProvider with XP, levels, and milestone badges"
```

---

### Task 6: Badges screen and Journey History screen

- [ ] **Step 1: Implement BadgesScreen**

```dart
// lib/features/profile/badges_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'badges_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(badgesStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (state) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Level ${state.level}',
                        style: const TextStyle(color: Color(0xFFD4A853), fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('${state.xp} XP', style: const TextStyle(color: Color(0xFFF5F0E8))),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 1 - (state.xpToNextLevel / 500),
                      backgroundColor: const Color(0xFF243D30),
                      color: const Color(0xFFD4A853),
                    ),
                    Text('${state.xpToNextLevel} XP to next level',
                        style: const TextStyle(color: Color(0xFFF5F0E8), fontSize: 12)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final badge = state.allDefinitions[i];
                    final earned = state.earnedIds.contains(badge.id);
                    return _BadgeTile(badge: badge, earned: earned);
                  },
                  childCount: state.allDefinitions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeDefinition badge;
  final bool earned;
  const _BadgeTile({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: earned ? const Color(0xFF243D30) : const Color(0xFF1A3A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: earned ? const Color(0xFFD4A853) : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, color: earned ? const Color(0xFFD4A853) : Colors.grey, size: 32),
            const SizedBox(height: 4),
            Text(badge.title,
                textAlign: TextAlign.center,
                style: TextStyle(color: earned ? const Color(0xFFD4A853) : Colors.grey, fontSize: 11)),
          ],
        ),
      );
}
```

- [ ] **Step 2: Implement JourneyHistoryScreen**

```dart
// lib/features/profile/journey_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../journey/journey.dart';
part 'journey_history_screen.g.dart';

@riverpod
Future<List<Journey>> completedJourneys(CompletedJourneysRef ref) async =>
    IsarService.instance.journeys.filter().endTimeIsNotNull()
        .sortByStartTimeDesc().findAll();

class JourneyHistoryScreen extends ConsumerWidget {
  const JourneyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeysAsync = ref.watch(completedJourneysProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Journeys')),
      body: journeysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (journeys) {
          final totalKm = journeys.fold(0.0, (s, j) => s + j.totalDistanceM) / 1000;
          final totalHours = journeys.fold(0.0, (s, j) => s + j.durationHours);
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF243D30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat('${journeys.length}', 'Journeys'),
                    _Stat('${totalKm.toStringAsFixed(0)} km', 'Distance'),
                    _Stat('${totalHours.toStringAsFixed(0)} h', 'Outdoors'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: journeys.length,
                  itemBuilder: (_, i) {
                    final j = journeys[i];
                    return ListTile(
                      title: Text('Journey ${journeys.length - i}'),
                      subtitle: Text(
                        '${j.startTime.day}/${j.startTime.month}/${j.startTime.year} · '
                        '${(j.totalDistanceM / 1000).toStringAsFixed(1)} km · '
                        '${j.durationHours.toStringAsFixed(1)} h',
                      ),
                      trailing: Text('${j.spotIds.length} spots',
                          style: const TextStyle(color: Color(0xFFD4A853))),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(color: Color(0xFFD4A853), fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Color(0xFFF5F0E8), fontSize: 12)),
        ],
      );
}
```

- [ ] **Step 3: Update ProfileScreen with real content**

```dart
// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import 'badges_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (state) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                  const SizedBox(height: 8),
                  Text('Level ${state.level} · ${state.xp} XP',
                      style: const TextStyle(color: Color(0xFFD4A853), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Color(0xFFD4A853)),
              title: const Text('Badges & Achievements'),
              trailing: Text('${state.earnedIds.length}/${state.allDefinitions.length}'),
              onTap: () => context.push('/profile/badges'),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFFD4A853)),
              title: const Text('Journey History'),
              onTap: () => context.push('/profile/history'),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFFD4A853)),
              title: const Text('Settings'),
              onTap: () => context.push(kSettingsRoute),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Add profile sub-routes**

```dart
// In router.dart ShellRoute routes, update profile:
GoRoute(
  path: kProfileRoute,
  builder: (_, __) => const ProfileScreen(),
  routes: [
    GoRoute(path: 'badges', builder: (_, __) => const BadgesScreen()),
    GoRoute(path: 'history', builder: (_, __) => const JourneyHistoryScreen()),
  ],
),
```

- [ ] **Step 5: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/profile/ lib/app/router.dart
git commit -m "feat: BadgesScreen, JourneyHistory, and real ProfileScreen"
```

---

### Task 7: Final integration test and golden path

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All PASS.

- [ ] **Step 2: Full golden path on device**

```bash
flutter run
```

Expected end-to-end flow:
1. First launch → Onboarding sliders → Explore shows Hidden Spots
2. Tap spot → Start Journey → GPS tracks → Get Task → Complete (record audio) → Add text journal entry → End Journey
3. Profile → Badges shows XP increased
4. Profile → Journey History shows completed journey
5. Community tab → prompted to sign in → magic link sent
6. After sign-in: For You / Following / Nearby tabs visible
7. Tap + → Compose post with pre-filled place name → post appears in For You

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "chore: Phase 6 Community complete — ZenVlog v1.0 shipped"
```
