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
