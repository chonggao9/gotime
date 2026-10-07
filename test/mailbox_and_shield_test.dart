import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/kindness_mailbox_service.dart';
import 'package:gotime/core/services/mindful_shield_service.dart';

void main() {
  group('KindnessMailboxService Tests (Peer Resonance & Offline Notes)', () {
    final mailbox = KindnessMailboxService.instance;

    test('initializes with thoughtful default notes', () {
      expect(mailbox.allNotes.length, greaterThanOrEqualTo(6));
      expect(mailbox.totalNotesCount, greaterThanOrEqualTo(6));
    });

    test('drawRandomNote picks a note and supports category filtering', () {
      final noteAny = mailbox.drawRandomNote();
      expect(noteAny.content, isNotEmpty);
      expect(mailbox.currentDrawnNote, equals(noteAny));

      final noteAnxiety = mailbox.drawRandomNote(filterCategory: '缓解焦虑');
      expect(noteAnxiety.category, '缓解焦虑');
      expect(noteAnxiety.authorTag, isNotEmpty);
    });

    test('toggleLikeNote toggles note like state and updates count', () {
      final note = mailbox.allNotes.first;
      final initialLikes = note.likesCount;
      final initialLiked = note.isLiked;

      mailbox.toggleLikeNote(note.id);
      expect(note.isLiked, !initialLiked);
      expect(note.likesCount, initialLiked ? initialLikes - 1 : initialLikes + 1);

      // 再次切换还原
      mailbox.toggleLikeNote(note.id);
      expect(note.isLiked, initialLiked);
      expect(note.likesCount, initialLikes);
    });

    test('writeNote inserts custom note at beginning with full metadata', () {
      final custom = mailbox.writeNote(
        content: '今天你已经非常勇敢了，慢一点也完全没关系！',
        authorTag: '清晨的向日葵',
        category: '自我宽恕',
        emoji: '🌻',
      );

      expect(custom.isCustom, isTrue);
      expect(custom.isLiked, isTrue);
      expect(custom.likesCount, 1);
      expect(custom.authorTag, '清晨的向日葵');
      expect(custom.category, '自我宽恕');
      expect(mailbox.allNotes.first.id, custom.id);
      expect(mailbox.currentDrawnNote?.id, custom.id);
      expect(mailbox.userCustomNotesCount, greaterThanOrEqualTo(1));
    });
  });

  group('MindfulShieldService Tests (Digital Detox & Mindful Interruption)', () {
    final shield = MindfulShieldService.instance;

    setUp(() {
      shield.resetToday();
    });

    test('toggleShield and setShieldActive control state', () {
      shield.setShieldActive(false);
      expect(shield.isShieldActive, isFalse);

      shield.toggleShield();
      expect(shield.isShieldActive, isTrue);

      shield.setShieldActive(false);
      expect(shield.isShieldActive, isFalse);
    });

    test('setCalmDownSeconds clamps safely between 10 and 60 seconds', () {
      shield.setCalmDownSeconds(20);
      expect(shield.calmDownSeconds, 20);

      shield.setCalmDownSeconds(5);
      expect(shield.calmDownSeconds, 10);

      shield.setCalmDownSeconds(120);
      expect(shield.calmDownSeconds, 60);
    });

    test('recordUrgeOvercome logs urge event and increments counter', () {
      expect(shield.todayOvercomeCount, 0);
      expect(shield.urgeLogs, isEmpty);

      shield.recordUrgeOvercome(
        trigger: '渴望即时多巴胺',
        calmSeconds: 15,
      );

      expect(shield.todayOvercomeCount, 1);
      expect(shield.urgeLogs.length, 1);
      expect(shield.urgeLogs.first.trigger, '渴望即时多巴胺');
      expect(shield.urgeLogs.first.calmSeconds, 15);

      // 再次战胜
      shield.recordUrgeOvercome(
        trigger: '遇到困难想逃避',
        calmSeconds: 30,
      );
      expect(shield.todayOvercomeCount, 2);
      expect(shield.urgeLogs.length, 2);
      expect(shield.urgeLogs.first.trigger, '遇到困难想逃避');
    });

    test('resetToday clears records cleanly', () {
      shield.recordUrgeOvercome();
      expect(shield.todayOvercomeCount, 1);

      shield.resetToday();
      expect(shield.todayOvercomeCount, 0);
      expect(shield.urgeLogs, isEmpty);
    });
  });
}
