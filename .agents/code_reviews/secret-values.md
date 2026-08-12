# Secret Value 與安全資料流

## 適用基準

- AuroraClassic 當前 TOC 已依使用者指示更新為 `Interface: 120100`；12.1 migration 已改以 WoWUI live `b3733541`（12.1.0.69273）重核。先前 PTR 只保留為歷史基線，所有 secret 結論仍須以 live source 與正式服實測為準。
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

## AuroraClassic 現有基線（2026-08-12）

以下只表示已找到呼叫點，不表示已完成安全認證。

| 位置 | 現況 | 狀態 |
| --- | --- | --- |
| `Core.lua` 開頭 | 定義四個 `B` secret 存取性 helper | 靜態確認；修改契約前須搜尋全部 caller |
| `Core.lua` 的 `WatchPixelSnap`／`DisablePixelSnap` | 先以 `B:NotSecretTable(frame)` 避免對 secret table 執行 frame／texture 操作 | 待以 12.1 Blizzard 契約確認；此 guard 只適用可略過的外觀處理 |
| `Core.lua` 覆寫 `BackdropTemplateMixin:SetupTextureCoordinates` | `GetWidth()` 為 secret 時直接返回，原碼已有 `needs review` 註記 | 待驗證；需核對覆寫契約、secret width 的觸發場景與略過後的 backdrop 狀態 |
| `AddOns/Blizzard_Communities.lua` 的 selection 顯示 hook | 以 `B:NotSecretValue(show)` 後才做 boolean test | 待核對 `SetShown` hook 的參數契約、texture reuse 與未讀取時的外觀 fallback |
| `AddOns/Blizzard_Communities.lua` 的 icon ring 狀態 | 以 `B:NotSecretValue(borderShown)` 後決定自訂 border 顯示 | 待核對 `IsShown()` 在目標 build 的 secret 條件與 pooled child refresh |
| `AddOns/Blizzard_Communities.lua` 的 roster class icon | 已移除 `GetMemberInfo()`／`classID` 資料消費；沿用原生 class texture，Aurora 外框只在 `IsShown()` 非 secret 時同步 | 已完成靜態修正；chat messaging lockdown 與 pool reuse 待正式服驗證 |
| `FrameXML/ChatFrame.lua` 的 voice notification | hook 在讀 GUID／class 前檢查 chat messaging lockdown 與 `B:NotSecretValue` | 已完成靜態修正；restricted 時保留 Blizzard hook 前已恢復的原生 channel color，仍須正式服實測 |
| `AddOns/Blizzard_CooldownViewer.lua` 的 dispel border | 已刪除 aura instance／secret color post-hook，保留 Blizzard 原生 DebuffBorder 管理 dispel atlas | 已完成靜態修正；restricted aura、combat 與 pool reuse 待正式服驗證 |

## 12.1 live 補充契約

- CooldownViewer、Communities roster 與 voice GUID 三條高風險資料流的 API 契約在 live 69273 仍成立；當前工作樹已分別移除不必要資料 consumer 或在消費前加 guard，三者狀態均為「靜態修正完成、正式服待驗證」。
- Communities `GetMemberInfo` 的 chat-lockdown secret 契約及 CooldownViewer `GetAuraDispelTypeColor` 的 restricted-aura／curve secret 契約在 12.0.7 已存在，因此兩者不是 12.1 才出現的資料流；12.1 對 dispel color API 另新增 failure mode 為 error 的 `RequiresUnitAuraAccess` 前置條件，新增的是呼叫資格風險，仍須以 live restricted aura 場景重測。
- CooldownViewer 已停止解析 aura payload／RGB並保留 Blizzard trusted code 管理的原生 border；Communities 已使用原生完成的 class texture／widget state，不再自行重算 `classID`。完整修正記錄見 `2026-08-12-secret-safe-cooldownviewer-communities.md`。
- Voice GUID 的 secret 註記在 12.0.7 已存在，不是 12.1 新限制。Blizzard `VoiceActivityNotification` 在 Aurora hook 前已先恢復原生 channel color，因此 restricted 時略過 Aurora class recolor 可使用原生狀態作 fallback，不必保留 pooled 舊 class 色。
- `C_BattleNet.SearchFriends` 在 live 文件新增 `HasRestrictions=true`、`SecretArguments=AllowedWhenUntainted`。Aurora 目前沒有 caller；未來 SocialUI skin 只處理 frame/region，不 hook 搜尋資料、不自行呼叫或轉送 `AuroraFriendsSearchInfo`。
- `C_HousingBlueprint.UpdateBlueprintStringFromInput` 是 live 69273 新增 API；若 `inputShareCode` 是 secret，只有未 taint 的呼叫可傳入。Aurora 目前沒有 HousingBlueprint runtime 模組；新增 skin 不讀、不 trim、不驗證、不保存 share code，只處理公開 widget 外觀與 enabled/shown state。
- 上述兩項是未來實作邊界，不表示目前 Aurora 已存在新的 secret data-flow bug。

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

- 已對照 WoWUI 12.0.7／12.1 API documentation 與 Blizzard caller，建立三條具體高風險資料流；voice、CooldownViewer 與 Communities 均已完成靜態修正。
- Blizzard trusted code 能操作 secret 不代表 Aurora post-hook 可做同樣分支、索引或字串處理。
- 12.1 另新增 ScriptBindings、EventRegistrations、parent/layout forbidden-aspect 契約；這些是 migration 實測項，不等於所有現有 caller 已確認失效。
- 尚未完成正式服 restricted aura、chat messaging lockdown、voice 與 combat 測試；不得把靜態修正宣稱為 runtime 已安全認證，也不得宣稱修正前風險已在正式服實際報錯。
