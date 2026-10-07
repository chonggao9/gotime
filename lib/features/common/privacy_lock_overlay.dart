import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/privacy_lock_service.dart';
import '../../core/services/theme_service.dart';

class PrivacyLockOverlay extends StatefulWidget {
  final Widget child;

  const PrivacyLockOverlay({super.key, required this.child});

  @override
  State<PrivacyLockOverlay> createState() => _PrivacyLockOverlayState();
}

class _PrivacyLockOverlayState extends State<PrivacyLockOverlay> with WidgetsBindingObserver {
  final _service = PrivacyLockService.instance;
  String _input = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _service.lock();
    }
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _onKeyPress(String digit) {
    if (_input.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _input += digit;
      _isError = false;
    });

    if (_input.length == 4) {
      final success = _service.unlock(_input);
      if (!success) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _input = '';
        });
      } else {
        _input = '';
      }
    }
  }

  void _onDelete() {
    if (_input.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _isError = false;
      });
    }
  }

  void _biometricUnlock() {
    HapticFeedback.mediumImpact();
    _service.unlock(_service.pinCode);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeService.instance.brandColor.primary;

    return Stack(
      children: [
        widget.child,

        // 当锁定激活时覆盖全屏高斯模糊与解锁键盘
        if (_service.isLocked)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                color: const Color(0xFF0F1715).withOpacity(0.92),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // 锁图标与标题
                      GestureDetector(
                        onTap: _biometricUnlock,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.fingerprint_rounded, color: primaryColor, size: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GoTime 隐私安全锁',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isError ? '密码错误，请重试 (默认: 1234)' : '点击指纹或输入 4 位 PIN 码解锁',
                        style: TextStyle(
                          color: _isError ? Colors.redAccent : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 4 个密码圆点指示器
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _input.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled ? primaryColor : Colors.white12,
                              border: Border.all(
                                color: isFilled ? primaryColor : Colors.white30,
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),

                      // 0-9 极简九宫格键盘
                      _buildKeypad(primaryColor),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKeypad(Color primaryColor) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['FaceID', '0', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == 'FaceID') {
                  return IconButton(
                    onPressed: _biometricUnlock,
                    icon: Icon(Icons.fingerprint_rounded, color: primaryColor, size: 30),
                  );
                } else if (key == '⌫') {
                  return IconButton(
                    onPressed: _onDelete,
                    icon: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 24),
                  );
                } else {
                  return InkWell(
                    onTap: () => _onKeyPress(key),
                    borderRadius: BorderRadius.circular(36),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
