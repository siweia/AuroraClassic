# LoadOnDemand AddOns 皮膚記憶

## 範圍與載入契約

- 模組位於 `AuroraClassic/AddOns/`。
- 實際載入清單以 `AuroraClassic/AddOns/AddOns.xml` 為準。
- Blizzard LoadOnDemand addon 以 `C.themes["Blizzard_*"] = function() ... end` 註冊；key 必須由 Blizzard TOC／原始碼確認。
- 同一 Lua 可註冊多個 Blizzard addon key，但每個 key 都要分別核對真實載入名稱與 frame 可用時機。

## 審查方法

- 先讀 Blizzard addon TOC、入口 Lua／XML、目標 Mixin 與 frame 建立流程，不能從 AuroraClassic 檔名猜 addon event 名稱。
- 同時驗證 `B:LoadSkins` 的兩種 LoadOnDemand 時序：AuroraClassic 啟動時 Blizzard addon 已載入，以及之後才收到對應 addon loaded。
- skin function 需能處理該時序下所有必需 frame；條件建立、子功能分拆或其他 Blizzard addon 依賴要有正確註冊點。
- 多次開啟 UI、資料 refresh、ScrollBox／pool reuse 不得重複建立 region、hook 或改壞 reset 狀態。
- 只需移除外觀時，優先處理 Texture／Atlas／alpha；不要用 `B:HideObject()` 破壞仍需更新的原生物件。
- 若 addon 可能在戰鬥中載入或刷新，所有 protected／secure 操作、CVar 與 deferred work 都要按 combat lockdown 審查。
- Blizzard addon 改名、拆分或合併時，同步調整 theme key、Lua、XML 與記憶，不能靠永久 nil guard 吞掉。

## 驗證矩陣

- AuroraClassic 先載入，再首次開啟 Blizzard UI。
- Blizzard addon 已載入後才載入或重載 AuroraClassic。
- 關閉重開與 `/reload`。
- 同一 addon 內不同分頁、子 frame 與條件功能首次建立。
- ScrollBox 捲動、搜尋／篩選、資料切換與 pool reuse。
- 戰鬥中開啟／刷新及離開戰鬥後恢復。
- 多 addon key 模組分別由每個 key 觸發。

## 2026-08-11 全量審查結論

- 初次全量 review 已閱讀當時的 63/63 Lua 與 79 個 theme key。2026-08-12 退休三個 dead module、再新增獨立 HousingBlueprint module 後，當前 `AddOns.xml` 為 61 個 Script／61 個 Lua、76 個 theme key；唯一仍以不存在 MAINLINE addon key 註冊的是待決策的 `Blizzard_Tutorial`。
- 12.1 確定硬斷點：Achievement HeaderDetails/Filters、Delves CompanionSlots、Housing root HouseDropdown、Weekly Rewards ConcessionsFrame。
- Weekly Rewards 的 `WeeklyRewardsFrameNameFrame` 是另一個既有確定錯誤。
- 全量審查當時確認的覆蓋缺口／失效：PVP 新 Arena button 與 CategoryButton5、PlayerChoice BorderOverlay、NewPlayer 舊 global、Transmog PreviewedWeaponToggle、ExpansionLandingPage Dragonriding target、MajorFactionRenown dead target。截至 2026-08-12，這批項目均已修正或退休。
- Communities roster 與 CooldownViewer dispel border 的兩條 secret data-flow 已完成靜態修正；正式服 restricted 場景仍待驗證，Achievement／Auction／Raid 等 secure 路徑與大量 Bootstrap addon 也仍需兩種載入順序及戰鬥內實測。
- 主要 pool／ScrollBox lifecycle 已逐檔核對；除已列項外，未確認另一個必然的 reuse error。

## 2026-08-12 12.1 live 重核

- 以 WoWUI live `b3733541`（12.1.0.69273）重核後，Achievement、Delves、Housing Dashboard、Weekly Rewards 四個 AddOns P1 均仍成立；最後 PTR → live 沒有撤回其結構變更。
- Delves 的 Role／Flavor／Combat／Utility 四個 slot 全部繼承同一個 `CompanionConfigSlotTemplate`，live source 確認每個 slot 都有 `OptionsList.ScrollBox`；migration 可一致處理四個 slot，再依內容決定是否 skin pooled option button。
- Weekly Rewards 的 live `ConcessionsFrame.Rewards` 已由原生 children/layout 管理兩個 concession；修正宜枚舉 children 並處理各自 `RewardsFrame.Text`，不再把數量 2 寫死。
- PVP Training Grounds live 以 `BonusTrainingGroundButtons` parent array 管理普通與 Arena button；Aurora 已於 12.1 新 UI 批次改為枚舉該 array。`CategoryButton5`、PlayerChoice `BorderOverlay`、NewPlayer 舊 globals、Transmog `PreviewedWeaponToggle` 都早在 12.0.7 已存在，維持「既有缺口」分類，並已於 2026-08-12 完成靜態修正。
- HousingBlueprint 是獨立 `LoadOnDemand` addon；現已使用真實 `C.themes["Blizzard_HousingBlueprint"]` 與對應 AddOns XML 模組，不依賴 HousingDashboard 載入時順便處理。
- 正式版 HousingBlueprint 的 import input／validation 各有一個 `GearDropdown`，ContentSummary 會在 loading／error／empty/content 狀態間改 `fixedHeight`、`minimumHeight` 與 child visibility。現行 skin 保留原生 Layout/MarkDirty lifecycle；兩個 dropdown 的 enabled/disabled 與所有內容狀態仍待正式服驗證。
- HousingBlueprint `ContentBudgets` 內部使用 pool；live 已移除 `SetInfo()` 自行 Show，統一由 `ContentSummary:UpdateContentVisibility()` 控制。現行 skin 不 force-show budgets 或 content children，並對 pooled budget entries 做冪等處理。
- WoWUI live `Blizzard_HousingDashboardInitiatives.lua:177` 本身仍呼叫已移除的 `HousingDashboardFrame.HouseInfoContent.HouseDropdown`，而 XML 只建立 root `HousingDashboardFrame.HouseDropdown`。這是上游 source 的 stale HelpTip anchor，不應複製進 Aurora；正式服測 Initiatives 首次顯示時需把原生錯誤與 Aurora theme 錯誤分開記錄。
- `Blizzard_TalentUI` 與 `Blizzard_VoidStorageUI` 已退休；`Blizzard_Tutorial` key 仍不存在，但其舊 skin 目標屬於有效的 `Blizzard_BoostTutorial`。若保留 boosted-character 教學皮膚，需改用真實 key 並按現行 `PortraitFrameTemplate` 重寫；不能只 re-key，因舊 `TitleBg`／root `.portrait` 路徑已失效。
- `B.SetCurrenciesHook` 藏在 Runeforge 模組仍是架構耦合，但不是「只有現行 XML 執行順序才會存在」的 runtime bug：所有 Script 在 theme closure 執行前已載入。移動／刪除 Runeforge 模組時仍必須同步處理 Azerite caller。
- CooldownViewer restricted-aura、Communities roster、GMChat deprecated alias、ExpansionLandingPage no-op、MajorFaction dead target 與 delayed theme 清錯 key 都在最後 12.0.7 已存在，不能標成 12.1 新增；這些項目現均已完成靜態修正或 dead module 退休。
- 12.1 Communities 的 Discord stream／`discordInfo`／`SendTitleFriendRequest` 變更只修改既有 chat／stream 資料與 API 路徑，live XML 沒有新增獨立 widget/template；既有 skin 自然承接，Aurora 不新增 member／Discord payload consumer。

## 2026-08-12 blocker 修正

- `Blizzard_AchievementUI.lua` 已改用 `AchievementFrame.HeaderDetails.Filters` 下的 FilterDropdown／SearchBox 與 `SearchBox.SearchPreviewContainer`；刪除舊 anchor 覆寫，保留 HorizontalLayout 與 comparison mode 的原生定位。
- `Blizzard_Delves.lua` 已改走 `CompanionSlots`，涵蓋 Role／Flavor／Combat／Utility 四個 slot；每個 ScrollBox 同時處理現存與之後更新的 active frame。atlas branch 以公開 `ResetTexCoord()` 清除 pooled texture row 的 Aurora crop，texture branch 再套回 `DB.TexCoord`；Aurora backdrop 可在 reuse 時隱藏／恢復而不重建。
- `Blizzard_HousingDashboard.lua` 已改用 `HousingDashboardFrame.HouseDropdown.Dropdown`；root `HouseDropdown` 是 lifecycle 容器，內層 `.Dropdown` 才是 `WowStyle1DropdownTemplate`。Collection／Initiatives／獨立 Blueprint 覆蓋也已於後續 12.1 新 UI 批次完成靜態實作。
- `Blizzard_WeeklyRewards.lua` 已枚舉 `ConcessionsFrame.Rewards:GetChildren()` 並冪等處理每個 `RewardsFrame.Text`；不存在的 `WeeklyRewardsFrameNameFrame` 已改為 `confirmFrame.ItemFrame.NameFrame`。
- `AddOns.xml`、theme key 與 Blizzard TOC 載入契約無需修改；舊路徑精確搜尋無殘留且 `git diff --check` 通過。尚待正式服驗證 Achievement normal／comparison、Brann 四 slot 與 pool reuse、Housing dashboard、Great Vault concession 與選獎確認框。

## 2026-08-12 SECRET SAFE 修正

- `Blizzard_CooldownViewer.lua` 已移除 `GetAuraDispelTypeColor`、color curve 與自訂 per-aura border hook；Aurora 固定黑邊仍在，dispellable／harmful 外圈交回 Blizzard 原生 `DebuffBorder`。
- `Blizzard_Communities.lua` roster 已移除 `GetMemberInfo()`／`classID`／class table lookup，只同步 Blizzard 原生 `Class` widget；`IsShown()` 先經 `B:NotSecretValue`，secret shown state 時隱藏可選 Aurora 外框。
- ApplicantList 的 classID post-hook 雖非目前已確認 secret source，但原生 initializer 已設定 texcoord，因此一併刪除重複資料解析，只在 pooled button 首次 skin 時建立外框。
- 詳細資料流、版本邊界、實作取捨與正式服測試矩陣見 `2026-08-12-secret-safe-cooldownviewer-communities.md`。

## 2026-08-12 GMChat lifecycle 修正

- `Blizzard_GMChatUI.lua` 已停止 hook 只有 deprecated alias 的 `ChatEdit_ActivateChat`／`ChatEdit_DeactivateChat`，改為 live canonical `ChatFrameUtil.ActivateChat`／`DeactivateChat` table hooks。
- 兩個 callback 都精確比對 `editBox == GMChatFrameEditBox`，不再依一般 chat editbox 也可能具有的資料欄位判斷。
- hook 安裝後會立即比對 `ChatFrameUtil.GetActiveWindow()`，同步 Blizzard addon 已載入且 GM editbox 已 active 的時序；不必等下一次 focus 切換才修正背景。
- WoWUI live 12.1.0.69273 的兩個方法都是單一 `editBox` 參數；GM OnLoad、focus gained／lost 與切換 active chat 都走 canonical table method。完整 `Blizzard_GMChatUI` ADDON_LOADED 時 ChatFrameUtil 已存在，不需 nil guard 或 XML 變更。
- 尚待正式服以 GM 對話實際驗證 editbox focus、失焦、切換其他 chat 與關閉重開時 Aurora 背景 show／hide。

## 2026-08-12 既有外觀漏項修正

- `Blizzard_PVPUI.lua` 的 category skin 與選取背景已改枚舉 live `PVPQueueFrame.CategoryButtons`，因此包含既有 `CategoryButton5`；12.1 Training Ground Arena button 亦已在後續新 UI 批次完成。
- `Blizzard_PlayerChoice.lua` 首次 skin 時同時隱藏 `NineSlice` 與新式 texture kit 使用的固定 `BorderOverlay`；原生後續只更新 shown／atlas／point，不會重建或重設 alpha。
- `Blizzard_NewPlayerExperienceGuide.lua` 已改用 `TutorialWalk_Frame`、`STRAFELEFT`／`STRAFERIGHT` 與 `TutorialSingleKey_Frame`。完整 `Blizzard_NewPlayerExperience` 載入時 XML／RequiredDep 已建立這些 globals，theme 不再以舊 guard 靜默略過。
- `Blizzard_Transmog.lua` 已把固定 `PreviewedWeaponToggle.Checkbox` 納入相鄰 toggle 的 checkbox skin；該 widget 非 pool，checked／shown lifecycle 仍由 Blizzard 管理。
- `Blizzard_ExpansionLandingPage.lua` 已停止掃描不存在的 Dragonriding child，改在 `RefreshExpansionOverlay` 後使用 `self.overlayFrame`，並以 Midnight template 固定的 `RunesOfPowerFrame` 辨識目標。immediate call 覆蓋 already-created overlay，post-hook 覆蓋之後建立；只處理外層 Background／Border／backdrop／CloseButton，不碰 trait tree 或 gameplay data。
- `Blizzard_EncounterJournal.lua` 的 Journeys 已移除固定 `QuestLogBorderFrameTemplate` 裝飾材質，並在異質 `JourneysList` pool 中只依 `WatchedFactionToggleFrame` 結構冪等 skin `WatchFactionCheckbox`。immediate `ForEachFrame` 補既有 active rows，`Update` post-hook 處理後續 acquire／reuse。
- AddOns XML、theme key 與 TOC 無需修改。尚待正式服測 PVP 第五 category、PlayerChoice texture-kit 切換、新手教學、Transmog toggle、Midnight overlay 首次／重開，以及 Journeys 捲動、hover checkbox 與 pool reuse。

## 2026-08-12 dead theme／target 清理

- `Blizzard_Delves.lua` 只移除不存在的 `C.themes["Blizzard_DelvesDashboardUI"]` closure；保留同檔有效的 Companion Configuration／Difficulty Picker themes 與 `AddOns.xml` Script。
- `Blizzard_TalentUI.lua` 與 `Blizzard_VoidStorageUI.lua` 已整檔刪除並同步移除 XML Script。WoWUI live 69273 沒有 MAINLINE `Blizzard_TalentUI`（只有 Mists/Cata source，MAINLINE 使用 PlayerSpells），也沒有 VoidStorageUI；兩檔未輸出跨檔 helper。
- `Blizzard_MajorFactions` addon key 本身仍有效，但 Aurora 唯一目標 `MajorFactionRenownFrame` 已不存在，因此 `Blizzard_MajorFactions.lua` 與 XML Script 已刪除。MajorFaction interaction 現由 Blizzard Bootstrap 導向 EncounterJournal Journeys；Aurora 的 EncounterJournal root、Journeys Border／scroll／buttons／pooled watch checkbox 已承接原外觀責任。
- 清理完成當下 AddOns 載入契約為 60 個 Script／60 個 Lua、75 個 theme key；之後新增獨立 HousingBlueprint module，現況為 61／61／76。Lua、XML、被移除 key／global 與跨檔 helper 搜尋均已核對。這不表示所有 Journey card／reward track 細節都已全面換皮，只有確認刪除舊 module 不會造成外觀責任回歸。

## 2026-08-12 12.1 新 UI 靜態覆蓋

- `Blizzard_HousingDashboard.lua` 已補 Collection scrollbar／details GearDropdown／ContentSummary，以及 Initiatives 兩個 scrollbar、切換按鈕與動態 HouseInfo tabs。tab skin 在 `UpdateTabs` 後冪等執行，保留原生 available／enabled／selected lifecycle。
- 新增 `Blizzard_HousingBlueprint.lua` 與 AddOns XML Script，使用真實 `Blizzard_HousingBlueprint` LoD key。Import／Validation buttons、兩個 GearDropdown、share-code input 外觀、ContentSummary 與 pooled budget icons 均已涵蓋；self-review 已將 budget lifecycle 從 mixin table hook 改為 Validation／Dashboard 兩個具體 `BudgetsContainer:SetInfo` instance hook＋immediate scan。不讀 share code／budget data、不 force-show children，也不改 `fixedHeight`、`minimumHeight` 或 MarkDirty。Import root 的 Aurora backdrop 標為 `ignoreInLayout`，不進入 ResizeLayout extents。
- `Blizzard_CooldownViewer.lua` 已補 GroupBuffFilter scrollbar／section item pools、兩個 alert editor 與 shared dragged-item preview。Group header 在 strip 前保存初始 atlas，避免首次顯示遺失展開箭頭；不讀 aura／alert gameplay payload。drag singleton 正常延後建立時由 Mixin post-hook處理；若它在 Aurora theme 前已存在，Blizzard 沒有公開安全 lookup，刻意不遍歷帶 Hierarchy secret aspect 的 UI tree，需 `/reload` 恢復此外觀 edge case。正式服 secure drag 待驗證。
- `Blizzard_PVPUI.lua` 已枚舉 live `BonusTrainingGroundButtons` parent array，因此普通與 Arena Training Ground button 共用同一 skin。
- `Blizzard_GuildControlUI.lua` 已處理固定 Discord server／channel controls，並在全域 `GuildControlUI_Discord_Update` 與非會長載入時已快取的 `GuildControlUI.rankUpdate` 後冪等處理動態 linked／unlinked frames；不呼叫或解析 Discord API/data。
- Communities live source 沒有對上述 Discord／friend-request diff 新增可獨立 skin 的 frame。此項不新增 runtime code，避免把資料層變更誤當 UI 結構。

## 2026-08-12 正式服 O 鍵／Guild rank lifecycle 修正

- 正式服實測 `C_AddOns.LoadAddOn("Blizzard_SocialUI")` 成功，但 `C_SocialUI.IsSystemEnabled()`／`SocialUIControl.IsEnabled()` 為 false；live source 並未移除新版 UI，目前是 runtime feature gate 關閉，因此 `O` 走 legacy `FriendsFrame`。新版 SocialUI skin 保留為 dormant 路徑，可見 UI、動態分頁與 side-window 正式服測試待 Blizzard 重新啟用。
- legacy `FriendsFrame_OnShow()` 會呼叫 `C_GuildInfo.GuildRoster()`。GuildControl addon 一旦已載入，Aurora 原本自建的 `GUILD_RANKS_UPDATE` frame 便會跨分頁執行 `updateGuildRanks()`；Blizzard XML 只靜態建立 Rank1，Rank2+ 僅由 `GuildControlUI_RankOrder_Update()` 動態建立，因此舊 helper 對不存在 row 的 `rank.styled` 索引造成正式服 hard error。
- 修正後不再監聽 guild-data event，也不再用 `GuildControlGetNumRanks()` 推定 frame lifecycle；只 post-hook 原生 RankOrder updater，依 `orderFrame` 的固定命名掃描已建立的連續 rows，遇第一個 nil 即停止，並在 theme 安裝後 immediate 掃一次以涵蓋 already-loaded rows。Rank rows 非 pool／secure template，使用專用 marker 冪等處理；不讀 rank payload，也不使用帶 Hierarchy secret aspect 的 child traversal。
- 正式服待重測：非會長／一般成員冷登入與 `/reload` 後反覆按 `O`、先開 Communities 再按 `O`；會長開 Guild Control 的 Rank Order，新增／刪除／上下移 rank並切換 Permissions／Bank／Discord；確認無 Lua error且既有／新建 rows 均套皮。
