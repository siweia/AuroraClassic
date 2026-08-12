# Config／GUI／Locales／SavedVariables 記憶

## 範圍

- `AuroraClassic/Config.lua`
- `AuroraClassic/GUI.lua`
- `AuroraClassic/Locales.lua`
- `AuroraClassic/Init.lua` 中設定載入、同步與清理流程
- `AuroraClassic/AuroraClassic.toc` 的 SavedVariables 宣告

## 當前設定基線（2026-08-11）

目前 `C.options` 可見的主要 key 包含：`Alpha`、`Bags`、`FlatMode`、`ChatBubbles`、`FontOutline`、`FontScale`、`Loot`、`Tooltips`、`Shadow`、`ObjectiveTracker`、`UIScale`、`CooldownMgr`、`DamageMeter`。

這只是 key 清單，不代表每個 GUI 控制項、runtime caller 與 reload 行為都已逐項驗證。

## 審查重點

- 設定 key 的 default、SavedVariables 合併／清理、GUI 控制項、runtime 讀取點與 locale 文案必須一致。
- 改名或刪除 `C.options`／locale key 時搜尋全專案；確認舊 SavedVariables 是否需要遷移或自然清除。
- GUI 若宣稱即時生效，要確認所有已建立 frame 都有 refresh 路徑；只能 `/reload` 生效則文案與行為要一致。
- build 判斷屬 runtime 相容契約，修改門檻前搜尋全部讀取點並連結到確切 Blizzard UI 變更。
- 選項依賴、互斥與不可用狀態要在 GUI 與 runtime 同步處理。
- 不把沒有實作或已失效的功能留成可操作控制項。
- CVar 寫入依 `project-rules.md` 的存在、readonly、locked、public、combat 與 retry 規則審查。

## 驗證矩陣

- 新安裝無 SavedVariables、既有 SavedVariables 與含失效 key 的升級情境。
- GUI 開關後立即觀察與 `/reload` 後觀察。
- 字型、scale、shadow、flat mode 等可能影響多模組的設定要抽查既有 frame 與之後新建 frame。
- 依賴 Blizzard addon 的選項要測 addon 未載入、已載入與延遲載入。
- 目標語系下 locale 缺漏、fallback、格式參數與控制項寬度。

## 2026-08-11 全量審查結論

- 已逐項搜尋所有 `C.options` runtime caller、GUI 控制項、locale 與 SavedVariables 清理路徑。
- 全量審查時確認 `ChatBubbles` 在 Config、GUI、Locales 都存在但沒有 runtime 讀取；已於下方 2026-08-12 接上 reload-based gate。
- 全量審查時確認 `DB.isNewPatch` 只有 `Config.lua:25` 的定義、沒有 caller；已於 2026-08-12 移除。
- Alpha 的即時更新與 Cancel／Default 回復路徑成立；其他外觀選項依現行 GUI 文案預期 reload，不列為即時 refresh bug。
- 工作樹已更新為 `Interface: 120100`；六個 12.1 結構性硬斷點已完成靜態修正，正式服 UI 與冷登入驗證仍待完成。

## 2026-08-12 ChatBubbles 選項修正

- `AuroraClassicDB.ChatBubbles` 已有 runtime caller：`FrameXML/ChatBubbles.lua` 的 default theme callback 會在建立監聽 frame前檢查設定。
- 本選項採與既有非即時外觀設定相同的 reload-based 行為。false＋reload 後保留 Blizzard 原生 bubble；true＋reload 後才註冊 say／yell／party 事件並套 Aurora skin。
- SavedVariables 預設合併發生在 default themes 執行前，因此新安裝與既有設定都能在正確時機生效。正式服 false／true 兩向切換仍待驗證。

## 2026-08-12 dead build state 清理

- 已移除無 caller 的 `DB.isNewPatch` 與專案內唯一的 `GetBuildInfo()` 呼叫。它不是 `C.options`、SavedVariables 或文件化第三方 API，不需要設定遷移。
- 12.1 Interface 的 runtime 確認仍可由使用者在正式服執行 `/dump select(4, GetBuildInfo())`；移除 addon 內未使用的 cache 不影響這項驗證。
