import 'package:flutter/foundation.dart';

/// 休假冻结服务
class FreezeModeService {
  static final FreezeModeService instance = FreezeModeService._internal();
  FreezeModeService._internal();

  /// 休假状态通知器
  final ValueNotifier<bool> isFreezeModeActive = ValueNotifier<bool>(false);
  
  /// 休假备注
  String currentReason = '身心充电中';

  /// 切换休假模式
  void toggleFreezeMode({String? reason}) {
    if (!isFreezeModeActive.value) {
      if (reason != null && reason.isNotEmpty) {
        currentReason = reason;
      }
      isFreezeModeActive.value = true;
    } else {
      isFreezeModeActive.value = false;
    }
  }

  /// 设置开启或关闭
  void setFreezeMode(bool active, {String? reason}) {
    if (reason != null && reason.isNotEmpty) {
      currentReason = reason;
    }
    isFreezeModeActive.value = active;
  }
}
