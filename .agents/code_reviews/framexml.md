# 主載入 FrameXML 皮膚記憶

## 範圍與載入契約

- 模組位於 `AuroraClassic/FrameXML/`。
- 實際載入清單以 `AuroraClassic/FrameXML/FrameXML.xml` 為準。
- 隨 AuroraClassic 主插件可直接取得的 Blizzard FrameXML，一般以 `tinsert(C.defaultThemes, function() ... end)` 註冊。
- 新增、刪除或改名檔案時，同步核對 Lua、XML `<Script>`、TOC 的 XML 入口與 `.pkgmeta` 打包根目錄。

## 審查方法

- 先在目標 build 的 Blizzard UI 原始碼讀 frame／Mixin 的建立、初始化、refresh、Layout、show／hide、pool reset 與事件流程。
- 確認目標在 AuroraClassic 主載入時確實存在；若屬 LoadOnDemand，不應以 nil guard 留在 FrameXML 模組。
- 優先沿用既有 `B` helper；單一模組用途保持 `local`。
- hook 要選在原生完成更新後的最小範圍。`hooksecurefunc` 與 `HookScript` 不可取代原有行為，`SetScript` 覆寫前需確認 Mixin 契約。
- ScrollBox、frame pool 與資料重綁元件必須可重複套皮膚；background、border、texture、script 與 hook 不得累積。
- Texture 的 atlas、texcoord、vertex color、desaturation 或 alpha 若會被原生 refresh 重設，只 hook 精確更新點，不建立無界限 `OnUpdate`。
- anchor、parent、frame level／strata、scale 與尺寸變更要檢查 Layout 回寫、錨點循環、遮擋與滑鼠區域。

## 驗證矩陣

- 登入後首次套用。
- `/reload`。
- frame 關閉後重開。
- ScrollBox 捲出／捲入與 pool element reset／reuse。
- 設定變更後已存在與之後建立的 frame。
- protected／secure 元件在戰鬥中開啟、刷新與離開戰鬥後狀態。
- secret value 相關 widget 在會啟用限制的正式服場景。

## 2026-08-11 全量審查結論

- 已逐檔閱讀 58/58 Lua；`FrameXML.xml` 的 58 個 Script 與實際檔案完全相符。
- 12.1 確定硬斷點：`ChatFrame.lua` 的 `BattleTagInviteFrame` 已移除；`Fonts.lua` 的固定 RaidWarning slots／`RaidBossEmoteFrame` 已改成動態 pool。
- 全量審查時確認 `AlertFrames.lua` 的 `hooked`／`hookded` marker typo 令 pooled alerts 重複掛 hook；已於下方 2026-08-12 修正。
- 全量審查當時確認的覆蓋缺口：12.1 SocialUI、Chat Config Additional Colors，以及既有 `InitiativeTasksObjectiveTracker`；三者已於 2026-08-12 完成下述靜態修正。
- 全量審查時確認 Voice notification GUID/class 是 chat messaging lockdown secret 風險；本輪 blocker 修正已加靜態 guard，正式服驗證仍待完成。動態 HookScript 另受 12.1 ScriptBindings 新契約影響。
- ColorPicker、Splash、UIWidgets 的搬移目前保留 Aurora 所用結構；EquipmentFlyout width 疑點已由原生 lifecycle 排除，ObjectiveTracker 則確認 `Bar.Icon` 是 optional 且 Aurora guard 正確。
- 尚未進行正式服遊戲內全模組測試；完整矩陣見總報告。

## 2026-08-12 12.1 live 重核

- 以 WoWUI live `b3733541`（12.1.0.69273）重核後，`BattleTagInviteFrame` 移除及 RaidWarning 動態 `fontStringPool` 兩個 P1 均仍成立；`RaidBossEmoteFrame` 公開 global 仍不存在。
- 最後 PTR → live 沒有修改上述兩個 blocker 的 source，故沒有撤回或降級。
- 12.1 的好友邀請替代物件是 `Blizzard_AddFriend/AddFriendTemplates.xml` 的 `BattleNetInviteFrame`；既有 `AddFriendFrame` global 仍保留且 Aurora 已有 skin。BattleNetInvite 與獨立 SocialUI skin 都已新增；既有 AddFriend 正式服回歸仍待完成，不能把三者誤寫成同一個全新功能。
- SocialUI 正式版在 `Blizzard_SocialUIShared/SocialUISharedTemplates.xml`／`.lua` 改為搜尋文字每次 `OnTextChanged` 即時 refresh、`OnHide` 清除文字，filter mixin 為 `SocialUISearchFilterDropdownMixin`。`SocialUIFrame` 的 tabs/content 又由 pool 動態 ReleaseAll/Acquire；現行 skin 已冪等處理 pool，且未覆寫 `OnTextChanged`、`OnHide`、`InitializeFilterBar` 或 `GenerateFilterMenu`。逐字輸入、filter、BN 斷線、header collapse 與關閉重開仍待正式服驗證。
- ChatConfig Additional Colors 的現有 swatches 已會進 Aurora 通用 swatch hook；`ChatConfigOtherSettingsAdditionalColors` 外層原生 backdrop box art 也已納入 strip。
- `InitiativeTasksObjectiveTracker` 與 voice GUID secret 註記在 12.0.7 已存在，分別屬既有覆蓋缺口與既有 12.x secret 契約，不是 12.1 新增。兩項現均已完成靜態修正；Initiative tracker 目前只顯示文字 objective，progress/timer hook 是沿用 base mixin 的完整 lifecycle／未來相容。
- ObjectiveTracker 原生 `GetProgressBar` 保證的是 `progressBar.Bar`；`Bar.Icon` 仍是 optional，Aurora 現有 `if icon` 防護正確。舊文件中「保證 `bar.Icon`」的描述已更正。
- 12.1 `HookScript` 雖回傳 success bool，但 `RequiresAssignableScript` 的 failure mode 是 Error；實作不能只靠檢查回傳值，仍須在正式服對精確 frame／forbidden aspect 驗證。
- QueueStatus 正式版新增 `LE_LFG_CATEGORY_LAIR` 名稱路徑；Aurora `GameTooltip.lua` 只把 `QueueStatusFrame` 納入外框處理，沒有讀 category，靜態上不受影響。

## 2026-08-12 blocker 修正

- `ChatFrame.lua` 已移除 `BattleTagInviteFrame`，改用 live `BattleNetInviteFrame.Border`、`.SendButton`、`.CancelButton`；`Blizzard_AddFriend` 是主載入 addon，未以 nil guard 掩蓋載入契約。
- ChatFrame theme 後段重新可達後，voice notification hook 會先檢查 chat messaging lockdown、GUID 與 class 的可存取性；restricted 時不解析 secret data，沿用 Blizzard 已恢復的原生 channel color。
- `Fonts.lua` 已移除固定 RaidWarning slots 與 `RaidBossEmoteFrame` global，改在 `RaidWarningFrame` 與 `CinematicFrame.BossEmoteFrame` 的 `AcquireString` 後枚舉 active `fontStringPool`。
- 每個 pool FontString 只初始化一次 Aurora font／outline／shadow，FontScale 使用 live 公開 `FontString:SetTextScale()`；不讀寫 FadingFrame 的 `textScaling*`、message order 或其他內部欄位。pool reset 不清 marker 或 text scale，因此 reuse 不會累乘。
- `FrameXML.xml` 無需修改；舊符號精確搜尋無殘留且 `git diff --check` 通過。尚待正式服驗證 ChatFrame theme 後半、Battle.net 邀請、`/rw`、一般／cinematic boss emote、pool reuse 與 `FontScale != 1`。

## 2026-08-12 核心缺陷修正

- `AlertFrames.lua` 的 `hooked`／`hookded` typo 已改成一致且專用的 `frame.__auroraAnimHooked`。LootWon／MoneyWon setup、`AddAlertFrame` 與 frame pool reuse 都會共用同一 marker，不再重複掛 OnEnter／OnShow／animation hooks。
- `ChatBubbles.lua` 已在 default theme callback 最前面讀取 `AuroraClassicDB.ChatBubbles`。設定為 false 並 reload 時，不會建立 bubbleHook、註冊聊天事件或安裝 OnEvent／OnUpdate；true 時維持原 skin lifecycle。
- 兩檔仍由既有 `FrameXML.xml` 載入，不需修改 XML。尚待正式服驗證 alert release／reacquire，以及 ChatBubbles false／true 各一次 reload 後的 say／yell／party bubble。

## 2026-08-12 Initiative Tasks 外觀修正

- `ObjectiveTracker.lua` 已將 live 固定 global `InitiativeTasksObjectiveTracker` 加入既有 module list，沿用 header、`AddBlock`、`GetProgressBar` 與 `GetTimerBar` 的共用 skin lifecycle。
- live `InitiativeTasksObjectiveTracker` 繼承 `ObjectiveTrackerModuleTemplate`；`AddTask()` 最終會由 base `LayoutBlock()` 走到 `AddBlock()`。目前模組只建立文字 objective，但 progress／timer 仍是同一 base mixin 的有效方法。
- 新增程式不讀 task info、requirements 或 Neighborhood Initiative gameplay data，也不新增 `HookScript`／protected layout 操作。`FrameXML.xml` 無需修改；尚待正式服測 tracker 建立、刷新、收合與 block reuse。

## 2026-08-12 SocialUI／Chat Config 靜態覆蓋

- `FriendsFrame.lua` 新增真實 `Blizzard_SocialUI` theme；主框、Battle.net bar／controls、broadcast／unavailable／ignore／RaidInfo side windows、動態 tabs、Raid content 固定 controls，以及各 content ScrollBox 都按 live lifecycle 處理。tab pool 走 `RefreshTabs` post-hook＋immediate enumerate，card／RaidInfo row pool 走 `OnInitializedFrame` callback＋immediate `ForEachFrame`。self-review 後將兩個 ResizeLayout side-window backdrop 標為 `ignoreInLayout`，避免 Aurora child 進入原生 extents。
- Friends／Recent Allies／Friend Requests／Quick Join／RAF card 只按 frame 結構處理背景、hover／selected 與固定 action buttons；RAF RewardClaiming 與 Friend Requests warning/buttons 也已涵蓋。callback 明確丟棄 `elementData`，不讀 SearchFriends、account、invite 或其他 restricted payload。
- SocialUI 搜尋／filter 的原生 `OnTextChanged`、`OnHide`、`InitializeFilterBar`、`GenerateFilterMenu` 完全未覆寫；system disabled 時既有 legacy FriendsFrame skin 仍保留。
- `ChatConfigOtherSettingsAdditionalColors` 已加入既有 outer backdrop strip 清單；內部 swatches 繼續由原生 `ChatConfig_UpdateSwatches` 完成後的 Aurora hook 處理。
- 靜態載入、callback signature 與 pool reuse 已核對；SocialUI enabled／disabled、逐字搜尋、filter、BN disconnect、header collapse、關閉重開與 legacy AddFriend 回歸仍待正式服驗證。
