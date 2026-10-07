// lib/models/user.dart
class GoTimeUser {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int momentumScore;
  final String? anchorTimezone;
  final DateTime createdAt;

  GoTimeUser({
    required this.uid,
    this.displayName = 'GoTime 用户',
    this.avatarUrl,
    this.momentumScore = 100,
    this.anchorTimezone,
    required this.createdAt,
  });

  factory GoTimeUser.fromJson(Map<String, dynamic> json) {
    return GoTimeUser(
      uid: json['uid'] as String,
      displayName: json['display_name'] as String? ?? 'GoTime 用户',
      avatarUrl: json['avatar_url'] as String?,
      momentumScore: json['momentum_score'] as int? ?? 100,
      anchorTimezone: json['anchor_timezone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'momentum_score': momentumScore,
      'anchor_timezone': anchorTimezone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
