import 'dart:convert';
import '../database/sqlite_service.dart';
import '../../models/habit.dart';
import '../../models/check_in.dart';

/// 本地优先数据备份与导出服务 (Local-First Backup & Export Service)
/// 灵感来源：开源项目 FriesI23/mhabit 与 Loop Habit Tracker
/// 支持标准 JSON 全量备份与 CSV 电子表格分析导出
class BackupService {
  /// 生成全量 JSON 备份文本
  static String exportToJson({
    required List<Habit> habits,
    required List<CheckIn> checkIns,
  }) {
    final Map<String, dynamic> backupData = {
      'app': 'GoTime',
      'version': '1.2.0',
      'exported_at': DateTime.now().toIso8601String(),
      'habits_count': habits.length,
      'check_ins_count': checkIns.length,
      'habits': habits.map((h) => h.toJson()).toList(),
      'check_ins': checkIns.map((c) => c.toJson()).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(backupData);
  }

  /// 导出为符合 RFC 4180 标准的 CSV 电子表格文本（方便 Excel / Notion 分析）
  static String exportToCsv({
    required List<Habit> habits,
    required List<CheckIn> checkIns,
  }) {
    final habitMap = {for (var h in habits) h.id: h};
    final StringBuffer csv = StringBuffer();

    // CSV 表头
    csv.writeln('日期,习惯名称,图标,习惯类型,打卡状态,完成数值,单位,专注时长(秒),心情Emoji,日志感悟,记录时间');

    final moodEmojis = ['', '😫', '😕', '😐', '😊', '🤩'];

    for (final checkIn in checkIns) {
      final habit = habitMap[checkIn.habitId];
      final habitName = habit?.name ?? '已归档习惯';
      final emoji = habit?.iconEmoji ?? '📝';
      final type = habit?.type.name ?? 'unknown';
      final status = checkIn.status.name;
      final val = checkIn.value?.toString() ?? '';
      final unit = habit?.targetUnit ?? '';
      final duration = checkIn.durationSeconds?.toString() ?? '';
      final moodStr = (checkIn.mood != null && checkIn.mood! >= 1 && checkIn.mood! <= 5)
          ? moodEmojis[checkIn.mood!]
          : '';
      // 处理日志中的逗号与换行，按 CSV 规范加引号包围
      final logSafe = checkIn.logText != null
          ? '"${checkIn.logText!.replaceAll('"', '""')}"'
          : '';
      final createdAt = checkIn.createdAt.toIso8601String();

      csv.writeln(
        '${checkIn.date},"$habitName",$emoji,$type,$status,$val,$unit,$duration,$moodStr,$logSafe,$createdAt',
      );
    }

    return csv.toString();
  }

  /// 校验并解析 JSON 备份文件内容
  static Map<String, dynamic>? validateAndParseJson(String jsonString) {
    try {
      final dynamic parsed = jsonDecode(jsonString);
      if (parsed is! Map<String, dynamic>) return null;
      if (parsed['app'] != 'GoTime' && parsed['habits'] == null) return null;

      final habitsJson = parsed['habits'] as List<dynamic>? ?? [];
      final checkInsJson = parsed['check_ins'] as List<dynamic>? ?? [];

      final habits = habitsJson.map((e) => Habit.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      final checkIns = checkInsJson.map((e) => CheckIn.fromJson(Map<String, dynamic>.from(e as Map))).toList();

      return {
        'habits': habits,
        'check_ins': checkIns,
        'exported_at': parsed['exported_at'],
      };
    } catch (_) {
      return null;
    }
  }

  /// 从数据库提取并生成全量 JSON 备份文本
  static Future<String> exportToJsonString() async {
    final habits = await SQLiteService.instance.getAllActiveHabits();
    final archived = await SQLiteService.instance.getArchivedHabits();
    final allHabits = [...habits, ...archived];
    final checkIns = await SQLiteService.instance.getCheckInsForYear(DateTime.now().year);
    return exportToJson(habits: allHabits, checkIns: checkIns);
  }

  /// 导入并恢复 JSON 数据入库
  static Future<bool> importFromJsonString(String jsonString) async {
    final parsed = validateAndParseJson(jsonString);
    if (parsed == null) return false;
    final habits = parsed['habits'] as List<Habit>;
    final checkIns = parsed['check_ins'] as List<CheckIn>;
    for (final habit in habits) {
      await SQLiteService.instance.insertHabit(habit);
    }
    for (final checkIn in checkIns) {
      await SQLiteService.instance.insertCheckIn(checkIn);
    }
    return true;
  }
}
