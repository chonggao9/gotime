# GoTime 习惯养成 (GoTime Habit Tracker)

> **极简·抗焦虑·数据自主·零羞耻感的习惯养成与心流伴侣**  
> 致力于打破“断签一天就清零”的挫败感，通过**指数平滑习惯强度模型**与**休假免责冻结机制**，让自律成为从容前行的阶梯，而非自我苛责的枷锁。

---

## 🌟 核心理念与心理学设计 (Philosophy)

1. **断签不归零，允许合法喘息**：
   - 告别传统打卡 App 的机械断签挫败。GoTime 引入源自学术研究的**指数平滑稳态强度分数 (Habit Strength Score)** ($\alpha = 0.94$) 与**休假免责模式 (Vacation & Streak Freeze)**。
   - 昨天身体不适或度假，休假跳过即可保留连胜，强度分数平移不衰减。
2. **拒绝大广场虚荣，专注温情陪伴**：
   - 不搞喧嚣的信息流与点赞攀比，仅提供 1 对 1 **双人搭子同盟**（碰拳 👊、加油 🔥、送水 💧、抱抱 🤗）与**离线善意共鸣信箱**。
3. **100% 本地优先与数据主权 (Local-First & Zero Telemetry)**：
   - 核心数据全部存放于设备本地安全的 SQLite 数据库；
   - 绝不收集任何遥测日志，绝无第三方商业广告，支持 WebDAV 私有网盘云端双向同步与一键数据物理粉碎。

---

## 📱 核心四大导航模块 (App Architecture)

应用采用标准的 **4 列固定底部导航 (Fixed 4-Tab Navigation)**，模块边界清晰、职责专一：

| 导航标签 | 核心组件 | 核心功能与亮点 |
| :--- | :--- | :--- |
| **今日习惯** <br>*(Today)* | [`HomeScreen`](file:///d:/work/gotime/lib/features/home/home_screen.dart) | • **周历矩阵与卡片列表双视图** (`HabitMatrixGridView` 周一至周日全景打卡)<br>• 极速打卡、长按休假冻结跳过<br>• 数值型自适应步进微调 (`QuickCounterSheet`)<br>• 坏习惯戒断正向计时与 4-7-8 呼吸急救冲浪 (`Urge Surfing`)<br>• 《原子习惯》两分钟破壁器与习惯堆叠<br>• 晨/午/晚时段过滤与自定义触感拖拽排序 |
| **数据洞察** <br>*(Stats)* | [`StatsScreen`](file:///d:/work/gotime/lib/features/stats/stats_screen.dart) | • GitHub 风格 52 周年度全景热力图 (冰蓝休假标识)<br>• 指数平滑稳态强度分多维雷达与完成率曲线<br>• 习惯心流疗愈微缩花园 (拟物玻璃温室，萌植生长无枯萎惩罚)<br>• 习惯日记时间轴与打卡感悟流<br>• 杂志级打卡海报生成与分享 |
| **自律圈子** <br>*(Community)* | [`CommunityScreen`](file:///d:/work/gotime/lib/features/social/community_screen.dart) | • **独立列**：双人同盟专属密令结对<br>• 双轨打卡进度对比 (直观查看彼此坚守)<br>• 4 项隔空温情互动（碰拳 / 加油 / 送水 / 拥抱）<br>• 圈子留言板与时光印记动态流<br>• 离线善意共鸣信箱卡片与自律勋章殿堂快捷通道 |
| **系统设置** <br>*(Settings)* | [`SettingsScreen`](file:///d:/work/gotime/lib/features/settings/settings_screen.dart) | • **独立列**：全局深浅主题与品牌主色调引擎<br>• 桌面小组件工坊 (2x2 / 4x2 尺寸样式预览)<br>• watchOS & Wear OS 智能手表独立微端仿真<br>• 生物识别 FaceID/指纹与 4 位 PIN 隐私安全锁<br>• 正念防沉迷呼吸冷却护盾 (`MindfulShield`)<br>• Apple Health & Android Health Connect 步数打通<br>• 多语言国际化 (简中 / 繁中 / 英文 / 日文)<br>• 本地 JSON/CSV 导入导出与 WebDAV 私有云同步<br>• **隐私政策与合规声明 (`PrivacyPolicyDialog`)**<br>• 苹果 Guideline 5.1.1 合规一键物理销毁粉碎数据 |

---

## 🎧 专注声境与心流体验

- **48kHz 母带级多轨环境白噪音混音台**：
  - 杜绝单调算法合成声，内置林间清风 🌲、窗边细雨 🌧️、深海浪涌 🌊、木柴壁炉 🔥、静谧咖啡馆 ☕ 五路真实采风母带；
  - 支持多轨独立音量推子混音与经典音景预设一键切换。
- **正念自律屏障 (Mindful Shield)**：
  - 当察觉到无意识摸手机或刷短视频诱惑时，提供 15 秒平缓呼吸冷却，重夺前额叶皮层主导权。

---

## 🔒 隐私与合规保证 (Privacy & Compliance)

详见专用合规文件：[`docs/PRIVACY_POLICY.md`](file:///d:/work/gotime/docs/PRIVACY_POLICY.md)。

- **Google Play & Apple App Store 双平台合规**：
  - 严格遵守 Google Play API 34+ 最新政策与 Apple Guideline 5.1.1(v)；
  - 运动步数仅在本地用于自动完成打卡目标，**零上传、零商业广告、零用户画像追踪**；
  - 生物识别（指纹/面容）仅在设备安全芯片 (Secure Enclave / TEE) 内部比对，绝不出端；
  - 提供即时可查的应用内《隐私政策》中英双语弹窗入口。

---

## 🛠️ 技术架构与工程规范

```text
lib/
├── core/                        # 全局基础设施
│   ├── database/                # SQLite 本地优先存储与跨平台工厂注入
│   ├── models/                  # 核心数据模型 (Habit, CheckIn, Milestone)
│   ├── services/                # 业务能力引擎 (休假冻结, 强度计算, i18n, WebDAV, 混音等)
│   └── theme/                   # 动态调色板、自适应流光动画与圆角规范
├── features/                    # 业务功能垂直切片
│   ├── home/                    # 今日习惯列表、计时器、打卡面板
│   ├── stats/                   # 数据洞察、热力图、疗愈花园、勋章殿堂
│   ├── social/                  # 自律圈子、同盟结对、善意信箱
│   └── settings/                # 系统设置、小组件工坊、隐私安全锁、合规入口
docs/                            # 产品需求与合规 Single Source of Truth
├── GoTime_Master_PRD.md         # 产品核心设计与需求总文档 (PRD)
├── FEATURE_TODO_ROADMAP.md      # 阶段路线图与待办功能清单 (Roadmap)
└── PRIVACY_POLICY.md            # Google Play & Apple 官方隐私合规中英双语文件
test/                            # 自动化测试套件 (110 项测试 100% PASS)
```

- **开发框架**：Flutter 3.x / Dart 3.x
- **测试保证**：
  ```bash
  flutter test                    # 115 / 115 全项测试通过
  flutter analyze --no-fatal-infos # 0 issues found (代码规范零警告)
  ```

---

## 📚 延伸阅读与开发文档

- [📘 GoTime 核心产品设计与需求总文档 (Master PRD)](file:///d:/work/gotime/docs/GoTime_Master_PRD.md)
- [🗺️ GoTime 产品功能待办清单与演进路线图 (Roadmap)](file:///d:/work/gotime/docs/FEATURE_TODO_ROADMAP.md)
- [🛡️ GoTime 隐私政策与数据合规声明 (Privacy Policy)](file:///d:/work/gotime/docs/PRIVACY_POLICY.md)
