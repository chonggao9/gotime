/// 数值型习惯步进推导工具
class CounterStepHelper {
  /// 根据单位和目标值自适应推导最合理的单次点按步进增量
  static int deduceDefaultStep(int targetValue, String? unit) {
    if (targetValue <= 0) return 1;

    final lowerUnit = unit?.toLowerCase().trim() ?? '';
    if (lowerUnit == 'ml' || lowerUnit == '毫升') {
      return 250;
    }
    if (lowerUnit == 'km' || lowerUnit == '公里' || lowerUnit == '千米' || lowerUnit == '公里/h') {
      return 1;
    }
    if (lowerUnit == '页' || lowerUnit == 'page' || lowerUnit == 'pages' || lowerUnit == '章') {
      return (targetValue >= 50) ? 10 : 5;
    }
    if (lowerUnit == '分' || lowerUnit == '分钟' || lowerUnit == 'min' || lowerUnit == 'mins') {
      return 15;
    }
    if (lowerUnit == '个' || lowerUnit == '次' || lowerUnit == '杯' || lowerUnit == '组') {
      return 1;
    }

    // 默认自适应分级
    if (targetValue >= 1000) return 100;
    if (targetValue >= 100) return 20;
    if (targetValue >= 20) return 5;
    return 1;
  }
}
