import 'dart:math';
import 'package:flutter/foundation.dart';

class KindnessNote {
  final String id;
  final String content;
  final String authorTag; // 例如："一位曾经连断四天的慢行者"、"清晨 6 点的跑者"
  final String category;  // "缓解焦虑"、"动量重启"、"自我宽恕"、"静心专注"
  final String emoji;
  int likesCount;
  bool isLiked;
  final bool isCustom;
  final DateTime createdAt;

  KindnessNote({
    required this.id,
    required this.content,
    required this.authorTag,
    required this.category,
    required this.emoji,
    this.likesCount = 0,
    this.isLiked = false,
    this.isCustom = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'content': content,
    'authorTag': authorTag,
    'category': category,
    'emoji': emoji,
    'likesCount': likesCount,
    'isLiked': isLiked,
    'isCustom': isCustom,
    'createdAt': createdAt.toIso8601String(),
  };

  factory KindnessNote.fromMap(Map<String, dynamic> map) => KindnessNote(
    id: map['id'] as String,
    content: map['content'] as String,
    authorTag: map['authorTag'] as String,
    category: map['category'] as String,
    emoji: map['emoji'] as String? ?? '💌',
    likesCount: map['likesCount'] as int? ?? 0,
    isLiked: map['isLiked'] as bool? ?? false,
    isCustom: map['isCustom'] as bool? ?? false,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// 离线善意共鸣信箱与温情打气便签服务 (Kindness Mailbox & Peer Resonance)
/// 核心准则：普遍人性与自我关怀。打破自律中的孤独感与挫败感，通过温情文字重聚动量。
class KindnessMailboxService extends ChangeNotifier {
  KindnessMailboxService._() {
    _initDefaultNotes();
  }
  static final KindnessMailboxService instance = KindnessMailboxService._();

  final List<KindnessNote> _notes = [];
  KindnessNote? _currentDrawnNote;

  List<KindnessNote> get allNotes => List.unmodifiable(_notes);
  KindnessNote? get currentDrawnNote => _currentDrawnNote;

  int get totalNotesCount => _notes.length;
  int get userCustomNotesCount => _notes.where((n) => n.isCustom).length;
  int get totalLikedCount => _notes.where((n) => n.isLiked).length;

  void _initDefaultNotes() {
    _notes.addAll([
      KindnessNote(
        id: 'kn_1',
        content: '今天哪怕只喝了一杯温水，或者只读了一页书，也是向更好的自己迈出了温柔的一步。不要慌，慢慢来最快。',
        authorTag: '一位懂得自我宽恕的慢行者',
        category: '自我宽恕',
        emoji: '🌿',
        likesCount: 142,
      ),
      KindnessNote(
        id: 'kn_2',
        content: '我也曾中断过整整两周。但习惯不是一条只能笔直向前的线，它是一条允许有弯道与树荫的长河。深呼吸，今天我们重新启航。',
        authorTag: '坚持第 320 天的朋友',
        category: '动量重启',
        emoji: '🌊',
        likesCount: 289,
      ),
      KindnessNote(
        id: 'kn_3',
        content: '允许自己有低能量的一天。累了就好好睡觉、吃热乎的饭，休息也是自律极为重要的一部分，绝不是怠惰。',
        authorTag: '心理学静修同路人',
        category: '缓解焦虑',
        emoji: '🍵',
        likesCount: 376,
      ),
      KindnessNote(
        id: 'kn_4',
        content: '你正在做的事情非常了不起。在无人鼓掌的日常琐碎里，你所投入的每一分钟专注，都在悄悄重塑你的大脑神经元。',
        authorTag: '清晨自习室的伙伴',
        category: '静心专注',
        emoji: '✨',
        likesCount: 512,
      ),
      KindnessNote(
        id: 'kn_5',
        content: '完美主义是自律最大的杀手。60 分的行动永远胜过 100 分的空想。起步两分钟，你就已经战胜了 90% 的犹豫！',
        authorTag: '《原子习惯》践行者',
        category: '动量重启',
        emoji: '🚀',
        likesCount: 431,
      ),
      KindnessNote(
        id: 'kn_6',
        content: '如果今天心情阴天，那就给自己一个大大的拥抱。你已经很努力了，世界很吵，但你很值得被温柔对待。',
        authorTag: '深夜书桌旁的同行者',
        category: '自我宽恕',
        emoji: '🧸',
        likesCount: 605,
      ),
    ]);
  }

  /// 从信箱随机抽取一张温情打气便签
  KindnessNote drawRandomNote({String? filterCategory}) {
    List<KindnessNote> pool = _notes;
    if (filterCategory != null && filterCategory != '全部') {
      final filtered = _notes.where((n) => n.category == filterCategory).toList();
      if (filtered.isNotEmpty) pool = filtered;
    }

    final rand = Random();
    final picked = pool[rand.nextInt(pool.length)];
    _currentDrawnNote = picked;
    notifyListeners();
    return picked;
  }

  /// 为便签送上温暖拥抱（点赞与点亮）
  void toggleLikeNote(String noteId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final note = _notes[index];
      if (note.isLiked) {
        note.isLiked = false;
        note.likesCount = max(0, note.likesCount - 1);
      } else {
        note.isLiked = true;
        note.likesCount += 1;
      }
      if (_currentDrawnNote?.id == noteId) {
        _currentDrawnNote = note;
      }
      notifyListeners();
    }
  }

  /// 用户向善意信箱投递一张自己书写的鼓励便签
  KindnessNote writeNote({
    required String content,
    required String authorTag,
    required String category,
    String emoji = '💌',
  }) {
    final newNote = KindnessNote(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      content: content.trim(),
      authorTag: authorTag.trim().isEmpty ? '温暖的自律同路人' : authorTag.trim(),
      category: category,
      emoji: emoji,
      likesCount: 1,
      isLiked: true,
      isCustom: true,
    );
    _notes.insert(0, newNote);
    _currentDrawnNote = newNote;
    notifyListeners();
    return newNote;
  }
}
