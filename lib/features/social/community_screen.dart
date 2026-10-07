import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/buddy_service.dart';
import '../../core/services/kindness_mailbox_service.dart';
import '../../core/database/sqlite_service.dart';
import 'widgets/buddy_pairing_dialog.dart';
import 'widgets/cloud_sync_dialog.dart';
import '../home/widgets/kindness_mailbox_dialog.dart';
import '../stats/widgets/milestone_hall_dialog.dart';
import '../../core/services/milestone_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _buddyService = BuddyService.instance;
  final _mailboxService = KindnessMailboxService.instance;
  int _myWeeklyDays = 3;

  @override
  void initState() {
    super.initState();
    _buddyService.addListener(_onServiceChanged);
    _mailboxService.addListener(_onServiceChanged);
    _loadMyWeeklyDays();
  }

  @override
  void dispose() {
    _buddyService.removeListener(_onServiceChanged);
    _mailboxService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadMyWeeklyDays() async {
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final mondayStr = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      final sunday = monday.add(const Duration(days: 6));
      final sundayStr = '${sunday.year}-${sunday.month.toString().padLeft(2, '0')}-${sunday.day.toString().padLeft(2, '0')}';

      final checkIns = await SQLiteService.instance.getCheckInsForDateRange(mondayStr, sundayStr);
      final days = BuddyService.instance.calculateMyWeeklyDays(checkIns);
      if (mounted) {
        setState(() => _myWeeklyDays = days > 0 ? days : 1);
      }
    } catch (_) {}
  }

  void _showMilestoneHall(BuildContext context) {
    HapticFeedback.lightImpact();
    final badges = MilestoneService.instance.getBadges(
      habits: [],
      checkIns: [],
      maxStreak: 12,
      totalFocusMinutes: 135,
    );
    MilestoneHallDialog.show(context, badges: badges);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buddy = _buddyService.buddy;
    final remainingDays = 7 - DateTime.now().weekday + 1;
    final note = _mailboxService.currentDrawnNote ?? _mailboxService.allNotes.first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('自律圈子', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_rounded),
            tooltip: '多端设备协同',
            onPressed: () => CloudSyncDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: _buddyService.hasBuddy ? '管理搭子' : '邀请搭子',
            onPressed: () {
              HapticFeedback.lightImpact();
              BuddyPairingDialog.show(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 模块一：专属搭子与双轨对决
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '专属双人搭子',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    BuddyPairingDialog.show(context);
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: Text(_buddyService.hasBuddy ? '管理密令' : '密令结对'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.mintGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 好友对决卡片
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                BuddyPairingDialog.show(context);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🏆 本周全勤对决',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '剩余 $remainingDays 天',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 我的进度
                    _buildComparisonTrack(
                      name: '我 (自律先行者)',
                      avatarEmoji: '🌱',
                      progress: (_myWeeklyDays / 7).clamp(0.0, 1.0),
                      days: _myWeeklyDays,
                      color: AppTheme.mintGreen,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // 好友进度
                    if (buddy != null && buddy.isPaired) ...[
                      _buildComparisonTrack(
                        name: buddy.name,
                        avatarEmoji: buddy.avatarEmoji,
                        progress: (buddy.weeklyDays / 7).clamp(0.0, 1.0),
                        days: buddy.weeklyDays,
                        color: Colors.blueAccent,
                        isDark: isDark,
                      ),
                      if (buddy.interactions.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(buddy.interactions.first.type.iconEmoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  buddy.interactions.first.message,
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '点击互勉 >',
                                style: TextStyle(fontSize: 11, color: AppTheme.mintGreen, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '暂未结对搭子 · 点击绑定密令开启双人互勉',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 模块二：同路人善意共鸣信箱
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '同路人善意信箱',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    KindnessMailboxDialog.show(context);
                  },
                  icon: const Icon(Icons.mail_outline_rounded, size: 16),
                  label: const Text('抽取便签'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                KindnessMailboxDialog.show(context);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2623) : const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE8DFD0),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(note.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              note.category,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(note.isLiked ? '🤗' : '🤍', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${note.likesCount}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      note.content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF2C241D),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '—— ${note.authorTag}',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white54 : Colors.brown[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 模块三：自律荣誉殿堂与勋章
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '圈子荣誉殿堂',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showMilestoneHall(context),
                  icon: const Icon(Icons.military_tech_rounded, size: 18),
                  label: const Text('全部勋章'),
                  style: TextButton.styleFrom(foregroundColor: Colors.amber[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () => _showMilestoneHall(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '自律里程碑勋章殿堂',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '已设立 8 大心流徽章 · 与搭子互勉见证点滴成长',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTrack({
    required String name,
    required String avatarEmoji,
    required double progress,
    required int days,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Text(avatarEmoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '$days/7 天',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
