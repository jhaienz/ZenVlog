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
