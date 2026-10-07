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

- [x] **F3.2 离线高保真母带采风白噪音声境与颂钵禅鸣 (Offline Hi-Fi Sampled Ambient Soundscapes)** `[P2]`
  - **灵感**：*Forest / Moodist / InlitX*
  - **核心准则**：**彻底摒弃机械刺耳的 Web Audio 算法数学震荡器合成方案，全量内置高保真母带采风真实音源资产**。
  - **描述**：番茄钟/计时专注期间，支持伴随 48kHz / 320kbps 纯天然采风原声：淅淅春雨 🌧️（野外春雨实录）、幽静森林 🌲（林间微风吹拂树冠真音）、舒缓潮汐 🌊（大西洋深海浪涌）、温暖壁炉 🔥（真实松木柴火爆裂微鸣）、街角咖啡 ☕（巴黎左岸咖啡馆人声氛围），倒计时结束提供纯正青铜禅音颂钵回荡。
  - **落地交付**：在 `assets/audio/` 与 `web/sounds/` 内置完整实录高保真音轨；实现 `PlatformAudioPlayer` 跨平台零时延无缝离线循环引擎；升级 `AmbientSoundService`、`SoundSelectorSheet`（标驻 `Hi-Fi 实录` 与 `48kHz 实录真音` 标签）与 `SoundWaveVisualizer`，通过 50/50 单元测试全面验证。

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

## 阶段五：前沿探索与隐私守护 (Phase 5: Hardware & Privacy Guardian)

- [x] **F5.1 苹果健康与安卓 Health Connect 步数/睡眠自动打卡 (Health Auto Tracking)** `[P3]`
  - **描述**：集成系统级运动健康传感器数据（Apple Health / Android Health Connect），智能识别每日步数、睡眠时长并自动感应达标，实现无感自动打卡与日志记录。
  - **落地交付**：已实现 `HealthSyncService`、`HealthSyncDialog` 传感器控制台面板，支持步数/睡眠智能达标判定、自动写入打卡数据库，并由单元测试全面覆盖。

- [x] **F5.2 生物识别与 4 位 PIN 隐私安全锁 (Biometric Privacy & PIN Lock)** `[P2]`
  - **描述**：提供银行级隐私保护，App 退至后台或闲置时自动进入高斯模糊锁屏，支持 FaceID / 指纹触控或 4 位数字密码解锁，确保自律日记与打卡足迹私密安全。
  - **落地交付**：已实现 `PrivacyLockService` 全局状态管理、`PrivacyLockOverlay` 磨砂毛玻璃全屏遮罩与触感九宫格数字键盘，集成于主入口并接入生命周期监听与单元测试。

- [x] **F5.3 智能手表 Wear OS / watchOS 独立微端打卡 (Watch Extension & Dial Companion)** `[P3]`
  - **描述**：腕上独立微端打卡体验。支持 Apple Watch 方形（Squircle）与 Pixel / Galaxy Watch 圆形（Round）物理表壳拟真仿真、表冠（Digital Crown）触感交互、实时同步置顶微习惯并支持一键抬腕即打卡与表盘复杂功能（Complications）。
  - **落地交付**：已实现 `WatchCompanionService`、`WatchPreviewDialog` 拟真 OLED 硬件仿真弹窗，在【圈子与设置】中提供配置入口，并通过单元测试全面验证。

---

## 阶段六：弹性度量与正向成就反馈 (Phase 6: Flexible Cadence & Trophy Hall)

- [x] **F6.1 灵活周期与弹性打卡频次调度 (Flexible Frequency: X Times Per Week / Days)** `[P1]`
  - **灵感**：*Loop Habit Tracker (uhabits)*, *Everyday*
  - **描述**：打破“必须每日打卡”的机械焦虑。支持创建习惯时选择“每日打卡”、“每周弹性 X 次 (1~6次)”或“指定工作日/周末”，计算周历（自然周）完成进度与达成率。
  - **落地交付**：在 `Habit` 模型增加 `frequencySummary`、`targetTimesPerPeriod` 与 `targetDaysOfWeek`；在 `CreateHabitSheet` 实现多模式周期选择器与步进器；在 `HabitCard` 渲染专属弹性周期胶囊徽章；实现 `FrequencyService` 及其周跨度调度算法与单元测试。

- [x] **F6.2 习惯里程碑成就与自律勋章殿堂 (Milestone Badges & Trophy Hall)** `[P1]`
  - **灵感**：*Habitica*, *Apple Fitness Badges*
  - **描述**：构建多维成就勋章体系（🌱 萌芽破晓、⚡ 7日破壁、🧱 21日筑基回路、💯 百日自律、🧘 深度心流大师、❄️ 从容自洽休假、🧩 原子堆叠、☁️ 数据主权守护）。
  - **落地交付**：已实现 `MilestoneService` 动态条件评估引擎；在数据洞察页集成横向勋章动量流；实现 `MilestoneHallDialog` 殿堂弹窗，支持未解锁进度暗态指示、已解锁高亮流光效果与一键杂志级海报分享，并通过单元测试验证。

- [x] **F6.3 全景色彩足迹与年度像素年鉴 (Year in Pixels / Annual Habit Panorama)** `[P1]`
  - **灵感**：*Bullet Journal / Everyday / Year in Pixels*
  - **描述**：将全年度 365 天习惯完成度与心情状态映射为 12 个月色彩马赛克矩阵。支持单日悬浮点选详情透视、年度坚持天数/达成率/免责休假多维汇总，并支持一键导出个人成长全景像素画卷长图。
- [x] **F6.4 多语言国际化全球化引擎 (i18n Localization Engine)** `[P2]`
  - **灵感**：*Global Productivity Apps (Loop / TickTick)*
  - **描述**：出海就绪。支持简体中文（🇨🇳 简体中文）、繁体中文（🇭🇰 繁體中文）、英语（🇺🇸 English）与日语（🇯🇵 日本語）实时无感热切换，覆盖底部导航栏、通用操作、核心指标、设置面板及各类成就弹窗。
  - **落地交付**：已实现响应式 `LocaleService` 全局状态管理、`LanguageSelectorSheet` 交互式语言点选弹窗，并在 `MaterialApp` 入口建立 `Listenable.merge` 双通道响应与单元测试全绿覆盖。

---

## 阶段七：社交陪伴与智能提醒体系 (Phase 7: Accountability Buddy & Smart Reminders)

- [x] **F7.1 习惯搭子双人结对与隔空互勉系统 (Accountability Buddy & Mutual Motivation)** `[P1]`
  - **灵感**：*Support Groups / Accountability Partner Psychology*
  - **核心准则**：**拒绝喧嚣的大广场与虚荣点赞，专注双人深度陪伴与无压力互勉**。
  - **描述**：通过 1 键生成专属专属结对密令（如 `GT-MINT-8848`），朋友填入口令即可双向绑定。双人专属对决卡片动态计算本周完成天数与剩余天数。支持 4 类温暖隔空互动动作：
    - ⚡ **隔空戳一戳**（“轻轻戳了你一下，该喝水运动打卡啦！”）
    - 🙌 **击掌鼓劲**（“太棒了！今天也一起达成了全勤自律！”）
    - ❄️ **赠送请假卡**（“今天累了就好好休息，我帮你守护连胜！”）
    - 🌟 **加油应援**（自定义鼓励便签回音壁）
  - **落地交付**：实现 `BuddyService`、`BuddyPairingDialog`、互勉动态时间轴与双轨打卡对比，全面集成在【圈子与设置】页并通过单元测试。

- [x] **F7.2 智能时段提醒与全局静音免打扰调度 (Smart Habit Reminders & Quiet Hours DND Engine)** `[P0]`
  - **灵感**：*TickTick / Fabulous / Apple Sleep Focus*
  - **描述**：科学分时段温和唤醒，避免信息轰炸。支持三大时段调度（晨间唤醒 08:00、午间回能 13:00、晚间复盘 21:00），支持 24 小时任意时间微调与总控开关；内置夜间深度睡眠免打扰（Quiet Hours: 22:30 ~ 07:00，跨午夜高精度分钟级判定）；支持模拟测试推送。
  - **落地交付**：实现 `ReminderService`、`ReminderSettingsDialog` 弹窗，支持全天提醒概要预览与免打扰逻辑跨午夜自动化测试验证。

---

## 阶段八：坏习惯戒断防护与精细量化度量 (Phase 8: Habit Precision & Bad Habit Urge Surfing)

- [x] **F8.1 坏习惯坚持戒除计时与冲动急救冲浪 (Quit Bad Habit Tracker & Urge Surfing Rescue)** `[P0]`
  - **灵感**：*I Am Sober / Atomic Habits / Mindfulness Psychology*
  - **核心准则**：**正向累计坚守时长，以认知解离与自我宽恕（Self-Compassion）替代羞耻感**。
  - **描述**：
    - 针对戒烟 🚭、戒糖 🍰、戒游戏 🎮 等坏习惯，卡片渲染实时正向计时器（例如 `🔥 已坚守 14 天 6 小时`）；
    - 点击操作区呼出 **“冲动急救冲浪”** 弹窗，提供 4-7-8 呼吸动效（吸气 4s $\rightarrow$ 屏息 7s $\rightarrow$ 呼气 8s）与 180 秒冲动峰值平息倒计时；
    - 若发生破戒，提供无指责复盘（诱因记录：压力、无聊、聚会诱惑等）与自我宽恕便签，重置计时器重新起航。
  - **落地交付**：实现 `QuitHabitService`、`QuitHabitRescueDialog`，并在 `HabitCard` 中深度集成并通过单元测试验证。

- [x] **F8.2 数值型习惯智能步进器与精准量化输入 (Smart Counter Stepper & Direct Value Pad)** `[P1]`
  - **灵感**：*Streaks / Loop Habit Tracker*
  - **描述**：解决数值打卡步进生硬机械问题。基于目标单位（ml, km, 页, 分钟, 杯等）与总目标自动推导最佳单次点击步进量（如喝水 +250ml、运动 +1km、读书 +5页）；支持长按加号或点击数值直接弹出快捷微调面板（QuickCounterSheet），支持拖拽进度滑块与数字键盘直达。
  - **落地交付**：实现 `CounterStepHelper` 自适应步进推导、`QuickCounterSheet` 交互面板与 `HabitCard` 点击/长按联动，全套单元测试通过。

---

## 阶段九：云端多端融合与自由节律重排 (Phase 9: Cloud Synchronization & Habit Reordering)

- [x] **F9.1 云端多端增量合并同步与跨设备游客桥接 (Cloud Sync & Multi-Device Seamless Bridge)** `[P0]`
  - **灵感**：*Apple iCloud / Local-First Software Philosophy*
  - **描述**：兼顾“本地优先隐私”与“多设备无缝漫游”。支持多设备集群管理（Web 客户端、iPhone、Apple Watch 等），支持一键关联账号，采用 Last-Write-Wins (LWW) 增量数据双向哈希校验与版本合库，保护本地离线打卡历史零丢失。
  - **落地交付**：实现 `CloudSyncService`、`CloudSyncDialog`，在【圈子与设置】中提供设备集群拓扑卡片、WiFi 自动同步与手动一键合库操作，并通过 9/9 单元测试。

- [x] **F9.2 习惯自定义拖拽排序与执行节律编排 (Custom Drag Reordering & Daily Rhythm)** `[P1]`
  - **灵感**：*Things 3 / TickTick / Notion*
  - **描述**：允许用户打破固定创建时间限制，在首页一键开启自定义排序模式，通过触感手柄自由拖拽重排习惯次序。与置顶（Pin）机制无缝融合（置顶习惯优先置顶，其余项严格尊崇自定义编排节律），并提供一键恢复默认。
  - **落地交付**：实现 `HabitOrderService`、首页 `SliverReorderableList` 拖拽交互与状态持久化监听，通过自动化单元测试全覆盖。

---

## 阶段十：日常仪式心流引导与深度周中节律透视 (Phase 10: Guided Routine Flow & Weekly Rhythm Analytics)

- [x] **F10.1 习惯晨间/晚间心流仪式引导播放流 (Guided Daily Routine Flow)** `[P0]`
  - **灵感**：*Fabulous / Routinery / Atomic Habits Habit Chaining*
  - **核心准则**：**将离散的单点习惯串联为连贯的日常仪式，伴随白噪音专注与无痛闭环**。
  - **描述**：打破单个习惯孤立打卡的枯燥感，支持一键开启“晨间唤醒流”或“晚间静心仪式”。全屏沉浸式步骤播放器依次引导完成各个时段习惯，提供当前步骤时长指示、48kHz 高保真背景白噪音伴奏、触感震动反馈，打卡后自动推进至下一环节，最后生成仪式达成温情小结。
  - **落地交付**：实现 `RoutineService`、首页时段过滤栏心流启动胶囊、`RoutinePlaySheet` 沉浸式心流引导面板与环境声动态联动，并通过单元测试验证。

- [x] **F10.2 习惯深度节律、周中完成率分布与情绪相关性分析 (Weekly Rhythms & Mood Correlation Insights)** `[P1]`
  - **灵感**：*Loop Habit Tracker (uhabits) History & Day-of-Week Distribution / Exist.io*
  - **描述**：在数据洞察页深入解析用户的生物钟节律与周中表现趋势（周一至周日 7 根自适应高度胶囊柱，自动标驻巅峰心流日 👑）。结合打卡心情 Emoji（1~5 档），计算平均情绪均值，输出基于心理学模型的自我关怀温情寄语，破除机械的自我苛责。
  - **落地交付**：实现 `HabitAnalyticsService` 计算引擎、`HabitAnalyticsCard` 深度分析卡片，深度嵌入 `StatsScreen`，并通过自动化单元测试全覆盖。

---

## 阶段十一：心理阻力破壁与自然语言速记打卡 (Phase 11: Psychological Friction Breaker & Quick Natural Logger)

- [x] **F11.1 《原子习惯》两分钟微习惯起步定律与心理阻力破壁器 (Two-Minute Rule & Friction Breaker)** `[P0]`
  - **灵感**：*James Clear《Atomic Habits》第13章“两分钟定律”*
  - **核心准则**：**当倦怠与拖延发生时，降级执行微小启动版本，起步即破壁，保持动量不归零**。
  - **描述**：在习惯操作面板提供“两分钟微习惯起步”；根据习惯特征智能推导 2 分钟极简微目标（例如：阅读只翻开读 1 页、跑步先穿上跑鞋原地活动 2 分钟、写作只写 1 句草稿）。提供 120 秒优雅环形倒计时与达成正向激励卡片，完成后自动计入打卡历史并标记为微启动达成。
  - **落地交付**：实现 `FrictionBreakerService`、`TwoMinuteFrictionDialog`，在 `HabitActionSheet` 深度集成并通过自动化单元测试覆盖。

- [x] **F11.2 离线自然语言与语音速记极速打卡引擎 (Offline Natural Language & Voice Quick Logger)** `[P1]`
  - **灵感**：*TickTick / Fantastical / Notion AI*
  - **描述**：无需在列表中逐个寻找习惯，支持输入一段话（例如：“喝水 500ml，阅读 15页，心情超好”），本地规则引擎 100% 离线智能解析出对应的习惯、打卡数值、专注时长与情绪评分，支持一键预览与批量打卡。
  - **落地交付**：实现 `QuickNaturalLoggerService` 解析引擎、首页 AppBar 闪电速记入口、`QuickNaturalLogDialog` 实时解析弹窗与批量提交处理，并通过单元测试验证。
