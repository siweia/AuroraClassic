# Secret Value 與安全資料流

## 適用基準

- AuroraClassic 當前 TOC 仍為 `Interface: 120005`；本輪另以 WoWUI 12.0.7 live 與 12.1 ptr 建立 migration 基線。所有 secret 結論仍須以最後採用的正式服 build 與實測為準。
- oUF_Ruri 文件中針對其他 build、單位框架、光環、資源條或 formatter 的允許路徑只作分析案例，不構成本專案白名單。
- `SecretReturns`、`SecretPayloads`、`SecretValue`、`SecretWhen*` 與由 secret 衍生的值都要沿資料流審查。

## 核心原則

- 不對 secret value 做 Lua 比較、算術、boolean test、table key／索引選擇、排序、篩選、分類或字串解析。
- 不把 secret value 傳給未明確接受 secret argument 的 Lua 函式、WoW API 或 widget 方法。
- 能依 frame 結構、region 或原生已完成的 widget state 套皮膚時，不另讀 gameplay data。
- `B:IsSecretValue()`、`B:NotSecretValue()`、`B:IsSecretTable()`、`B:NotSecretTable()` 只回答目前是否可由 Lua 安全檢查，不會把值解密，也不是略過必要 refresh 的通用方案。
- 不用長期保留舊外觀、隱藏整個功能或大量 early return 掩蓋資料流問題。

## 審查模板

每個可疑路徑都記錄：

1. 精確 API／callback／Mixin／structure field 與對應 build。
2. secret predicate、參數位置及是否只在特定狀態為 secret。
3. 來源到 sink 的完整資料流，包括所有衍生值。
4. 中途是否出現 boolean test、比較、算術、索引、格式化或不明 API 呼叫。
5. 最終 sink 是否由 Blizzard 文件或原始碼明確允許 secret argument。
6. 是否牽涉 protected frame、combat lockdown、taint、anchor、Backdrop、Layout 或 pool reuse。
7. 驗證層級：靜態來源核對、正式服場景與戰鬥內／外測試。

## AuroraClassic 現有基線（2026-08-11）

以下只表示已找到呼叫點，不表示已完成安全認證。

| 位置 | 現況 | 狀態 |
| --- | --- | --- |
| `Core.lua` 開頭 | 定義四個 `B` secret 存取性 helper | 靜態確認；修改契約前須搜尋全部 caller |
| `Core.lua` 的 `WatchPixelSnap`／`DisablePixelSnap` | 先以 `B:NotSecretTable(frame)` 避免對 secret table 執行 frame／texture 操作 | 待以 12.0.5 Blizzard 契約確認；此 guard 只適用可略過的外觀處理 |
| `Core.lua` 覆寫 `BackdropTemplateMixin:SetupTextureCoordinates` | `GetWidth()` 為 secret 時直接返回，原碼已有 `needs review` 註記 | 待驗證；需核對覆寫契約、secret width 的觸發場景與略過後的 backdrop 狀態 |
| `AddOns/Blizzard_Communities.lua` 的 selection 顯示 hook | 以 `B:NotSecretValue(show)` 後才做 boolean test | 待核對 `SetShown` hook 的參數契約、texture reuse 與未讀取時的外觀 fallback |
| `AddOns/Blizzard_Communities.lua` 的 icon ring 狀態 | 以 `B:NotSecretValue(borderShown)` 後決定自訂 border 顯示 | 待核對 `IsShown()` 在目標 build 的 secret 條件與 pooled child refresh |
| `AddOns/Blizzard_Communities.lua` 的 roster class icon | post-hook 讀 `memberInfo.classID` 並查 class table | chat messaging lockdown 下屬已確認 secret-unsafe 資料流；實際觸發需正式服驗證 |
| `FrameXML/ChatFrame.lua` 的 voice notification | secret GUID 衍生 class 後做 boolean test／table key | chat messaging lockdown 高風險；修復 BattleTag 12.1 blocker 後此路徑才重新可達 |
| `AddOns/Blizzard_CooldownViewer.lua` 的 dispel border | tainted post-hook 讀 aura instance，呼叫可回 secret color 的 API | 12.1 restricted aura 高風險；需重新設計 fallback 與 pool reset，不能只 early return |

## 特別風險

- 對 `BackdropTemplateMixin` 的全域方法覆寫會影響所有 caller；不能只檢查 AuroraClassic 直接呼叫點。
- hook 收到的 `show`、尺寸或 widget state 即使看似 boolean／number，也可能在特定受保護狀態成為 secret。
- `and`／`or`、`if value then` 與 table key 選擇都屬 Lua 對值的消費；先確認值非 secret 才可使用。
- secret table guard 若使必要的 reset／refresh 被略過，可能留下 pooled frame 的舊外觀；必須確認略過的副作用只屬可選 cosmetic。

## 遊戲內驗證清單

- `/reload` 後首次建立與關閉重開。
- ScrollBox／pool 元件離開畫面再重用。
- 會啟用 secret 限制的正式服戰鬥、聊天或社群場景。
- 戰鬥中開啟／刷新與離開戰鬥後再刷新。
- 確認沒有 Lua 錯誤、taint、受保護操作封鎖、舊外觀殘留或必要 UI 消失。

## 2026-08-11 全量審查結論

- 已對照 WoWUI 12.0.7／12.1 API documentation 與 Blizzard caller，建立三條具體高風險資料流。
- Blizzard trusted code 能操作 secret 不代表 Aurora post-hook 可做同樣分支、索引或字串處理。
- 12.1 另新增 ScriptBindings、EventRegistrations、parent/layout forbidden-aspect 契約；這些是 migration 實測項，不等於所有現有 caller 已確認失效。
- 尚未完成正式服 restricted aura、chat messaging lockdown、voice 與 combat 測試；不得宣稱上述路徑已安全或已實際報錯。
