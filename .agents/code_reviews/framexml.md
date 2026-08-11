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
- 確定既有問題：`AlertFrames.lua` 的 `hooked`／`hookded` marker typo 令 pooled alerts 重複掛 hook。
- 確定覆蓋缺口：12.1 SocialUI、Chat Config Additional Colors，以及既有 `InitiativeTasksObjectiveTracker`。
- Voice notification GUID/class 是 chat messaging lockdown secret 風險；動態 HookScript 另受 12.1 ScriptBindings 新契約影響。
- ColorPicker、Splash、UIWidgets 的搬移目前保留 Aurora 所用結構；EquipmentFlyout width 疑點已由原生 lifecycle 排除，ObjectiveTracker 則確認 `Bar.Icon` 是 optional 且 Aurora guard 正確。
- 尚未進行正式服遊戲內全模組測試；完整矩陣見總報告。

## 2026-08-12 12.1 live 重核

- 以 WoWUI live `b3733541`（12.1.0.69273）重核後，`BattleTagInviteFrame` 移除及 RaidWarning 動態 `fontStringPool` 兩個 P1 均仍成立；`RaidBossEmoteFrame` 公開 global 仍不存在。
- 最後 PTR → live 沒有修改上述兩個 blocker 的 source，故沒有撤回或降級。
- 12.1 的好友邀請替代物件是 `Blizzard_AddFriend/AddFriendTemplates.xml` 的 `BattleNetInviteFrame`；既有 `AddFriendFrame` global 仍保留，且 Aurora `FriendsFrame.lua:149-160` 已有 skin。migration 應新增 BattleNetInvite skin、回歸既有 AddFriend，不把兩者都誤寫成全新功能。
- SocialUI 正式版在 `Blizzard_SocialUIShared/SocialUISharedTemplates.xml`／`.lua` 改為搜尋文字每次 `OnTextChanged` 即時 refresh、`OnHide` 清除文字，filter mixin 為 `SocialUISearchFilterDropdownMixin`。`SocialUIFrame` 的 tabs/content 又由 pool 動態 ReleaseAll/Acquire；新增 skin 必須冪等處理 pool，且不得覆寫 `OnTextChanged`、`OnHide`、`InitializeFilterBar` 或 `GenerateFilterMenu`。需測逐字輸入、filter、BN 斷線、header collapse 與關閉重開。
- ChatConfig Additional Colors 的現有 swatches 已會進 Aurora 通用 swatch hook；缺口精確是 `ChatConfigOtherSettingsAdditionalColors` 外層原生 backdrop box art。
- `InitiativeTasksObjectiveTracker` 與 voice GUID secret 註記在 12.0.7 已存在，分別屬既有覆蓋缺口與既有 12.x secret 風險，不是 12.1 新增。現行 Initiative tracker 只顯示文字 objective，當前可見缺口主要是 header；progress/timer hook 屬完整 lifecycle／未來相容。
- ObjectiveTracker 原生 `GetProgressBar` 保證的是 `progressBar.Bar`；`Bar.Icon` 仍是 optional，Aurora 現有 `if icon` 防護正確。舊文件中「保證 `bar.Icon`」的描述已更正。
- 12.1 `HookScript` 雖回傳 success bool，但 `RequiresAssignableScript` 的 failure mode 是 Error；實作不能只靠檢查回傳值，仍須在正式服對精確 frame／forbidden aspect 驗證。
- QueueStatus 正式版新增 `LE_LFG_CATEGORY_LAIR` 名稱路徑；Aurora `GameTooltip.lua` 只把 `QueueStatusFrame` 納入外框處理，沒有讀 category，靜態上不受影響。
