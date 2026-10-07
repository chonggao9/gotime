# GoTime 产品功能待办清单与演进路线图 (Feature Backlog & Roadmap)

> **定位宗旨**：一款带有“请假机制”、关注用户心理健康、绝不制造焦虑的极简习惯养成工具。  
> 本清单汇总了对标 GitHub 顶级开源项目（Loop Habit Tracker、mhabit、streak 等）及《原子习惯》心理学模型精选的待办功能，按优先级逐步迭代推进。

---

## 📌 状态图例
- [ ] `待实现 (To Do)`
- [ ] 🚧 `进行中 (In Progress)`
- [x] `已交付 (Done)`

---

## 阶段一：核心抗焦虑体验与心理激励 (Phase 1: Quick Wins)
聚焦于彻底解决“断签即归零的焦虑感”与“完成习惯时的即时正向反馈”。

- [x] **F1.1 指数平滑习惯强度分数 (Habit Strength Score)** `[P0]`
  - **灵感**：*Loop Habit Tracker (iSoron/uhabits)*
  - **描述**：引入动态习惯强度百分比（0%~100%），采用指数平滑公式：$S_t = S_{t-1} \cdot \alpha + (1 - \alpha) \cdot V_t$。
  - **价值**：断签 1 天仅衰减小幅百分比（如 85% $\rightarrow$ 80%），次日打卡迅速回升，坚决不直接归零。
  - **落地交付**：已实现 `HabitStrengthService` 及相关单元测试，集成在 `HabitDetailScreen` 及 `StatsScreen`。

- [x] **F1.2 休假与生病免责冻结模式 (Vacation / Sick Freeze)** `[P0]`
  - **灵感**：*InlitX/streak (Vacation Mode)*
  - **描述**：支持在首页或设置中一键开启“休假/生病状态”；休假期间所有习惯自动免除，热力图标记为冰蓝色 ❄️（已休假），连胜不断。
  - **价值**：允许合法喘息，生病与出差不再有心理罪恶感。
  - **落地交付**：已实现 `FreezeModeService`，在首页提供快速休假状态开关与渐变横幅，在设置页提供开关，长按卡片可单项免责跳过，热力图渲染专属冰蓝图例。

- [x] **F1.3 今日全勤庆祝微动效与触感强化 (Celebration Confetti & Haptics)** `[P0]`
  - **灵感**：*PHom798/Flutter-Habit-Tracker*
  - **描述**：当日所有激活习惯均打卡完成时，触发全屏优雅礼花动效（Confetti）与震动回馈。
  - **价值**：给完成一整天目标的自律行为最强烈的多巴胺正向奖励。
  - **落地交付**：已实现纯 Flutter CustomPainter 物理粒子弹窗 `ConfettiCelebrationDialog`，当日所有习惯完成时自动触发动效与重触感反馈。

---

## 阶段二：使用效率与破圈传播 (Phase 2: Growth & Sharing)
聚焦于降低打卡认知负荷、促进自发性社交分享。

- [ ] **F2.1 一键生成杂志级打卡分享海报 (Aesthetic Share Card)** `[P1]`
  - **灵感**：*Everyday / Streaks*
  - **描述**：在数据洞察或习惯详情中，点击分享按钮，自动将年度热力图、连胜数据与今日格言渲染成精致的极简卡片，支持一键保存到本地相册或分享至社交网络。
  - **涉及模块**：`lib/features/stats/`, `lib/features/home/widgets/`

- [ ] **F2.2 习惯时段分类与标签过滤 (Time-of-day & Tags Filter)** `[P1]`
  - **灵感**：*FriesI23/mhabit*
  - **描述**：为习惯增加 `晨间 (Morning)`、`午间 (Afternoon)`、`晚间 (Evening)` 或自定义标签（如健康/工作/学习）；首页支持横向胶囊切换视图。
  - **涉及模块**：`lib/models/habit.dart`, `lib/features/home/home_screen.dart`

- [ ] **F2.3 《原子习惯》习惯堆叠触发器 (Habit Stacking)** `[P1]`
  - **灵感**：*James Clear《Atomic Habits》*
  - **描述**：允许新建习惯时设置“前置锚点”：“在 [习惯A] 之后做 [习惯B]”。首页打卡完 A 时，优雅弹出提示推荐顺带打卡 B。
  - **涉及模块**：`lib/features/home/widgets/create_habit_sheet.dart`

---

## 阶段三：数据主权与沉浸专注 (Phase 3: Privacy & Deep Focus)
聚焦于本地数据安全、无依赖自由备份与专注环境搭建。

- [ ] **F3.1 本地优先数据导入导出与备份 (JSON & CSV Backup)** `[P2]`
  - **灵感**：*FriesI23/mhabit*, *Loop Habit Tracker*
  - **描述**：支持一键导出完整的 `gotime_backup.json`，随时可导入恢复；支持导出 `habits_data.csv`，方便用户在 Excel / Notion 自行分析。
  - **涉及模块**：`lib/core/database/`, `lib/features/social/social_screen.dart`

- [ ] **F3.2 专注计时器白噪音背景音 (Ambient Focus Audio)** `[P2]`
  - **灵感**：*Forest / InlitX*
  - **描述**：番茄钟/计时专注期间，支持伴随舒缓的雨声 🌧️、森林 🌲、咖啡馆 ☕ 白噪音，倒计时结束提供颂钵提醒。
  - **涉及模块**：`lib/features/timer/timer_screen.dart`

- [ ] **F3.3 桌面小组件支持 (Home Screen Widgets)** `[P2]`
  - **描述**：在 Android 与 iOS 桌面提供 2x2 与 4x2 习惯进度与一键打卡小组件。
