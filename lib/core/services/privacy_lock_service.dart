import 'package:flutter/foundation.dart';

/// 隐私安全锁服务 (FaceID / 指纹 / PIN 码防护)
class PrivacyLockService extends ChangeNotifier {
  PrivacyLockService._();
  static final PrivacyLockService instance = PrivacyLockService._();

  bool _isLockEnabled = false;
  bool _isLocked = false;
  String _pinCode = '1234'; // 默认 4 位 PIN 码

  bool get isLockEnabled => _isLockEnabled;
  bool get isLocked => _isLocked;
  String get pinCode => _pinCode;

  void setLockEnabled(bool enabled) {
    _isLockEnabled = enabled;
    if (!enabled) {
      _isLocked = false;
    }
    notifyListeners();
  }

  void lock() {
    if (_isLockEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  bool unlock(String inputPin) {
    if (inputPin == _pinCode) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void setPinCode(String newPin) {
    if (newPin.length == 4) {
      _pinCode = newPin;
      notifyListeners();
    }
  }
}
