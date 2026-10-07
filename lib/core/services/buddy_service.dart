import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/check_in.dart';

/// 搭子互动动作类型
enum BuddyInteractionType {
  poke(
    title: '隔空戳一戳',
    iconEmoji: '⚡',
    defaultMsg: '轻轻戳了你一下，该喝水运动打卡啦！',
  ),
  highFive(
    title: '击掌鼓劲',
    iconEmoji: '🙌',
    defaultMsg: '太棒了！今天也一起达成了全勤自律！',
  ),
  freezePass(
    title: '赠送请假卡',
    iconEmoji: '❄️',
    defaultMsg: '今天累了就好好休息，我帮你守护连胜！',
  ),
  cheer(
    title: '加油应援',
    iconEmoji: '🌟',
    defaultMsg: '坚持就是胜利，你比想象中更强大！',
  );

  final String title;
  final String iconEmoji;
  final String defaultMsg;

  const BuddyInteractionType({
    required this.title,
    required this.iconEmoji,
    required this.defaultMsg,
  });
}

/// 互动记录
class BuddyInteraction {
  final String id;
  final BuddyInteractionType type;
  final String message;
  final DateTime timestamp;
  final bool fromMe;

  BuddyInteraction({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.fromMe,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'fromMe': fromMe,
  };
}

/// 习惯搭子档案模型
class BuddyProfile {
  final String id;
  final String name;
  final String avatarEmoji;
  final String slogan;
  final String pairCode;
  final int weeklyDays;
  final int streakDays;
  final bool isPaired;
  final List<BuddyInteraction> interactions;

  BuddyProfile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.slogan,
    required this.pairCode,
    required this.weeklyDays,
    required this.streakDays,
    required this.isPaired,
    required this.interactions,
  });

  BuddyProfile copyWith({
    String? name,
    String? avatarEmoji,
    String? slogan,
    String? pairCode,
    int? weeklyDays,
    int? streakDays,
    bool? isPaired,
    List<BuddyInteraction>? interactions,
  }) {
    return BuddyProfile(
      id: id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      slogan: slogan ?? this.slogan,
      pairCode: pairCode ?? this.pairCode,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      streakDays: streakDays ?? this.streakDays,
      isPaired: isPaired ?? this.isPaired,
      interactions: interactions ?? this.interactions,
    );
  }
}

/// 习惯搭子双人结对与隔空互勉服务
class BuddyService extends ChangeNotifier {
  BuddyService._() {
    _initDefaultBuddy();
  }
  static final BuddyService instance = BuddyService._();

  final String myPairCode = 'GT-MINT-${1000 + Random().nextInt(9000)}';
  BuddyProfile? _buddy;

  BuddyProfile? get buddy => _buddy;
  bool get hasBuddy => _buddy != null && _buddy!.isPaired;

  void _initDefaultBuddy() {
    _buddy = BuddyProfile(
      id: 'buddy_alex',
      name: 'Alex (晨跑搭子)',
      avatarEmoji: '🏃‍♂️',
      slogan: '慢即是快，每天进步 1%',
      pairCode: 'GT-ALEX-8848',
      weeklyDays: 3,
      streakDays: 14,
      isPaired: true,
      interactions: [
        BuddyInteraction(
          id: 'int_1',
          type: BuddyInteractionType.highFive,
          message: '昨天晨跑 5km 达成！你今天怎么样？',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          fromMe: false,
        ),
      ],
    );
  }

  /// 使用口令结对绑定
  bool pairWithCode(String code, {String? nickname}) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    _buddy = BuddyProfile(
      id: 'buddy_${DateTime.now().millisecondsSinceEpoch}',
      name: nickname ?? '自律合伙人',
      avatarEmoji: '🌱',
      slogan: '与优秀的人同行，让好习惯生根发芽',
      pairCode: cleanCode,
      weeklyDays: 2,
      streakDays: 7,
      isPaired: true,
      interactions: [
        BuddyInteraction(
          id: 'int_new',
          type: BuddyInteractionType.cheer,
          message: '成功与你建立习惯结对！接下来的日子一起加油！',
          timestamp: DateTime.now(),
          fromMe: false,
        ),
      ],
    );
    notifyListeners();
    return true;
  }

  /// 解除结对
  void unpair() {
    _buddy = null;
    notifyListeners();
  }

  /// 发送互动消息 (戳一戳/击掌/免责卡/鼓励)
  void sendInteraction(BuddyInteractionType type, {String? customMessage}) {
    if (_buddy == null) return;

    final interaction = BuddyInteraction(
      id: 'int_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      message: customMessage ?? type.defaultMsg,
      timestamp: DateTime.now(),
      fromMe: true,
    );

    final updatedList = List<BuddyInteraction>.from(_buddy!.interactions)
      ..insert(0, interaction);

    _buddy = _buddy!.copyWith(interactions: updatedList);
    notifyListeners();
  }

  /// 计算当前用户本周（周一至周日）打卡天数
  int calculateMyWeeklyDays(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) return 0;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

    final thisWeekDays = checkIns
        .where((c) => c.date.compareTo(mondayStr) >= 0 && c.status == CheckInStatus.completed)
        .map((c) => c.date)
        .toSet();

    return thisWeekDays.length;
  }
}
