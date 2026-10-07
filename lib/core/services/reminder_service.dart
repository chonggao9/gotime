import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 智能提醒与免打扰调度服务
class ReminderService extends ChangeNotifier {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _afternoonTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);

  bool _isMorningEnabled = true;
  bool _isAfternoonEnabled = true;
  bool _isEveningEnabled = true;

  bool _isQuietHoursEnabled = true;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  TimeOfDay get morningTime => _morningTime;
  TimeOfDay get afternoonTime => _afternoonTime;
  TimeOfDay get eveningTime => _eveningTime;

  bool get isMorningEnabled => _isMorningEnabled;
  bool get isAfternoonEnabled => _isAfternoonEnabled;
  bool get isEveningEnabled => _isEveningEnabled;

  bool get isQuietHoursEnabled => _isQuietHoursEnabled;
  TimeOfDay get quietStart => _quietStart;
  TimeOfDay get quietEnd => _quietEnd;

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void updateSlot({
    TimeOfDay? morning,
    TimeOfDay? afternoon,
    TimeOfDay? evening,
    bool? morningEnabled,
    bool? afternoonEnabled,
    bool? eveningEnabled,
  }) {
    if (morning != null) _morningTime = morning;
    if (afternoon != null) _afternoonTime = afternoon;
    if (evening != null) _eveningTime = evening;
    if (morningEnabled != null) _isMorningEnabled = morningEnabled;
    if (afternoonEnabled != null) _isAfternoonEnabled = afternoonEnabled;
    if (eveningEnabled != null) _isEveningEnabled = eveningEnabled;
    notifyListeners();
  }

  void updateQuietHours({
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) {
    if (enabled != null) _isQuietHoursEnabled = enabled;
    if (start != null) _quietStart = start;
    if (end != null) _quietEnd = end;
    notifyListeners();
  }

  /// 检查当前时间是否位于静音免打扰时段内
  bool isInQuietHours(DateTime now) {
    if (!_isQuietHoursEnabled) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = _quietStart.hour * 60 + _quietStart.minute;
    final endMinutes = _quietEnd.hour * 60 + _quietEnd.minute;

    if (startMinutes > endMinutes) {
      // 跨过午夜 (例如 22:30 ~ 07:00)
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  /// 模拟触发一次自律提醒
  String getNextScheduledSummary() {
    final activeSlots = <String>[];
    if (_isMorningEnabled) activeSlots.add('晨间 ${formatTime(_morningTime)}');
    if (_isAfternoonEnabled) activeSlots.add('午间 ${formatTime(_afternoonTime)}');
    if (_isEveningEnabled) activeSlots.add('晚间 ${formatTime(_eveningTime)}');

    if (activeSlots.isEmpty) return '已关闭全天提醒';
    return activeSlots.join(' · ');
  }
}
