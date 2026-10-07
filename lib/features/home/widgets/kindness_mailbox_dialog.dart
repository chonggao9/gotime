import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/kindness_mailbox_service.dart';

class KindnessMailboxDialog extends StatefulWidget {
  const KindnessMailboxDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => const KindnessMailboxDialog(),
    );
  }

  @override
  State<KindnessMailboxDialog> createState() => _KindnessMailboxDialogState();
}

class _KindnessMailboxDialogState extends State<KindnessMailboxDialog> with SingleTickerProviderStateMixin {
  final _service = KindnessMailboxService.instance;
  late KindnessNote _currentNote;
  String _selectedCategory = '全部';
  bool _isWriting = false;

  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  String _writeCategory = '缓解焦虑';

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<String> _categories = ['全部', '缓解焦虑', '动量重启', '自我宽恕', '静心专注'];

  @override
  void initState() {
    super.initState();
    _currentNote = _service.currentDrawnNote ?? _service.drawRandomNote();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _drawNextNote() {
    HapticFeedback.lightImpact();
    _animController.reset();
    setState(() {
      _currentNote = _service.drawRandomNote(filterCategory: _selectedCategory);
    });
    _animController.forward();
  }

  void _submitCustomNote() {
    if (_contentController.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    final note = _service.writeNote(
      content: _contentController.text.trim(),
      authorTag: _authorController.text.trim(),
      category: _writeCategory,
    );
    setState(() {
      _isWriting = false;
      _currentNote = note;
      _contentController.clear();
      _authorController.clear();
    });
    _animController.reset();
    _animController.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💌 你的善意便签已投入信箱，愿它温暖更多同路人！'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 380,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2623) : const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE8DFD0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: _isWriting ? _buildWriteView(isDark) : _buildNoteView(isDark),
        ),
      ),
    );
  }

  Widget _buildNoteView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💌 ', style: TextStyle(fontSize: 22)),
                  Text(
                    '善意共鸣信箱',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3E332A),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white54 : Colors.brown[300],
                ),
              ),
            ],
          ),

          // 分类筛选小胶囊
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6, top: 4, bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _drawNextNote();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white10 : const Color(0xFFF0EAE1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.brown[700]),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // 核心便签卡片 (拟物明信片质感)
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF26322E) : const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334B42) : const Color(0xFFE5DDD0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_currentNote.emoji} ${_currentNote.category}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                      // 温暖拥抱点赞
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _service.toggleLikeNote(_currentNote.id);
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                _currentNote.isLiked ? '🤗' : '🤍',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_currentNote.likesCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _currentNote.isLiked
                                      ? const Color(0xFF10B981)
                                      : (isDark ? Colors.white54 : Colors.brown[300]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentNote.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.65,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF2C241D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '—— ${_currentNote.authorTag}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white54 : Colors.brown[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 底部操作栏：抽取另一张 / 投递我的便签
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isWriting = true);
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('投递善意 ✍️', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _drawNextNote,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('再抽一张 💌', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWriteView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('✍️ ', style: TextStyle(fontSize: 20)),
                  Text('写下给同路人的便签', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _isWriting = false),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '哪怕是一句简单的肯定，也会成为别人灰暗时刻的微光：',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.brown[400]),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentController,
            maxLines: 4,
            maxLength: 120,
            decoration: InputDecoration(
              hintText: '写下一句充满关怀、理解与鼓励的温情话语...',
              hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white30 : Colors.grey[400]),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F3EB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              hintText: '署名 (例如: 傍晚散步的追风者)',
              hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white30 : Colors.grey[400]),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F3EB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitCustomNote,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('投递入信箱 📬', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
