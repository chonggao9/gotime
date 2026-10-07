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

- [x] **F2.1 一键生成杂志级打卡分享海报 (Aesthetic Share Card)** `[P1]`
  - **灵感**：*Everyday / Streaks*
  - **描述**：在数据洞察或习惯详情中，点击分享按钮，自动将年度热力图、连胜数据与今日格言渲染成精致的极简卡片，支持一键保存到本地相册或分享至社交网络。
  - **落地交付**：已实现 `SharePosterDialog`，支持 RepaintBoundary 高清截图渲染、自适应专属寄语、微型足迹热力图呈现，已在首页每日金句、数据洞察页及习惯详情页完成全面联动。

- [x] **F2.2 习惯时段分类与标签过滤 (Time-of-day & Tags Filter)** `[P1]`
  - **灵感**：*FriesI23/mhabit*
  - **描述**：为习惯增加 `晨间 (Morning)`、`午间 (Afternoon)`、`晚间 (Evening)` 或自定义标签（如健康/工作/学习）；首页支持横向胶囊切换视图。
  - **落地交付**：已在 `Habit` 模型与 SQLite 数据库增加 `time_of_day` 和 `tags` 支持与自动迁移；在 `CreateHabitSheet` 中支持时段选择，并在 `HomeScreen` 提供横向胶囊时段过滤栏与单元测试。

- [x] **F2.3 《原子习惯》习惯堆叠触发器 (Habit Stacking)** `[P1]`
  - **灵感**：*James Clear《Atomic Habits》*
  - **描述**：允许新建习惯时设置“前置锚点”：“在 [习惯A] 之后做 [习惯B]”。首页打卡完 A 时，优雅弹出提示推荐顺带打卡 B。
  - **落地交付**：已在 `Habit` 模型增加 `stackedAfterHabitId` 与锚点习惯选择器；打卡完成前置习惯后自动弹出“习惯堆叠”即时打卡胶囊，支持一键顺带完成，并通过单元测试验证。

- [x] **F2.4 优质预设习惯模板库 (Curated Habit Preset Bundles)** `[P1]`
  - **描述**：在新建习惯底部提供“精选预设包”（如：晨间一杯温水、25分钟深度工作、睡前慢读15页、正念呼吸冥想等），一键填入 Emoji、时段与颜色。
  - **落地交付**：已在 `CreateHabitSheet` 集成可滑动的预设卡片列表，点击一键自动填充表单。

---

## 阶段三：数据主权与沉浸专注 (Phase 3: Privacy & Deep Focus)
聚焦于本地数据安全、无依赖自由备份与专注环境搭建。

- [x] **F3.1 本地优先数据导入导出与备份 (JSON & CSV Backup)** `[P2]`
  - **灵感**：*FriesI23/mhabit*, *Loop Habit Tracker*
  - **描述**：支持一键导出完整的 `gotime_backup.json`，随时可导入恢复；支持导出 `habits_data.csv`，方便用户在 Excel / Notion 自行分析。
  - **落地交付**：已实现 `BackupService`，支持 RFC 4180 标准 CSV 导出与完整 JSON 备份及合法性校验，并在圈子/设置页提供 `BackupDialog` 界面与自动化测试。

- [x] **F3.2 专注计时器白噪音声境与颂钵禅鸣 (Ambient Focus Soundscapes)** `[P2]`
  - **灵感**：*Forest / InlitX*
  - **描述**：番茄钟/计时专注期间，支持伴随舒缓的雨声 🌧️、森林 🌲、潮汐 🌊、壁炉 🔥、咖啡馆 ☕ 白噪音，倒计时结束提供颂钵禅鸣并自动记录打卡。
  - **落地交付**：已实现 `AmbientSoundService`、`SoundSelectorSheet`、动态起伏波形条 `SoundWaveVisualizer`，专注倒计时结束自动记录 `duration_seconds` 到打卡数据库，并提供暂停/继续控制。

- [x] **F3.3 打卡心得笔记与心情记录真实持久化 (Check-in Note & Mood Logging)** `[P1]`
  - **描述**：将打卡心得备忘与 1~5 档心情 Emoji 真实持久化存储到 `check_ins` 表的 `log_text` 和 `mood` 字段；在习惯详情页可查看历史感悟时间轴，并支持随时补充记录。
  - **落地交付**：已在 `HomeScreen` 连接打卡日志真实插入与取消反选同步，在 `HabitDetailScreen` 渲染真实打卡感悟流与“写心得”入口，并通过自动化测试验证。

- [x] **F3.4 习惯归档管理与休眠池 (Habit Archive & Restore)** `[P2]`
  - **描述**：对于暂时中止但不想删除历史统计的习惯（如考研结束、季节性运动），支持一键“归档休眠”；从今日打卡流隐藏，随时可以在“归档池”中一键唤醒恢复。
  - **落地交付**：已在 `SQLiteService` 实现 `archiveHabit` 与 `getArchivedHabits`，在 `HabitActionSheet` 提供“归档”菜单，并在主页右上角提供 `ArchivedHabitsSheet` 唤醒管理界面。

---

## 阶段四：跨端扩展与生态互联 (Phase 4: Ecosystem & Platform Expansion)

- [x] **F4.1 桌面小组件工坊与全屏实时样式预览 (Desktop Widgets Workshop)** `[P2]`
  - **描述**：在设置页提供桌面小组件工坊，支持 2×2（极简微盘环形进度与当日习惯）与 4×2（宽屏周足迹热力条与一键打卡行）小组件视觉预览与样式配置。
  - **落地交付**：已实现 `WidgetPreviewDialog`，提供手机主屏幕真实环境渲染仿真，支持即时应用配置。

- [x] **F4.2 全局深浅模式与品牌主色调引擎 (Theme & Brand Color Customizer)** `[P1]`
  - **描述**：支持动态切换“极夜暗黑”、“晨曦微白”、“跟随系统”；支持点选切换 4 套官方品牌强调色（翠绿薄荷 🌿、冰晶蔚蓝 ❄️、暮光雅紫 🔮、暖阳珊瑚 🌅）。
  - **落地交付**：已实现响应式 `ThemeService`，在设置页提供可视化点选器，点击实时无缝重塑全 App 主题色彩。

- [x] **F4.3 防焦虑数据洞察升级：每周习惯复盘与动量报告 (Weekly Warm Review & Momentum Insight)** `[P1]`
  - **描述**：在数据洞察页热力图下方，结合抗焦虑心理学模型生成每周温情复盘卡片（统计本周打卡天数、合法免责请假天数、零负荷心理自愈寄语），并支持一键生成杂志级周报海报分享。
  - **落地交付**：已在 `StatsScreen` 中落地 `_buildWeeklyReviewCard` 与周报分享海报生成联动。

- [x] **F4.4 WebDAV 私有网盘双向云同步与自动备份 (WebDAV Cloud Sync)** `[P2]`
  - **描述**：支持坚果云、Nextcloud、群晖 NAS 等私有网盘，通过标准 WebDAV 协议进行全量打卡数据双向私密同步与灾备，无需依赖任何第三方闭源服务。
  - **落地交付**：已实现纯 Dart 标准 HTTP Basic 认证 `WebDavService` 与 `WebDavDialog` 交互弹窗，支持连接验证、一键备份至云端、从云端拉取恢复，并通过单元测试验证。

- [x] **F4.5 习惯置顶锁定与优先级排序 (Habit Pinning)** `[P2]`
  - **描述**：允许将晨间温水、深度工作等核心习惯长按置顶（Pin to Top），在主页打卡列表中始终排在最前面并显示专属金色图钉徽章 📌。
  - **落地交付**：已在 `Habit` 模型增加 `isPinned` 属性与 SQLite 迁移，在 `HabitActionSheet` 提供“置顶 / 取消置顶”操作，在 `HabitCard` 渲染图钉徽章，并通过单元测试验证。

---

## 阶段五：前沿探索与多模态交互 (Phase 5: Future Explorations)

- [ ] **F5.1 苹果健康与安卓 Health Connect 步数/睡眠自动打卡 (Health Auto Tracking)** `[P3]`
- [ ] **F5.2 智能手表 Wear OS / watchOS 独立微端打卡 (Watch Extension)** `[P3]`



