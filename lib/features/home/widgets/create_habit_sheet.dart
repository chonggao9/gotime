import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';
import 'package:uuid/uuid.dart';

class CreateHabitSheet extends StatefulWidget {
  final Function(Habit) onSave;

  const CreateHabitSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  final _nameController = TextEditingController();
  
  // 默认状态
  String _selectedEmoji = '🎯';
  String _selectedColor = '#34D399'; // Mint Green
  HabitType _selectedType = HabitType.boolean;
  
  // 附加设定
  int _targetValue = 2000;
  String _targetUnit = 'ml';
  int _timerMinutes = 25;

  final List<String> _emojis = ['🎯', '💧', '📚', '🏃‍♂️', '🧘‍♀️', '🥗', '💻', '💸', '🛌', '🚭'];
  final List<String> _colors = ['#34D399', '#60A5FA', '#F472B6', '#FBBF24', '#A78BFA', '#F87171'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.vibrate();
      // 这里可以加一个优雅的 Toast 提示
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    final newHabit = Habit(
      id: const Uuid().v4(), // 生成唯一ID
      name: _nameController.text.trim(),
      iconEmoji: _selectedEmoji,
      themeColor: _selectedColor,
      type: _selectedType,
      targetValue: _selectedType == HabitType.counter ? _targetValue : null,
      targetUnit: _selectedType == HabitType.counter ? _targetUnit : null,
      timerSeconds: _selectedType == HabitType.timer ? _timerMinutes * 60 : null,
      frequency: {'type': 'daily'}, // 默认每天
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
        // 处理键盘遮挡问题
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部小横条
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
            const SizedBox(height: 24),
            
            // 标题
            Text(
              '建立新习惯',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 快捷灵感推荐库 (基于 Streaks / Fabulous / Habitify 行业大数据精炼)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPresetChip('💧 喝水 2L', '每日补水 2L', '💧', '#60A5FA', HabitType.counter, 2000, 'ml', null),
                      _buildPresetChip('🛏️ 11点早睡', '11点前睡觉', '🛏️', '#A78BFA', HabitType.boolean, null, null, null),
                      _buildPresetChip('🍅 深度专注', '深度工作', '💻', '#F87171', HabitType.timer, null, null, 25),
                      _buildPresetChip('🏃‍♂️ 运动 30分', '有氧运动', '🏃‍♂️', '#FBBF24', HabitType.timer, null, null, 30),
                      _buildPresetChip('📓 每日复盘', '今日复盘', '📓', '#34D399', HabitType.boolean, null, null, null),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPresetChip('🧘‍♀️ 冥想 15分', '正念冥想', '🧘‍♀️', '#34D399', HabitType.timer, null, null, 15),
                      _buildPresetChip('📚 阅读 30分', '沉浸阅读', '📚', '#F472B6', HabitType.timer, null, null, 30),
                      _buildPresetChip('💊 补充维C', '吃维他命', '💊', '#FBBF24', HabitType.boolean, null, null, null),
                      _buildPresetChip('🍩 戒除甜食', '戒除游离糖', '🍩', '#F87171', HabitType.quit, null, null, null),
                      _buildPresetChip('📱 戒睡前刷手机', '戒除睡前手机', '📱', '#A78BFA', HabitType.quit, null, null, null),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Emoji与名称输入区
            Row(
              children: [
                _buildEmojiSelector(isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: false, // 改为 false，避免一上来就弹键盘遮挡灵感库
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: '例如: 早起喝水',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 颜色选择器
            Text('专属颜色', style: _labelStyle(isDark)),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 24),

            // 类型选择器
            Text('打卡类型', style: _labelStyle(isDark)),
            const SizedBox(height: 12),
            _buildTypeSelector(isDark),
            const SizedBox(height: 24),
            
            // 动态设置区域 (数值或计时)
            if (_selectedType == HabitType.counter || _selectedType == HabitType.timer)
              _buildDynamicSettings(isDark),

            // 保存按钮
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('保 存', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 提取的 UI 组件 =====

  TextStyle _labelStyle(bool isDark) => TextStyle(
    fontSize: 14, 
    fontWeight: FontWeight.bold, 
    color: isDark ? Colors.grey[400] : Colors.grey[600]
  );

  Widget _buildPresetChip(String label, String name, String emoji, String color, HabitType type, int? tVal, String? tUnit, int? timerMins) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.mintGreen.withOpacity(0.1),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          HapticFeedback.selectionClick();
          setState(() {
            _nameController.text = name;
            _selectedEmoji = emoji;
            _selectedColor = color;
            _selectedType = type;
            if (tVal != null) _targetValue = tVal;
            if (tUnit != null) _targetUnit = tUnit;
            if (timerMins != null) _timerMinutes = timerMins;
          });
        },
      ),
    );
  }

  Widget _buildEmojiSelector(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // 简易版的水平滚动表情选择器
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              itemCount: _emojis.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () {
                  setState(() => _selectedEmoji = _emojis[i]);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(_emojis[i], style: const TextStyle(fontSize: 32)),
                ),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(isSelected ? 1.0 : 0.6),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))] : [],
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
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.mintGreen.withOpacity(0.5))),
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
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.mintGreen.withOpacity(0.5))),
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
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.mintGreen.withOpacity(0.5))),
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
