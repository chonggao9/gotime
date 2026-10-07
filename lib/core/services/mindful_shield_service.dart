import 'package:flutter/foundation.dart';

class UrgeLog {
  final String id;
  final String trigger;
  final DateTime timestamp;
  final int calmSeconds;

  const UrgeLog({
    required this.id,
    required this.trigger,
    required this.timestamp,
    required this.calmSeconds,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'trigger': trigger,
    'timestamp': timestamp.toIso8601String(),
    'calmSeconds': calmSeconds,
  };

  factory UrgeLog.fromMap(Map<String, dynamic> map) => UrgeLog(
    id: map['id'] as String,
    trigger: map['trigger'] as String,
    timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    calmSeconds: map['calmSeconds'] as int? ?? 15,
  );
}

/// 正念自律屏障与数字极简防沉迷盾牌服务 (Mindful Shield & Anti-Distraction Service)
/// 核心准则：在冲动与反应之间插入正念缓冲，化被动诱惑为主观战胜。
class MindfulShieldService extends ChangeNotifier {
  MindfulShieldService._();
  static final MindfulShieldService instance = MindfulShieldService._();

  bool _isShieldActive = false;
  int _todayOvercomeCount = 0;
  int _calmDownSeconds = 15; // 默认 15 秒理性冷静呼吸期
  final List<UrgeLog> _urgeLogs = [];

  bool get isShieldActive => _isShieldActive;
  int get todayOvercomeCount => _todayOvercomeCount;
  int get calmDownSeconds => _calmDownSeconds;
  List<UrgeLog> get urgeLogs => List.unmodifiable(_urgeLogs);

  static const List<String> commonUrgeTriggers = [
    '无聊/习惯性摸手机',
    '遇到困难想逃避',
    '渴望即时多巴胺',
    '焦虑想刷短视频',
    '无意识检查通知',
    '疲惫想切换任务',
  ];

  void toggleShield() {
    _isShieldActive = !_isShieldActive;
    notifyListeners();
  }

  void setShieldActive(bool active) {
    _isShieldActive = active;
    notifyListeners();
  }

  void setCalmDownSeconds(int seconds) {
    _calmDownSeconds = seconds.clamp(10, 60);
    notifyListeners();
  }

  /// 战胜分心冲动并记录
  void recordUrgeOvercome({String trigger = '无意识抓取手机', int calmSeconds = 15}) {
    _todayOvercomeCount++;
    _urgeLogs.insert(
      0,
      UrgeLog(
        id: 'urge_${DateTime.now().millisecondsSinceEpoch}',
        trigger: trigger,
        timestamp: DateTime.now(),
        calmSeconds: calmSeconds,
      ),
    );
    notifyListeners();
  }

  /// 重置今日计数
  void resetToday() {
    _todayOvercomeCount = 0;
    _urgeLogs.clear();
    notifyListeners();
  }
}
