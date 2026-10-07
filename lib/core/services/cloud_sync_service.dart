import 'package:flutter/foundation.dart';

enum CloudSyncStatus { idle, syncing, success, error }

class SyncDevice {
  final String id;
  final String name;
  final String typeEmoji;
  final String platform;
  final DateTime lastSeen;

  SyncDevice({
    required this.id,
    required this.name,
    required this.typeEmoji,
    required this.platform,
    required this.lastSeen,
  });
}

/// 云端多端同步服务
class CloudSyncService extends ChangeNotifier {
  CloudSyncService._() {
    _initDefaultState();
  }
  static final CloudSyncService instance = CloudSyncService._();

  bool _isEnabled = false;
  bool _isAccountLinked = false;
  String? _accountEmail;
  CloudSyncStatus _status = CloudSyncStatus.idle;
  DateTime? _lastSyncedAt;
  bool _autoSyncOnWifi = true;

  final List<SyncDevice> _devices = [];

  bool get isEnabled => _isEnabled;
  bool get isAccountLinked => _isAccountLinked;
  String? get accountEmail => _accountEmail;
  CloudSyncStatus get status => _status;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get autoSyncOnWifi => _autoSyncOnWifi;
  List<SyncDevice> get devices => List.unmodifiable(_devices);

  void _initDefaultState() {
    _devices.addAll([
      SyncDevice(
        id: 'dev_1',
        name: '当前设备 (Web 客户端)',
        typeEmoji: '🌐',
        platform: 'Flutter Web',
        lastSeen: DateTime.now(),
      ),
      SyncDevice(
        id: 'dev_2',
        name: 'iPhone 16 Pro',
        typeEmoji: '📱',
        platform: 'iOS 18',
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SyncDevice(
        id: 'dev_3',
        name: 'Apple Watch Series 10',
        typeEmoji: '⌚',
        platform: 'watchOS 11',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ]);
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (_isEnabled && !_isAccountLinked) {
      _accountEmail = 'gotime.user@gmail.com';
      _isAccountLinked = true;
    }
    notifyListeners();
  }

  void linkAccount(String email) {
    final clean = email.trim();
    if (clean.isEmpty) return;
    _accountEmail = clean;
    _isAccountLinked = true;
    _isEnabled = true;
    notifyListeners();
  }

  void unlinkAccount() {
    _accountEmail = null;
    _isAccountLinked = false;
    _isEnabled = false;
    notifyListeners();
  }

  void setAutoSyncOnWifi(bool value) {
    _autoSyncOnWifi = value;
    notifyListeners();
  }

  /// 触发增量合并同步
  Future<bool> performCloudSync() async {
    if (!_isEnabled) return false;

    _status = CloudSyncStatus.syncing;
    notifyListeners();

    try {
      // 模拟多端双向哈希校验与版本合并
      await Future.delayed(const Duration(milliseconds: 600));

      _lastSyncedAt = DateTime.now();
      _status = CloudSyncStatus.success;
      notifyListeners();

      // 3 秒后重置状态为 idle
      Future.delayed(const Duration(seconds: 3), () {
        if (_status == CloudSyncStatus.success) {
          _status = CloudSyncStatus.idle;
          notifyListeners();
        }
      });
      return true;
    } catch (_) {
      _status = CloudSyncStatus.error;
      notifyListeners();
      return false;
    }
  }

  String getLastSyncSummary() {
    if (!_isEnabled) return '云端多端同步已关闭';
    if (_lastSyncedAt == null) return '尚未进行初次同步 · 账号已就绪';

    final diff = DateTime.now().difference(_lastSyncedAt!);
    if (diff.inMinutes < 1) return '刚刚已同步完成';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前同步';
    return '${diff.inHours} 小时前同步';
  }
}
