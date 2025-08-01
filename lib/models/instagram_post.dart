/// Model representing an Instagram post with all relevant data
/// This model handles data serialization/deserialization and provides
/// type safety for Instagram post operations
class InstagramPost {
  final String id;
  final String caption;
  final String mediaType;
  final String mediaUrl;
  final String permalink;
  final String thumbnailUrl;
  final DateTime timestamp;

  const InstagramPost({
    required this.id,
    required this.caption,
    required this.mediaType,
    required this.mediaUrl,
    required this.permalink,
    required this.thumbnailUrl,
    required this.timestamp,
  });

  /// Creates an InstagramPost from API JSON response
  factory InstagramPost.fromJson(Map<String, dynamic> json) {
    return InstagramPost(
      id: json['id'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'IMAGE',
      mediaUrl: json['media_url'] as String? ?? '',
      permalink: json['permalink'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      timestamp: _parseTimestamp(json['timestamp'] as String?),
    );
  }

  /// Converts InstagramPost to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'permalink': permalink,
      'thumbnail_url': thumbnailUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy of this post with updated fields
  InstagramPost copyWith({
    String? id,
    String? caption,
    String? mediaType,
    String? mediaUrl,
    String? permalink,
    String? thumbnailUrl,
    DateTime? timestamp,
  }) {
    return InstagramPost(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      permalink: permalink ?? this.permalink,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Checks if this post is a video
  bool get isVideo => mediaType.toUpperCase() == 'VIDEO';

  /// Checks if this post is an image
  bool get isImage => mediaType.toUpperCase() == 'IMAGE';

  /// Gets a formatted time string (e.g., "2h ago", "3d ago")
  String get formattedTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Gets a truncated version of the caption for display
  String getTruncatedCaption(int maxLength) {
    if (caption.length <= maxLength) return caption;
    return '${caption.substring(0, maxLength)}...';
  }

  /// Private helper to parse timestamp from API response
  static DateTime _parseTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return DateTime.now();
    }
    
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      // If parsing fails, return current time
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstagramPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InstagramPost(id: $id, caption: ${caption.substring(0, caption.length > 50 ? 50 : caption.length)}..., mediaType: $mediaType)';
  }
}