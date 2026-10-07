import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'backup_service.dart';

class WebDavConfig {
  final String serverUrl; // e.g. https://dav.jianguoyun.com/dav/
  final String username;
  final String password;
  final String remotePath; // e.g. /gotime/gotime_backup.json

  const WebDavConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.remotePath = '/gotime_backup.json',
  });

  Map<String, dynamic> toJson() => {
        'server_url': serverUrl,
        'username': username,
        'password': password,
        'remote_path': remotePath,
      };

  factory WebDavConfig.fromJson(Map<String, dynamic> json) => WebDavConfig(
        serverUrl: json['server_url'] as String? ?? '',
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
        remotePath: json['remote_path'] as String? ?? '/gotime_backup.json',
      );
}

class WebDavSyncResult {
  final bool success;
  final String message;
  final DateTime timestamp;

  const WebDavSyncResult({
    required this.success,
    required this.message,
    required this.timestamp,
  });
}

/// 纯 Dart 轻量 WebDAV 同步服务 (支持坚果云、Nextcloud、群晖等私有云)
class WebDavService {
  WebDavService._();
  static final WebDavService instance = WebDavService._();

  WebDavConfig? _config;
  DateTime? _lastSyncTime;

  WebDavConfig? get config => _config;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isConfigured => _config != null && _config!.serverUrl.isNotEmpty;

  void saveConfig(WebDavConfig config) {
    _config = config;
  }

  String _getAuthHeader(String user, String pass) {
    final credentials = '$user:$pass';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  String _getFullUrl(String serverUrl, String path) {
    var base = serverUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    var cleanPath = path.trim();
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    return '$base$cleanPath';
  }

  /// 测试 WebDAV 服务器连接凭据有效性
  Future<WebDavSyncResult> testConnection(WebDavConfig config) async {
    try {
      final url = Uri.parse(_getFullUrl(config.serverUrl, ''));
      final auth = _getAuthHeader(config.username, config.password);

      // 发起 PROPFIND 或 HEAD 请求验证凭证
      final request = http.Request('PROPFIND', url);
      request.headers['Authorization'] = auth;
      request.headers['Depth'] = '0';

      final client = http.Client();
      try {
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 10));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300 || response.statusCode == 207) {
          return WebDavSyncResult(
            success: true,
            message: 'WebDAV 网盘连接成功！',
            timestamp: DateTime.now(),
          );
        } else if (response.statusCode == 401) {
          return WebDavSyncResult(
            success: false,
            message: '认证失败：用户名或应用密码错误 (HTTP 401)',
            timestamp: DateTime.now(),
          );
        } else {
          return WebDavSyncResult(
            success: false,
            message: '服务器响应异常 (HTTP ${response.statusCode})',
            timestamp: DateTime.now(),
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      return WebDavSyncResult(
        success: false,
        message: '连接超时或网络异常: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// 上传全量备份到 WebDAV
  Future<WebDavSyncResult> uploadBackup() async {
    if (_config == null || _config!.serverUrl.isEmpty) {
      return WebDavSyncResult(
        success: false,
        message: '尚未配置 WebDAV 网盘信息',
        timestamp: DateTime.now(),
      );
    }

    try {
      // 1. 生成全量备份 JSON 字符串
      final jsonString = await BackupService.exportToJsonString();
      final url = Uri.parse(_getFullUrl(_config!.serverUrl, _config!.remotePath));
      final auth = _getAuthHeader(_config!.username, _config!.password);

      // 2. 发起 HTTP PUT 请求写入文件
      final response = await http.put(
        url,
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: utf8.encode(jsonString),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300 || response.statusCode == 201 || response.statusCode == 204) {
        _lastSyncTime = DateTime.now();
        return WebDavSyncResult(
          success: true,
          message: '已成功备份到 WebDAV 私有网盘！',
          timestamp: _lastSyncTime!,
        );
      } else {
        return WebDavSyncResult(
          success: false,
          message: '备份上传失败 (HTTP ${response.statusCode})',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      return WebDavSyncResult(
        success: false,
        message: '同步出错: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// 从 WebDAV 拉取远端备份并恢复
  Future<WebDavSyncResult> downloadAndRestore() async {
    if (_config == null || _config!.serverUrl.isEmpty) {
      return WebDavSyncResult(
        success: false,
        message: '尚未配置 WebDAV 网盘信息',
        timestamp: DateTime.now(),
      );
    }

    try {
      final url = Uri.parse(_getFullUrl(_config!.serverUrl, _config!.remotePath));
      final auth = _getAuthHeader(_config!.username, _config!.password);

      final response = await http.get(
        url,
        headers: {'Authorization': auth},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final content = utf8.decode(response.bodyBytes);
        final success = await BackupService.importFromJsonString(content);
        if (success) {
          _lastSyncTime = DateTime.now();
          return WebDavSyncResult(
            success: true,
            message: '已从 WebDAV 恢复全部习惯与打卡数据！',
            timestamp: _lastSyncTime!,
          );
        } else {
          return WebDavSyncResult(
            success: false,
            message: '远端文件不是合法的 GoTime 备份数据',
            timestamp: DateTime.now(),
          );
        }
      } else if (response.statusCode == 404) {
        return WebDavSyncResult(
          success: false,
          message: '远端网盘未找到备份文件「${_config!.remotePath}」',
          timestamp: DateTime.now(),
        );
      } else {
        return WebDavSyncResult(
          success: false,
          message: '下载备份失败 (HTTP ${response.statusCode})',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      return WebDavSyncResult(
        success: false,
        message: '同步出错: $e',
        timestamp: DateTime.now(),
      );
    }
  }
}
