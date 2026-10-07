import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/webdav_service.dart';
import '../../../core/services/theme_service.dart';

class WebDavDialog extends StatefulWidget {
  final VoidCallback onRestored;

  const WebDavDialog({super.key, required this.onRestored});

  static void show(BuildContext context, {required VoidCallback onRestored}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WebDavDialog(onRestored: onRestored),
    );
  }

  @override
  State<WebDavDialog> createState() => _WebDavDialogState();
}

class _WebDavDialogState extends State<WebDavDialog> {
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pathController = TextEditingController(text: '/gotime_backup.json');

  bool _isTesting = false;
  bool _isSyncing = false;
  String? _statusMessage;
  bool? _isStatusSuccess;

  @override
  void initState() {
    super.initState();
    final config = WebDavService.instance.config;
    if (config != null) {
      _serverController.text = config.serverUrl;
      _usernameController.text = config.username;
      _passwordController.text = config.password;
      _pathController.text = config.remotePath;
    }
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  WebDavConfig _buildConfig() {
    return WebDavConfig(
      serverUrl: _serverController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      remotePath: _pathController.text.trim().isEmpty ? '/gotime_backup.json' : _pathController.text.trim(),
    );
  }

  Future<void> _testConnection() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isTesting = true;
      _statusMessage = null;
    });

    final config = _buildConfig();
    final result = await WebDavService.instance.testConnection(config);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _statusMessage = result.message;
        _isStatusSuccess = result.success;
      });
      if (result.success) {
        WebDavService.instance.saveConfig(config);
      }
    }
  }

  Future<void> _uploadBackup() async {
    HapticFeedback.mediumImpact();
    final config = _buildConfig();
    WebDavService.instance.saveConfig(config);

    setState(() {
      _isSyncing = true;
      _statusMessage = null;
    });

    final result = await WebDavService.instance.uploadBackup();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _statusMessage = result.message;
        _isStatusSuccess = result.success;
      });
    }
  }

  Future<void> _downloadAndRestore() async {
    HapticFeedback.heavyImpact();
    final config = _buildConfig();
    WebDavService.instance.saveConfig(config);

    setState(() {
      _isSyncing = true;
      _statusMessage = null;
    });

    final result = await WebDavService.instance.downloadAndRestore();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _statusMessage = result.message;
        _isStatusSuccess = result.success;
      });

      if (result.success) {
        widget.onRestored();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.instance.brandColor.primary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽手柄
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WebDAV 私有云同步',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '支持坚果云、Nextcloud、群晖等私有网盘',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 坚果云快捷填入预设胶囊
            Row(
              children: [
                ActionChip(
                  label: const Text('坚果云预设', style: TextStyle(fontSize: 12)),
                  avatar: const Text('🥜', style: TextStyle(fontSize: 13)),
                  backgroundColor: isDark ? const Color(0xFF1E2923) : Colors.grey[200],
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _serverController.text = 'https://dav.jianguoyun.com/dav/';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Nextcloud', style: TextStyle(fontSize: 12)),
                  avatar: const Text('☁️', style: TextStyle(fontSize: 13)),
                  backgroundColor: isDark ? const Color(0xFF1E2923) : Colors.grey[200],
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _serverController.text = 'https://your-nextcloud.com/remote.php/dav/files/USER/';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 表单输入
            _buildInputField('服务器地址 (Server URL)', _serverController, 'https://dav.jianguoyun.com/dav/', isDark),
            const SizedBox(height: 12),
            _buildInputField('用户名 / 账号 (Username)', _usernameController, 'example@mail.com', isDark),
            const SizedBox(height: 12),
            _buildInputField('应用授权密码 (Password)', _passwordController, '填入网盘生成的第三方应用密码', isDark, isPassword: true),
            const SizedBox(height: 12),
            _buildInputField('远端文件路径 (Remote Path)', _pathController, '/gotime_backup.json', isDark),
            const SizedBox(height: 16),

            // 测试与状态反馈
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isStatusSuccess == true ? Colors.green : Colors.redAccent).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (_isStatusSuccess == true ? Colors.green : Colors.redAccent).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isStatusSuccess == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: _isStatusSuccess == true ? Colors.green : Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          color: _isStatusSuccess == true ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 操作按钮组
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isTesting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSyncing ? null : _uploadBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSyncing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('立即备份到云端', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 从云端恢复按钮
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isSyncing ? null : _downloadAndRestore,
                icon: const Icon(Icons.cloud_download_rounded, size: 18),
                label: const Text('从 WebDAV 云端拉取并恢复本地数据'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2923) : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
