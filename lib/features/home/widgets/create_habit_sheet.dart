import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';
import 'package:uuid/uuid.dart';

class CreateHabitSheet extends StatefulWidget {
  final Function(Habit) onSave;
  final List<Habit> existingHabits;

  const CreateHabitSheet({
    super.key,
    required this.onSave,
    this.existingHabits = const [],
  });

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  final _nameController = TextEditingController();
  
  // 默认状态
  String _selectedEmoji = '🎯';
  String _selectedColor = '#34D399'; // Mint Green
  HabitType _selectedType = HabitType.boolean;
  String _selectedTimeOfDay = 'all'; // all, morning, afternoon, evening
  
  // 习惯堆叠字段
  String? _selectedStackedHabitId;
  String? _selectedStackedHabitName;

  // 附加设定
  int _targetValue = 2000;
  String _targetUnit = 'ml';
  int _timerMinutes = 25;

  final List<String> _emojis = ['🎯', '💧', '📚', '🏃‍♂️', '🧘‍♀️', '🥗', '💻', '💸', '🛌', '🚭'];
  final List<String> _colors = ['#34D399', '#60A5FA', '#F472B6', '#FBBF24', '#A78BFA', '#F87171'];

  // 推荐习惯包预设
  final List<Map<String, dynamic>> _presets = [
    {
      'title': '晨间温水',
      'emoji': '💧',
      'color': '#34D399',
      'type': HabitType.counter,
      'targetValue': 2000,
      'targetUnit': 'ml',
      'timeOfDay': 'morning',
    },
    {
      'title': '深度工作',
      'emoji': '🍅',
      'color': '#F87171',
      'type': HabitType.timer,
      'timerMinutes': 25,
      'timeOfDay': 'afternoon',
    },
    {
      'title': '睡前慢读',
      'emoji': '📚',
      'color': '#60A5FA',
      'type': HabitType.boolean,
      'timeOfDay': 'evening',
    },
    {
      'title': '正念冥想',
      'emoji': '🧘‍♀️',
      'color': '#A78BFA',
      'type': HabitType.timer,
      'timerMinutes': 10,
      'timeOfDay': 'evening',
    },
    {
      'title': '清晨慢跑',
      'emoji': '🏃‍♂️',
      'color': '#FBBF24',
      'type': HabitType.counter,
      'targetValue': 5,
      'targetUnit': 'km',
      'timeOfDay': 'morning',
    },
    {
      'title': '戒烟节制',
      'emoji': '🚭',
      'color': '#F87171',
      'type': HabitType.quit,
      'timeOfDay': 'all',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    HapticFeedback.lightImpact();
    setState(() {
      _nameController.text = preset['title'] as String;
      _selectedEmoji = preset['emoji'] as String;
      _selectedColor = preset['color'] as String;
      _selectedType = preset['type'] as HabitType;
      _selectedTimeOfDay = preset['timeOfDay'] as String;
      if (preset.containsKey('targetValue')) {
        _targetValue = preset['targetValue'] as int;
        _targetUnit = preset['targetUnit'] as String;
      }
      if (preset.containsKey('timerMinutes')) {
        _timerMinutes = preset['timerMinutes'] as int;
      }
    });
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入习惯名称'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    final newHabit = Habit(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      iconEmoji: _selectedEmoji,
      themeColor: _selectedColor,
      type: _selectedType,
      targetValue: _selectedType == HabitType.counter ? _targetValue : null,
      targetUnit: _selectedType == HabitType.counter ? _targetUnit : null,
      timerSeconds: _selectedType == HabitType.timer ? _timerMinutes * 60 : null,
      frequency: {'type': 'daily'},
      timeOfDay: _selectedTimeOfDay,
      stackedAfterHabitId: _selectedStackedHabitId,
      stackedAfterHabitName: _selectedStackedHabitName,
      updatedAt: DateTime.now(),
    );
    
    widget.onSave(newHabit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部拉条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 标题
            Text(
              '建立新习惯',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 推荐习惯包快捷导入 (F2.4)
            _buildPresetBar(isDark),
            const SizedBox(height: 20),

            // 图标与名称输入
            Row(
              children: [
                _buildEmojiPicker(isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: '如：晨间喝温水、阅读15分钟',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 习惯类型选择
            Text('习惯类型', style: _labelStyle(isDark)),
            const SizedBox(height: 12),
            _buildTypeSelector(isDark),
            const SizedBox(height: 20),

            // 动态数值设置
            _buildDynamicSettings(isDark),

            // 时段分类选择 (F2.2)
            Text('执行时段', style: _labelStyle(isDark)),
            const SizedBox(height: 12),
            _buildTimeOfDaySelector(isDark),
            const SizedBox(height: 24),

            // 《原子习惯》习惯堆叠触发器 (F2.3)
            _buildHabitStackingSection(isDark),

            // 主题色选择
            Text('标记颜色', style: _labelStyle(isDark)),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 32),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '立即开启新习惯',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
    );
  }

  Widget _buildPresetBar(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('✨ ', style: TextStyle(fontSize: 14)),
            Text(
              '一键预设模板包',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _presets.map((preset) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: Text(preset['emoji'] as String, style: const TextStyle(fontSize: 14)),
                  label: Text(preset['title'] as String),
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                  side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => _applyPreset(preset),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitStackingSection(bool isDark) {
    if (widget.existingHabits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('⛓️ 习惯堆叠锚点 (原子习惯法则)', style: _labelStyle(isDark)),
            if (_selectedStackedHabitId != null)
              GestureDetector(
                onTap: () => setState(() {
                  _selectedStackedHabitId = null;
                  _selectedStackedHabitName = null;
                }),
                child: const Text('清除绑定', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '在完成选中的前置习惯后，系统将自动提示顺便完成此习惯。',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600]),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: widget.existingHabits.map((h) {
              final isChosen = _selectedStackedHabitId == h.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  avatar: Text(h.iconEmoji),
                  label: Text('在【${h.name}】之后'),
                  selected: isChosen,
                  selectedColor: AppTheme.mintGreen.withValues(alpha: 0.2),
                  onSelected: (val) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (val) {
                        _selectedStackedHabitId = h.id;
                        _selectedStackedHabitName = h.name;
                      } else {
                        _selectedStackedHabitId = null;
                        _selectedStackedHabitName = null;
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmojiPicker(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (ctx) => Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: _emojis.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () {
                  setState(() => _selectedEmoji = _emojis[i]);
                  Navigator.pop(context);
                },
                child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 28))),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _colors.map((hexCode) {
        final color = Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
        final isSelected = _selectedColor == hexCode;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedColor = hexCode);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isSelected ? 1.0 : 0.6),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 4))]
                  : [],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _typeOption('常规', HabitType.boolean, isDark),
          _typeOption('数值', HabitType.counter, isDark),
          _typeOption('专注', HabitType.timer, isDark),
          _typeOption('戒除', HabitType.quit, isDark),
        ],
      ),
    );
  }

  Widget _typeOption(String label, HabitType type, bool isDark) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedType = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.mintGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOfDaySelector(bool isDark) {
    final slots = [
      {'key': 'all', 'label': '全天 🌟'},
      {'key': 'morning', 'label': '晨间 🌅'},
      {'key': 'afternoon', 'label': '午间 ☀️'},
      {'key': 'evening', 'label': '晚间 🌙'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: slots.map((slot) {
          final isSelected = _selectedTimeOfDay == slot['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedTimeOfDay = slot['key']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? Colors.grey[800] : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    slot['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.darkMintGreen
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicSettings(bool isDark) {
    if (_selectedType == HabitType.counter) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          children: [
            Text('每日目标:', style: _labelStyle(isDark)),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => _targetValue = int.tryParse(v) ?? 0,
                decoration: InputDecoration(
                  hintText: '2000',
                  isDense: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.mintGreen.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                onChanged: (v) => _targetUnit = v,
                decoration: InputDecoration(
                  hintText: 'ml',
                  isDense: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.mintGreen.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedType == HabitType.timer) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          children: [
            Text('单次专注:', style: _labelStyle(isDark)),
            const SizedBox(width: 16),
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => _timerMinutes = int.tryParse(v) ?? 25,
                decoration: InputDecoration(
                  hintText: '25',
                  isDense: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.mintGreen.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('分钟', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
