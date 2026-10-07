// lib/models/check_in.dart
enum CheckInStatus { completed, skipped, partial }

class CheckIn {
  final String id;
  final String habitId;
  final String date; // Format: "YYYY-MM-DD"
  final CheckInStatus status;
  final int? value;
  final int? durationSeconds;
  final String? logText;
  final int? mood;
  final bool isSuspicious;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    this.value,
    this.durationSeconds,
    this.logText,
    this.mood,
    this.isSuspicious = false,
    required this.createdAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      date: json['date'] as String,
      status: CheckInStatus.values.firstWhere((e) => e.name == json['status']),
      value: json['value'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      logText: json['log_text'] as String?,
      mood: json['mood'] as int?,
      isSuspicious: json['is_suspicious'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'status': status.name,
      'value': value,
      'duration_seconds': durationSeconds,
      'log_text': logText,
      'mood': mood,
      'is_suspicious': isSuspicious,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
