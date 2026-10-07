import 'package:flutter/foundation.dart';

/// 休假与生病免责冻结模式服务 (Vacation & Freeze Mode)
/// 核心理念：允许合法喘息。在开启冻结模式期间，不打卡不扣减动量分数，连胜不中断。
class FreezeModeService {
  static final FreezeModeService instance = FreezeModeService._internal();
  FreezeModeService._internal();

  /// 响应式休假状态通知器，供 UI 实时监听刷新
  final ValueNotifier<bool> isFreezeModeActive = ValueNotifier<bool>(false);
  
  /// 休假备注（如：出差中、年假休养、身体不适）
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
