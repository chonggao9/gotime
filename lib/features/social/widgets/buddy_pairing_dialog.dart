import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/buddy_service.dart';
import '../../../core/theme/app_theme.dart';

class BuddyPairingDialog extends StatefulWidget {
  const BuddyPairingDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BuddyPairingDialog(),
    );
  }

  @override
  State<BuddyPairingDialog> createState() => _BuddyPairingDialogState();
}

class _BuddyPairingDialogState extends State<BuddyPairingDialog> {
  final _buddyService = BuddyService.instance;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isEnteringCode = false;

  @override
  void initState() {
    super.initState();
    _buddyService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _buddyService.removeListener(_onServiceUpdate);
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buddy = _buddyService.buddy;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部手柄
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

          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🤝 习惯搭子结对互勉',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Text(
                          '轻社交 · 零焦虑',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '找一位同频搭子，彼此照亮，共同坚守自律初心',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 我的结对专属密令卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A332B), const Color(0xFF13231F)]
                    : [const Color(0xFFE6F4EA), const Color(0xFFF1F8F5)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.mintGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.mintGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔑', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '我的专属结对密令',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buddyService.myPairCode,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.mintGreen : const Color(0xFF0F5132),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _buddyService.myPairCode));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制结对密令，发送给朋友即可绑定！✨'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('复制'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.mintGreen,
                    side: const BorderSide(color: AppTheme.mintGreen),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 主体内容：已结对搭子卡片 VS 结对表单
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: buddy != null && buddy.isPaired && !_isEnteringCode
                  ? _buildPairedSection(buddy, isDark)
                  : _buildPairingFormSection(isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 已结对展示区
  Widget _buildPairedSection(BuddyProfile buddy, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搭子信息卡
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.mintGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(buddy.avatarEmoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              buddy.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🔥 连胜 ${buddy.streakDays} 天',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '“${buddy.slogan}”',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (val) {
                      if (val == 'rebind') {
                        setState(() => _isEnteringCode = true);
                      } else if (val == 'unbind') {
                        _showUnbindConfirmation();
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'rebind', child: Text('更换搭子')),
                      const PopupMenuItem(
                        value: 'unbind',
                        child: Text('解除结对', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              // 快捷互勉动作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: BuddyInteractionType.values.map((type) {
                  return InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _buddyService.sendInteraction(type);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已发送【${type.title}】给搭子！${type.iconEmoji}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Text(type.iconEmoji, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 6),
                          Text(type.title, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 互勉历史动态时间轴
        const Text(
          '💌 互勉时光印记',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (buddy.interactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text('暂无互动，点击上方按钮给搭子戳一戳吧！', style: TextStyle(color: Colors.grey[500])),
            ),
          )
        else
          ...buddy.interactions.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF191919) : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Text(item.type.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.fromMe ? '我' : buddy.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item.fromMe ? AppTheme.mintGreen : Colors.blueAccent,
                              ),
                            ),
                            Text(
                              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(item.message, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  /// 绑定新搭子表单
  Widget _buildPairingFormSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '输入对方的结对密令',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '让搭子在其 App 复制密令后发给你，填入即可建立双人互勉搭子关系。',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: '搭子专属密令 (例如: GT-ALEX-8848)',
            prefixIcon: const Icon(Icons.vpn_key_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '搭子昵称备注 (选填，例如：健身搭子小李)',
            prefixIcon: const Icon(Icons.badge_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            if (_buddyService.buddy != null && _isEnteringCode)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEnteringCode = false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('返回'),
                  ),
                ),
              ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final code = _codeController.text.trim();
                  if (code.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请输入搭子的结对密令！')),
                    );
                    return;
                  }
                  HapticFeedback.mediumImpact();
                  final ok = _buddyService.pairWithCode(
                    code,
                    nickname: _nameController.text.trim().isNotEmpty
                        ? _nameController.text.trim()
                        : null,
                  );
                  if (ok) {
                    setState(() => _isEnteringCode = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 恭喜！已成功建立习惯结对！')),
                    );
                  }
                },
                icon: const Icon(Icons.link_rounded),
                label: const Text('确认结对'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showUnbindConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('解除搭子关系'),
        content: const Text('确定要与当前习惯搭子解除结对吗？随时可以使用新密令重新绑定。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _buddyService.unpair();
              setState(() => _isEnteringCode = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已解除搭子结对')),
              );
            },
            child: const Text('确认解除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
