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

- 已逐檔閱讀 63/63 Lua；`AddOns.xml` 的 63 個 Script 與實際檔案完全相符。
- 79 個 AddOns theme key 已逐項核對。MAINLINE 不存在：`Blizzard_DelvesDashboardUI`、`Blizzard_TalentUI`、`Blizzard_Tutorial`、`Blizzard_VoidStorageUI`。
- 12.1 確定硬斷點：Achievement HeaderDetails/Filters、Delves CompanionSlots、Housing root HouseDropdown、Weekly Rewards ConcessionsFrame。
- Weekly Rewards 的 `WeeklyRewardsFrameNameFrame` 是另一個既有確定錯誤。
- 確定覆蓋缺口／失效：PVP 新 Arena button 與 CategoryButton5、PlayerChoice BorderOverlay、NewPlayer 舊 global、Transmog PreviewedWeaponToggle、ExpansionLandingPage Dragonriding target、MajorFactionRenown dead target。
- Communities、CooldownViewer 具有 secret data-flow 風險；Achievement／Auction／Raid 等 secure 路徑與大量 Bootstrap addon 仍需兩種載入順序及戰鬥內實測。
- 主要 pool／ScrollBox lifecycle 已逐檔核對；除已列項外，未確認另一個必然的 reuse error。

## 2026-08-12 12.1 live 重核

- 以 WoWUI live `b3733541`（12.1.0.69273）重核後，Achievement、Delves、Housing Dashboard、Weekly Rewards 四個 AddOns P1 均仍成立；最後 PTR → live 沒有撤回其結構變更。
- Delves 的 Role／Flavor／Combat／Utility 四個 slot 全部繼承同一個 `CompanionConfigSlotTemplate`，live source 確認每個 slot 都有 `OptionsList.ScrollBox`；migration 可一致處理四個 slot，再依內容決定是否 skin pooled option button。
- Weekly Rewards 的 live `ConcessionsFrame.Rewards` 已由原生 children/layout 管理兩個 concession；修正宜枚舉 children 並處理各自 `RewardsFrame.Text`，不再把數量 2 寫死。
- PVP Training Grounds live 以 `BonusTrainingGroundButtons` parent array 管理普通與 Arena button；Aurora 應枚舉該 array。`CategoryButton5`、PlayerChoice `BorderOverlay`、NewPlayer 舊 globals、Transmog `PreviewedWeaponToggle` 都早在 12.0.7 已存在，維持「既有缺口」分類。
- HousingBlueprint 是獨立 `LoadOnDemand` addon；若補完整覆蓋，應新增真實 `C.themes["Blizzard_HousingBlueprint"]` 註冊與對應 AddOns XML 模組，不依賴 HousingDashboard 載入時順便處理。
- 正式版 HousingBlueprint 的 import input／validation 各有一個 `GearDropdown`，ContentSummary 會在 loading／error／empty/content 狀態間改 `fixedHeight`、`minimumHeight` 與 child visibility。skin 必須保留原生 Layout/MarkDirty lifecycle，測兩個 dropdown 的 enabled/disabled 與所有內容狀態。
- HousingBlueprint `ContentBudgets` 內部使用 pool；live 已移除 `SetInfo()` 自行 Show，統一由 `ContentSummary:UpdateContentVisibility()` 控制。future skin 不可 force-show budgets 或 content children，並須對 pooled budget entries 做冪等處理。
- WoWUI live `Blizzard_HousingDashboardInitiatives.lua:177` 本身仍呼叫已移除的 `HousingDashboardFrame.HouseInfoContent.HouseDropdown`，而 XML 只建立 root `HousingDashboardFrame.HouseDropdown`。這是上游 source 的 stale HelpTip anchor，不應複製進 Aurora；正式服測 Initiatives 首次顯示時需把原生錯誤與 Aurora theme 錯誤分開記錄。
- `Blizzard_Tutorial` key 確實不存在，但其舊 skin 目標屬於仍有效的 `Blizzard_BoostTutorial`。若保留 boosted-character 教學皮膚，需改用真實 key 並按現行 `PortraitFrameTemplate` 重寫；不能把它與 `Blizzard_TalentUI`、`Blizzard_VoidStorageUI` 一起直接退休，也不能只 re-key，因舊 `TitleBg`／root `.portrait` 路徑已失效。
- `B.SetCurrenciesHook` 藏在 Runeforge 模組仍是架構耦合，但不是「只有現行 XML 執行順序才會存在」的 runtime bug：所有 Script 在 theme closure 執行前已載入。移動／刪除 Runeforge 模組時仍必須同步處理 Azerite caller。
- CooldownViewer restricted-aura、Communities roster、GMChat deprecated alias、ExpansionLandingPage no-op、MajorFaction dead target 與 delayed theme 清錯 key 都在最後 12.0.7 已存在；12.1 migration 需一併修／驗證，但不能標成 12.1 新增。
- 12.1 Communities 新增 Discord stream／`discordInfo`／`SendTitleFriendRequest` 等 surface；補 skin 時仍只使用公開 frame/region state，不把新 coverage 變成另一條 member payload 解析路徑。
