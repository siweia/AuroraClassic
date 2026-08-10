# Init／Core／共用 Helper 記憶

## 範圍

- `AuroraClassic/Init.lua`
- `AuroraClassic/Core.lua`
- `AuroraClassic/AuroraClassic.toc`
- 所有 `B.*` 共用 helper 的 caller

## 已知結構（2026-08-11）

- namespace 由 `Init.lua` 建立，慣例為 `local B, C, L, DB = unpack(ns)`。
- `B:LoadSkins` 會處理主插件載入時的 `C.defaultThemes`，也會處理 Blizzard addon 已載入與之後才載入的 `C.themes`。
- 頂層 Lua 既定順序是 `Init.lua`、`Config.lua`、`Core.lua`、`Locales.lua`、`GUI.lua`；任何調整都要核對 namespace 與 helper 的可用時機。
- `Core.lua` 包含 secret helper、聊天 lockdown guard、backdrop／button／icon／scroll bar／tab／dropdown 等共用皮膚能力及全域 Blizzard 相容處理。

## 審查重點

- 修改 `B.*` 的參數、回傳值、欄位或副作用前，精確搜尋所有 caller，確認重複呼叫仍冪等。
- `B:LoadSkins` 的三條路徑都要核對：default theme、AuroraClassic 載入時已載入的 Blizzard addon、之後收到 addon loaded 的 Blizzard addon。
- theme 執行後的清除 key、重入行為與錯誤隔離要逐路徑檢查，不能只測一種載入順序。
- pixel snapping、backdrop、anchor、frame level／strata 與 Layout 相關 helper 要檢查原生 refresh 是否會覆寫。
- `B:HideObject()` 會改變事件或 Show 行為；caller 必須確定目標 region 不再需要原生更新。
- 全域 Mixin 方法覆寫的影響面大於 AuroraClassic caller；需讀 Blizzard 所有相關呼叫契約並注意其他插件 hook 相容性。
- secret helper 與目前 caller 的基線另見 `secret-values.md`。

## 驗證矩陣

- 登入首次載入與 `/reload`。
- AuroraClassic 先載入，之後開啟 Blizzard LoadOnDemand UI。
- Blizzard addon 已載入後才載入／重載 AuroraClassic。
- 相同 skin helper 對同一 frame 重複執行。
- frame 關閉重開、ScrollBox／pool reset 與重用。
- 涉及 protected／secret 的路徑在戰鬥中與離開戰鬥後操作。

## 2026-08-11 全量審查結論

- 已讀完整 `Core.lua`、`Init.lua` 與全部 caller；詳見 `2026-08-11-full-review-12.1-migration.md`。
- `Init.lua:67-70` 的 delayed `ADDON_LOADED` 路徑執行 `C.themes[addon]` 後誤清 `C.themes[addonName]`，theme registration 會殘留。
- `Core.lua:162-174` 的 `B:CreateSD()` 遺失 `size, override` 參數；Garrison/VenturePlan caller 在 `Shadow=false` 時可解參考 nil shadow。
- `B.ReplaceIconString` 與 `B.SetCurrenciesHook` 分別藏在 AnimaDiversion、Runeforge 模組，形成跨模組與 XML 載入順序耦合。
- 12.1 對 ScriptBindings、EventRegistrations、parent change、layout inheritance 與 texture parent 加入新限制；共用 helper 必須依具體 protected frame 正式服驗證，不把所有 caller預判為失效。
- `BackdropTemplateMixin:SetupTextureCoordinates` 的 secret-width early return 與 icon border RGB 比較仍列為待驗證安全資料流。
