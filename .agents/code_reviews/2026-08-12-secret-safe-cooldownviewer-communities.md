# SECRET SAFE：CooldownViewer 與 Communities

## 記錄資訊

- 日期：2026-08-12
- 建議 commit title：`fix: make CooldownViewer and Communities skins secret-safe`
- 中文摘要：移除 CooldownViewer 與 Communities 皮膚對受限制 gameplay data 的二次解析，改以 Blizzard 已完成的原生 widget state 作為外觀邊界。
- Blizzard 基準：最後 12.0.7 `861fbf13`（12.0.7.68974）與 12.1 live `b3733541`（12.1.0.69273）。
- Aurora 目標：MAINLINE `Interface: 120100`。
- 狀態：runtime 程式已完成靜態修正；正式服 restricted aura、chat messaging lockdown、combat 與 pool reuse 尚未實測。

這是一組專門處理 secret-safe data flow 的變更，不把它誤記為 12.1 才新增的兩個 bug。兩條原始 secret 契約在最後 12.0.7 已存在；12.1 只對 `C_UnitAuras.GetAuraDispelTypeColor` 另加 failure mode 為 error 的 `RequiresUnitAuraAccess` 前置條件。

## 追加問答：這兩個模組真的會引起 secret value 問題嗎

> 問：你有仔細查過 BlizzardInterfaceCode，確定這兩個模組調用的路徑會引起 secret value 問題，沒有白改嗎？

有。另以「嘗試反證舊路徑其實不會觸發」的方向，重新核對 WoWUI `live` 12.1.0.69273。精確結論不是「舊碼每次執行都必然報錯」，而是「兩條 post-hook 都是正常 refresh 可達路徑；CooldownViewer 在 restriction 期間再次呼叫 guarded API、且實際 argument／return 受限制時，或 Communities 在 chat messaging lockdown 期間取得／刷新受限制的 member data 時，舊 Aurora consumer 會形成 secret-unsafe data flow」。目前尚未在正式服重現具體 Lua error，因此本次只能記為條件式風險修正，不能記成已重現 crash。

| 判定 | 結果 |
| --- | --- |
| 舊 Aurora hook 是否為正常可達路徑 | 已由 Blizzard live source 確認 |
| 相關 API 是否具有 secret／access 契約 | 已由 generated API documentation 確認 |
| 實際 argument／return 為 secret 或 access precondition 失敗時，舊 addon consumer 是否不安全 | 已由資料流靜態確認 |
| 每次開啟介面是否必然取得 secret | 否，取決於 restriction、資料與 refresh 時機 |
| 正式服是否已重現 Lua error／blocked action | 尚未 |

### CooldownViewer 的反證複核

確定可達的 Blizzard 路徑：

```text
BuffIcon／BuffBar RefreshData
  -> RefreshAuraInstance
  -> GetAuraData 迭代 scanUnits = { "player", "target" } 並快取 aura
  -> 回到 RefreshData
  -> RefreshIconBorder
  -> DebuffBorder:UpdateFromAuraData
  -> Aurora post-hook（修正前）
```

- `Blizzard_CooldownViewer/CooldownViewerItemData.lua:1` 明列同時掃描 `player` 與 `target`；敵方 target 有 harmful aura 路徑，不是只處理 player buff。
- `Blizzard_CooldownViewer/CooldownViewer.lua:267-270` 由 `RefreshIconBorder()` 呼叫 `DebuffBorder:UpdateFromAuraData()`；BuffIcon 與 BuffBar 的 `RefreshData` 分別在同檔 `:1443-1451`、`:1611-1619` 走到該函式，所以舊 hook 不是 dead code。
- `UnitAuraDocumentation.lua:244-250` 對 `GetAuraDispelTypeColor` 明列 `RequiresUnitAuraAccess`、`RequiresValidUnitAuraInstance`、`SecretWhenUnitAuraRestricted`、`SecretWhenCurveSecret` 與 `SecretArguments = "AllowedWhenUntainted"`。
- `SecretPredicatesDocumentation.lua:47-50` 說明 `RequiresUnitAuraAccess` 是 failure mode 為 `Error` 的 precondition；`:79-81` 說明 combat、encounter、challenge mode 或 PvP addon restrictions 生效時，guarded API 可能產生 secret value，個別 spell 的 `NeverSecret`／`AlwaysSecret` 設定可優先覆蓋。

可反證的過強說法是「這個 hook 每次都一定拿到 secret 或一定報錯」。城內、沒有 restriction、restriction 期間沒有再次執行該 hook／API，或 aura 被標為 `NeverSecret` 時，舊路徑可能不會觸發問題；Aurora 自建的 `borderCurve` 也只含公開常數，沒有證據表示本案會觸發 `SecretWhenCurveSecret`。限制前取得的 public cache 本身不能當成安全保證，因為 hook 若在 restriction 期間再次呼叫 `GetAuraDispelTypeColor`，該次 API call 仍可能回傳 secret，或先因缺少 unit aura access 而 error。真正成立的風險是：restriction 生效且實際 argument／return 受限制時，Aurora post-hook 再呼叫 guarded API、判斷 `color`、讀取 RGB 並寫入 backdrop，不能由 source 證明具有 Blizzard 的 unit aura access，也不能假設 `hooksecurefunc` 會把 addon callback 提升成 trusted code。

因此移除仍不是白改。CooldownViewer 原生已用 `AuraUtil.SetAuraBorderAtlasFromAura` 管理 dispel atlas；Aurora 的資料重算只為替自訂 backdrop 染色。刪除它會失去 Aurora 自訂彩色邊框，但保留 Blizzard 原生 gameplay 語意，同時移除對未文件化 hook 權限與受限制 aura data 的依賴。

### Communities 的反證複核

確定可達的 Blizzard 路徑：

```text
C_Club.GetClubMembers／C_Club.GetMemberInfo
  -> Communities cache／DataProvider
  -> row:SetMember(self.memberInfo)
  -> RefreshExpandedColumns
  -> Aurora post-hook（修正前）
  -> memberInfo.classID
  -> C_CreatureInfo.GetClassInfo
```

- `ClubDocumentation.lua:611-625` 對 `C_Club.GetMemberInfo` 明列 `SecretInChatMessagingLockdown = true`；`SecretPredicatesDocumentation.lua:64-66` 說明 encounter、challenge mode、PvP restrictions，以及 dungeon／raid 等 communication-restricted map 中，guarded API 會產生 secret value。
- `ClubMemberInfo.classID` 沒有 `NeverSecret`。memberInfo 經 Communities cache、DataProvider、row 的 `self.memberInfo` 全程保留原物件；`GetMemberInfo()` 只是回傳該欄位，source 中沒有 declassify、可存取性檢查或轉成 public copy 的步驟。
- `CommunitiesMemberList.lua:952-967` 的 `GUILD_ROSTER_UPDATE` 會重新呼叫 `C_Club.GetMemberInfo` 後執行 `RefreshExpandedColumns`；`SetMember`、`SetExpanded` 與 ScrollBox refresh 也會走到同一函式。expanded roster 在 restriction 期間建立、捲動重綁或刷新時，舊 Aurora hook 可以讀到當次受限制資料。
- Blizzard initializer 使用 trusted／secure execution 消費原生資料，不代表其後的 Aurora addon post-hook取得相同權限；把回傳 table 存進普通 Lua 欄位也不會解除 secret。
- `C_CreatureInfo.GetClassInfo` 的 secret argument 契約是 `AllowedWhenUntainted`。舊 post-hook 對 `memberInfo.classID` 做 boolean test，再由 addon callback 傳入該 API，正是應移除的二次 consumer。

可反證的過強說法同樣是「只要打開 Communities 就一定報錯」。必須同時處於 chat messaging lockdown、顯示 expanded roster、存在實際 member row，並在限制期間建立或刷新資料；若只使用限制前的 public cache且完全沒有 refresh、處於 collapsed／header row，或該會員沒有 classID，當次風險不一定觸發。

目前也不能只靠 source 宣稱 `Class:IsShown()` 在此具體分支每次必然回傳 secret；現行 `B:NotSecretValue(shown)` 是依 widget shown-aspect 契約加入的保守防禦。主要已確認風險仍是舊碼重新解析 `memberInfo.classID`。原生 `RefreshExpandedColumns` 已經負責設定職業圖示，移除 Aurora 二次解析只犧牲額外 UV 內縮，不影響原生職業資訊。

ApplicantList 的 `ClubFinderApplicantInfo.classID` 目前沒有同一項 chat-lockdown secret-return 契約，因此 Applicant hook 不是已確認的 secret 漏洞；本次刪除它屬冗餘 consumer 清理與降低未來資料契約變動面，不能把它列成已證實的風險點。

本節是全文對「是否確定會出錯」的精確定性：路徑、API 契約與條件成立後的不安全 consumer 已靜態確認；實際 restriction 觸發條件、hook 當下權限及正式服錯誤型態仍以測試矩陣驗證，不以推測冒充實測。

## 風險一：CooldownViewer 驅散邊框

### 修正前資料流

`AuroraClassic/AddOns/Blizzard_CooldownViewer.lua` 原本在 `DebuffBorder:UpdateFromAuraData` 的 post-hook 中執行：

```text
auraData.auraInstanceID
  -> C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, borderCurve)
  -> if color then
  -> color:GetRGB()
  -> Icon.bg:SetBackdropBorderColor(r, g, b)
```

同時，Aurora 先把 Blizzard 原生 `DebuffBorder` 設成 `SetAlpha(0)`，所以自訂 backdrop 是唯一可見的驅散提示。

### 具體風險

1. 12.0.7 的 `UnitAuraDocumentation.lua` 已為 `GetAuraDispelTypeColor` 標示 `RequiresValidUnitAuraInstance`、`SecretWhenUnitAuraRestricted`、`SecretWhenCurveSecret` 與 `SecretArguments = "AllowedWhenUntainted"`。
2. Aurora post-hook 可能取得受限制的 `auraInstanceID`，再由 tainted addon code 呼叫該 API。
3. 回傳 `color` 可能是 secret；`if color then` 是 boolean test，`color:GetRGB()` 產生的 RGB 仍是 secret 衍生值。
4. 12.1 新增 `RequiresUnitAuraAccess = true`，其 predicate failure mode 是 `Error`。沒有 aura access 時可能在 API 呼叫當下中止，不能靠呼叫後的 `NotSecretValue` 或 nil guard 補救。
5. 原生 border 已被隱藏；若 hook 中止，Aurora backdrop 可能保留 pooled item 的上一個顏色，或完全失去 debuff 外圈語意。

這是 API 文件與 Blizzard source 能確認的靜態不安全資料流；尚未宣稱已在正式服實際觸發 Lua error。

### 採用的修法

- 完整刪除 `dispelIndex`、`borderCurve`、`updateBorderColor`、`handleDebuffBorder` 與兩個 caller。
- Aurora 不再呼叫 `C_UnitAuras.GetAuraDispelTypeColor`，也不讀 `auraInstanceID` 或 RGB。
- 不再把 Blizzard `DebuffBorder` 設成透明；其 show／hide、harmful 判斷與 dispel atlas 全由 Blizzard trusted code 管理。
- 保留 Aurora 的 icon 裁切、固定黑邊、陰影、cooldown swipe 與 bar 外觀。
- 不 hook 原生 border 的 `Show`、`Hide` 或 `SetAtlas` 去鏡射資料狀態，避免把 secret control／widget state 再帶回 addon code。

WoWUI live lifecycle 依據：

- `Blizzard_CooldownViewer/CooldownViewer.lua:267-270`：`RefreshIconBorder()` 呼叫 `DebuffBorder:UpdateFromAuraData()`。
- 同檔 `:2366-2373`：nil aura 隱藏 border；有 aura 顯示後交給 AuraUtil。
- `Blizzard_FrameXMLUtil/AuraUtil.lua:645-652`：由 Blizzard 根據 aura 狀態顯示／隱藏 texture 並設定 dispel atlas。
- BuffIcon／BuffBar 在 viewer 顯示時會於 item reacquire 後重新走 `RefreshData`；viewer 隱藏時父 item 不可見，之後由 `OnShow` 的 `RefreshLayout`／`RefreshData` 更新，因此 Aurora 不需要額外保存或 reset dispel 顏色。

### 可見取捨

Aurora backdrop 不再被染成驅散類型顏色；驅散資訊改由 Blizzard 原生外圈顯示。外觀會與原本略有不同，但不會丟失 gameplay 語意，也不再讓 Aurora 擁有 per-aura state。

## 風險二：Communities roster 職業圖示

### 修正前資料流

`AuroraClassic/AddOns/Blizzard_Communities.lua` 原本 post-hook `RefreshExpandedColumns`：

```text
self:GetMemberInfo()
  -> memberInfo.classID
  -> if memberInfo and memberInfo.classID then
  -> C_CreatureInfo.GetClassInfo(classID)
  -> classInfo.classFile
  -> B.ClassIconTexCoord(self.Class, classFile)
```

### 具體風險

1. `C_Club.GetMemberInfo` 在 12.0.7 與 12.1 都標有 `SecretInChatMessagingLockdown = true`。
2. `ClubMemberInfo.classID` 沒有 `NeverSecret`；chat messaging lockdown 中不能假設它是普通 number。
3. `if memberInfo.classID then` 對可能的 secret 做 boolean test。
4. `C_CreatureInfo.GetClassInfo` 的 secret argument 契約是 `AllowedWhenUntainted`；Aurora tainted post-hook 不能把 secret `classID` 傳入，再以衍生的 `classFile` 選擇 texture coordinates。
5. member row 由 ScrollBox 重用；hook 中止或只 early return 可能留下上一位會員的 Aurora 裁切或外框狀態。
6. 原碼另有 `child.bg:SetShown(child.Class:IsShown())`。12.1 widget API 對 `IsShown()` 標有 shown secret aspect，不能把其回傳值未經檢查直接傳給 `SetShown()`。

### 採用的修法

Roster 不再讀 member payload，只沿用 Blizzard 已完成的 class widget state：

```lua
local function updateNameFrame(self)
    if not self.bg then
        self.bg = B.CreateBDFrame(self.Class)
    end

    local shown = self.Class:IsShown()
    self.bg:SetShown(B:NotSecretValue(shown) and shown)
end
```

- 完整移除 `GetMemberInfo()`、`memberInfo.classID`、`C_CreatureInfo.GetClassInfo()` 與 `B.ClassIconTexCoord()`。
- Blizzard 原生 `RefreshExpandedColumns` 在 expanded、非 BattleNet 分支先 hide class texture，只有成功取得 class 後才設定原生 texcoord 並 show；collapsed 狀態由 `SetExpanded` 控制。Aurora post-hook 只同步外框。
- `Class:IsShown()` 若是 secret，`B:NotSecretValue(shown) and shown` 固定得到安全的 `false`，因此隱藏 Aurora 可選外框，保留 Blizzard 原生 icon。
- Roster 的 ScrollBox 枚舉器在安裝 `Update` post-hook 後立即執行一次，覆蓋 Blizzard addon 已載入且已有 active rows 的路徑；之後每次 `Update` 都重新枚舉，安裝 `RefreshExpandedColumns` hook 後也立即呼叫 helper，補上 hook 安裝前已完成的 initializer／refresh。
- 刪除未經 guard 的 `child.bg:SetShown(child.Class:IsShown())`。
- 原生 refresh 每次都負責 hide／重設 texcoord／show；Aurora 不保存 class-specific state，所以 pool 不需額外 texture reset。

### ApplicantList 一併去除重複資料解析

`updateMemberName(info.classID)` 的 `info` 來自 `C_ClubFinder.ReturnClubApplicantList`／`ReturnPendingClubApplicantList`，目前 API 文件沒有把 `ClubFinderApplicantInfo` 標為 secret return，因此它不是上述已確認的 chat-lockdown 漏洞。

但 Blizzard `ClubFinderApplicantEntryMixin:UpdateMemberInfo` 已經解析 `classID` 並設定 `Class` texcoord，Aurora 再做一次沒有必要。本次一併：

- 刪除 `updateMemberName` 與 `UpdateMemberInfo` post-hook。
- Applicant ScrollBox 同樣在安裝 `Update` post-hook 後立即枚舉現有 children；pooled button 首次 skin 時只建立 `button.Class` 外框。
- 保留 Blizzard 原生 class texcoord，減少未來 API secret 契約變動時新增另一條 gameplay-data consumer。

### 可見取捨

Roster 與 ApplicantList 使用 Blizzard 原生職業圖示 texcoord，不再套 Aurora 額外的 class-cell UV 內縮。一般狀態仍有 Aurora 外框；shown state 受限制時只隱藏可選外框，不隱藏原生職業圖示。

## 為何不只加 guard 或 pcall

- CooldownViewer 在取得 `color` 前就可能因 `RequiresUnitAuraAccess` 失敗；呼叫後 guard 太晚。
- 對 secret value 做 `if value`、table lookup 或 API 轉送本身就是違規資料消費，`pcall` 只吞錯，沒有讓資料流變安全。
- pooled widget 若只是 early return，可能保留上一筆自訂顏色、裁切或顯示狀態。
- 本次改法移除不必要的資料 consumer，讓 Blizzard trusted code 保有 gameplay state 所有權；Aurora 只處理可選 cosmetic。

## 實際修改檔案

Runtime：

- `AuroraClassic/AddOns/Blizzard_CooldownViewer.lua`
- `AuroraClassic/AddOns/Blizzard_Communities.lua`

記憶與提交記錄：

- `.agents/code_reviews/2026-08-12-secret-safe-cooldownviewer-communities.md`
- `CODE_REVIEW.md`
- `.agents/code_reviews/secret-values.md`
- `.agents/code_reviews/addons.md`
- `.agents/code_reviews/2026-08-11-full-review-12.1-migration.md`
- `.agents/code_reviews/12.0.7-to-12.1-todo.md`

兩個 runtime Lua 原本已由 `AddOns/AddOns.xml` 載入，theme key 仍為真實的 `Blizzard_CooldownViewer` 與 `Blizzard_Communities`；本次不新增 Lua 模組、不修改 XML／TOC。

## 靜態驗證

- [x] `git diff --check` 通過；只有工作樹 LF 將由 Git 轉為 CRLF 的提示。
- [x] 已重讀兩個修改後完整函式與作用域；獨立覆核未發現 P0-P2。
- [x] 已搜尋移除的 `GetAuraDispelTypeColor`、curve、handler、roster `memberInfo.classID` 與 applicant post-hook，runtime Lua 無殘留。
- [x] 已核對 AddOns XML、真實 theme key 與 Blizzard live lifecycle；不需修改載入設定。
- [x] 已確認沒有新增 `.gitignore`。

本機沒有 `lua`／`luac`，因此沒有編譯器級 Lua syntax check；已以完整作用域重讀、精確符號搜尋與獨立 code review 補足靜態檢查。

## 正式服測試矩陣

### CooldownViewer

- `/reload` 後檢查 Buff Icon 與 Buff Bar：Aurora icon crop／黑邊／陰影仍在。
- helpful／harmful aura 切換，確認原生 debuff 外圈正確 show／hide。
- 至少兩種 dispel type，確認原生 atlas 顏色切換。
- 新增、刪除、重排及同數量換項，覆蓋 pool release／acquire 與 in-place refresh。
- 戰鬥及 restricted aura 場景觸發／移除 aura、切換 target，確認沒有 secret、`RequiresUnitAuraAccess`、taint 或 blocked-action 錯誤。
- 快速確認沒有 DebuffBorder 的 Essential／Utility viewer 無回歸。

### Communities

- 首次開啟、`/reload`、關閉重開 roster。
- Guild／Community／BattleNet 切換，折疊／展開與 profession header。
- 高速捲動不同職業會員，覆蓋 ScrollBox row reuse；不得留下舊 texcoord／外框。
- chat messaging lockdown 中開啟、捲動與刷新 roster；原生 class icon 可由 Blizzard 管理，Aurora 外框可安全隱藏，不能出現 secret Lua error。
- 解除 lockdown 後刷新／捲動，確認外框恢復。
- Applicant／Pending Applicant 切換、首次顯示與高速捲動，確認原生 class icon 與 Aurora 外框沒有殘影。

正式服測試完成前，本記錄只代表靜態修正完成，不宣稱 runtime 已安全認證。
