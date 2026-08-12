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

- 初次全量 review 已閱讀當時的 63/63 Lua 與 79 個 theme key。2026-08-12 退休三個 dead module 後，當前 `AddOns.xml` 為 60 個 Script／60 個 Lua、75 個 theme key；唯一仍以不存在 MAINLINE addon key 註冊的是待決策的 `Blizzard_Tutorial`。
- 12.1 確定硬斷點：Achievement HeaderDetails/Filters、Delves CompanionSlots、Housing root HouseDropdown、Weekly Rewards ConcessionsFrame。
- Weekly Rewards 的 `WeeklyRewardsFrameNameFrame` 是另一個既有確定錯誤。
- 全量審查當時確認的覆蓋缺口／失效：PVP 新 Arena button 與 CategoryButton5、PlayerChoice BorderOverlay、NewPlayer 舊 global、Transmog PreviewedWeaponToggle、ExpansionLandingPage Dragonriding target、MajorFactionRenown dead target。截至 2026-08-12，除 Arena button 外，其餘項目均已修正或退休。
- Communities roster 與 CooldownViewer dispel border 的兩條 secret data-flow 已完成靜態修正；正式服 restricted 場景仍待驗證，Achievement／Auction／Raid 等 secure 路徑與大量 Bootstrap addon 也仍需兩種載入順序及戰鬥內實測。
- 主要 pool／ScrollBox lifecycle 已逐檔核對；除已列項外，未確認另一個必然的 reuse error。

## 2026-08-12 12.1 live 重核

- 以 WoWUI live `b3733541`（12.1.0.69273）重核後，Achievement、Delves、Housing Dashboard、Weekly Rewards 四個 AddOns P1 均仍成立；最後 PTR → live 沒有撤回其結構變更。
- Delves 的 Role／Flavor／Combat／Utility 四個 slot 全部繼承同一個 `CompanionConfigSlotTemplate`，live source 確認每個 slot 都有 `OptionsList.ScrollBox`；migration 可一致處理四個 slot，再依內容決定是否 skin pooled option button。
- Weekly Rewards 的 live `ConcessionsFrame.Rewards` 已由原生 children/layout 管理兩個 concession；修正宜枚舉 children 並處理各自 `RewardsFrame.Text`，不再把數量 2 寫死。
- PVP Training Grounds live 以 `BonusTrainingGroundButtons` parent array 管理普通與 Arena button；Aurora 仍應在 12.1 新 UI 批次枚舉該 array。`CategoryButton5`、PlayerChoice `BorderOverlay`、NewPlayer 舊 globals、Transmog `PreviewedWeaponToggle` 都早在 12.0.7 已存在，維持「既有缺口」分類，並已於 2026-08-12 完成靜態修正。
- HousingBlueprint 是獨立 `LoadOnDemand` addon；若補完整覆蓋，應新增真實 `C.themes["Blizzard_HousingBlueprint"]` 註冊與對應 AddOns XML 模組，不依賴 HousingDashboard 載入時順便處理。
- 正式版 HousingBlueprint 的 import input／validation 各有一個 `GearDropdown`，ContentSummary 會在 loading／error／empty/content 狀態間改 `fixedHeight`、`minimumHeight` 與 child visibility。skin 必須保留原生 Layout/MarkDirty lifecycle，測兩個 dropdown 的 enabled/disabled 與所有內容狀態。
- HousingBlueprint `ContentBudgets` 內部使用 pool；live 已移除 `SetInfo()` 自行 Show，統一由 `ContentSummary:UpdateContentVisibility()` 控制。future skin 不可 force-show budgets 或 content children，並須對 pooled budget entries 做冪等處理。
- WoWUI live `Blizzard_HousingDashboardInitiatives.lua:177` 本身仍呼叫已移除的 `HousingDashboardFrame.HouseInfoContent.HouseDropdown`，而 XML 只建立 root `HousingDashboardFrame.HouseDropdown`。這是上游 source 的 stale HelpTip anchor，不應複製進 Aurora；正式服測 Initiatives 首次顯示時需把原生錯誤與 Aurora theme 錯誤分開記錄。
- `Blizzard_TalentUI` 與 `Blizzard_VoidStorageUI` 已退休；`Blizzard_Tutorial` key 仍不存在，但其舊 skin 目標屬於有效的 `Blizzard_BoostTutorial`。若保留 boosted-character 教學皮膚，需改用真實 key 並按現行 `PortraitFrameTemplate` 重寫；不能只 re-key，因舊 `TitleBg`／root `.portrait` 路徑已失效。
- `B.SetCurrenciesHook` 藏在 Runeforge 模組仍是架構耦合，但不是「只有現行 XML 執行順序才會存在」的 runtime bug：所有 Script 在 theme closure 執行前已載入。移動／刪除 Runeforge 模組時仍必須同步處理 Azerite caller。
- CooldownViewer restricted-aura、Communities roster、GMChat deprecated alias、ExpansionLandingPage no-op、MajorFaction dead target 與 delayed theme 清錯 key 都在最後 12.0.7 已存在，不能標成 12.1 新增；這些項目現均已完成靜態修正或 dead module 退休。
- 12.1 Communities 新增 Discord stream／`discordInfo`／`SendTitleFriendRequest` 等 surface；補 skin 時仍只使用公開 frame/region state，不把新 coverage 變成另一條 member payload 解析路徑。

## 2026-08-12 blocker 修正

- `Blizzard_AchievementUI.lua` 已改用 `AchievementFrame.HeaderDetails.Filters` 下的 FilterDropdown／SearchBox 與 `SearchBox.SearchPreviewContainer`；刪除舊 anchor 覆寫，保留 HorizontalLayout 與 comparison mode 的原生定位。
- `Blizzard_Delves.lua` 已改走 `CompanionSlots`，涵蓋 Role／Flavor／Combat／Utility 四個 slot；每個 ScrollBox 同時處理現存與之後更新的 active frame。atlas branch 以公開 `ResetTexCoord()` 清除 pooled texture row 的 Aurora crop，texture branch 再套回 `DB.TexCoord`；Aurora backdrop 可在 reuse 時隱藏／恢復而不重建。
- `Blizzard_HousingDashboard.lua` 已改用 `HousingDashboardFrame.HouseDropdown.Dropdown`；root `HouseDropdown` 是 lifecycle 容器，內層 `.Dropdown` 才是 `WowStyle1DropdownTemplate`。Collection／Initiatives／Blueprint 完整覆蓋仍留在後續工作。
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

- `Blizzard_PVPUI.lua` 的 category skin 與選取背景已改枚舉 live `PVPQueueFrame.CategoryButtons`，因此包含既有 `CategoryButton5`；這不等於 12.1 Training Ground Arena button 已完成，後者仍在新 UI 待辦。
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
- 清理後 AddOns 載入契約為 60 個 Script／60 個 Lua、75 個 theme key；Lua、XML、被移除 key／global 與跨檔 helper 搜尋均已核對。這不表示所有 Journey card／reward track 細節都已全面換皮，只有確認刪除舊 module 不會造成外觀責任回歸。
