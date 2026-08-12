# AuroraClassic Code Review 記憶索引

本檔只保存最新概況、閱讀順序與模組入口。具體分析、歷史與待辦放在 `.agents/code_reviews/`；當前工作樹、對應 build 的 Blizzard UI 原始碼與正式服實測永遠優先於舊記憶。

## 使用方式

1. 先讀 `AGENTS.md`、本索引、`project-rules.md` 與 `secret-values.md`。
2. 依任務讀相關模組記憶，再讀當前 Lua、XML、TOC 與 Blizzard UI 對應來源。
3. 不把記憶中的歷史判斷直接當成現況；確認後才引用。
4. 完成審查或修改後，把新結論寫回相關模組記憶，索引只更新摘要與入口。

## 最新概況（2026-08-12）

- 已完整閱讀 `D:\Github\oUF_Ruri` 下 24 份 Markdown，包括 `AGENTS.md`、`CODE_REVIEW.md`、全部 `.agents/code_reviews/*.md`、README 與 issue template。
- 已將其中可泛用的 code review 方法、生命週期檢查、secret value、CVar、效能與記憶維護原則整理到 AuroraClassic 的本機文件。
- oUF_Ruri 的模組結論、API 白名單、版本判斷與歷史問題只保留為參考案例，不視為 AuroraClassic 的現況。
- 初次全量 review 已逐檔讀完 AuroraClassic 當時的 126 個 Lua、TOC、兩份載入 XML、打包／release 設定與 README。2026-08-12 退休三個 dead AddOns 模組、再新增獨立 HousingBlueprint 模組後，當前為 124 個 Lua：58 個 FrameXML Script、61 個 AddOns Script，均與實際 Lua 一一對應。
- 12.1 正式上線後已改用 WoWUI `live` 重核。正式 migration 基準為 `861fbf13`（12.0.7.68974）→ `b3733541`（tag `v12.1.0`，12.1.0.69273）；先前 `ptr=b883b4d`（12.1.0.69189）結論已由 live source 覆核，不再作當前事實來源。
- ChatFrame、Fonts、Achievement、Delves Companion、Housing Dashboard、Weekly Rewards 六個 12.1 結構性硬斷點已在 2026-08-12 當前工作樹完成靜態修正；Weekly Rewards 不存在的確認框 NameFrame 路徑與 ChatFrame 重新可達的 voice secret data flow 也一併修正。舊 global／field 已無殘留，六個模組的載入 XML／theme key 不需改動，正式服操作驗證仍待完成。
- CooldownViewer restricted-aura dispel color 與 Communities roster `classID` 兩條既有 secret data flow 已完成靜態修正：Aurora 不再解析 aura／member payload，改保留 Blizzard 原生 debuff border 與 class texture；詳細風險、實作取捨與測試矩陣見 `2026-08-12-secret-safe-cooldownviewer-communities.md`。
- 五項已確認的核心／runtime 缺陷已於 2026-08-12 完成靜態修正：delayed `ADDON_LOADED` 正確清除事件 addon 的 theme、AlertFrames pool hook 使用一致 marker、`CreateSD(size, override)` 契約恢復、ChatBubbles 選項在 reload 後真正控制監聽 lifecycle、GMChat 改 hook canonical `ChatFrameUtil`。正式服 GM focus、alert pool、Shadow=false＋VenturePlan 與 ChatBubbles 開關仍待驗證。
- 六組既有外觀漏項已於 2026-08-12 完成靜態修正：PVP category 改枚舉 live `CategoryButtons`、PlayerChoice 補 `BorderOverlay`、NewPlayer 改用現行 tutorial globals、Transmog 補 Previewed Weapon checkbox、ObjectiveTracker 納入 Initiative Tasks、Expansion Landing 改走動態 Midnight overlay；EncounterJournal Journeys 亦補固定外框與 pooled Renown watch checkbox。正式服首次顯示、重開與 pool reuse 仍待驗證。
- dead code 清理已完成：移除 `Blizzard_DelvesDashboardUI`、`Blizzard_TalentUI`、`Blizzard_VoidStorageUI` 三個 MAINLINE dead themes，以及只指向不存在 `MajorFactionRenownFrame` 的 Aurora 模組；後者的現行責任由 EncounterJournal Journeys 承接。Calendar debug print 與無 caller 的 `DB.isNewPatch` 也已移除。`Blizzard_Tutorial` 仍保留為是否重寫到 `Blizzard_BoostTutorial` 的獨立決策。
- AuroraClassic 當前工作樹已依使用者指示更新為 `Interface: 120100`；正式服 `GetBuildInfo()` 第四回傳與關閉「載入過期插件」的冷登入仍待驗證。
- 最後 PTR → live 只改動 16 個 tracked 檔（14 個 code/API，另含 `.gitignore` 與 `No code changes.txt`）；與 Aurora migration 直接相關的是 SocialUI 即時搜尋／filter lifecycle、HousingBlueprint 輸入與內容狀態。未新增第七個現有 runtime 硬斷點，但這兩區的實作與測試清單已補強。
- 12.1 新 UI 已於 2026-08-12 完成靜態覆蓋，並做過修後 self-review：SocialUI 補 Raid content／RaidInfo side window且排除 ResizeLayout backdrop；Housing budget pool 改 hook 兩個具體 container instance；Guild Discord 補已快取的 `rankUpdate`；Cooldown drag 保留正常延後建立的安全 Mixin hook，不為 theme 前已存在的匿名 singleton 遍歷帶 Hierarchy secret aspect 的 UI tree。新增 skin 只讀 frame／region，不解析 Social search、Housing share code、Discord 或 aura payload；正式服狀態切換、pool reuse、secure drag 與 LoD 兩種時序仍待驗證。
- 正式服已確認 `Blizzard_SocialUI` 可成功載入，但 `C_SocialUI.IsSystemEnabled()`／`SocialUIControl.IsEnabled()` 目前為 false，`O` 因此走 legacy FriendsFrame。該路徑的 `FriendsFrame_OnShow()` 刷新 guild roster，暴露 Aurora GuildControl rank rows 尚未建立便由自建 `GUILD_RANKS_UPDATE` handler 掃描的 hard error；當前工作樹已移除錯誤事件監聽，改在原生 `GuildControlUI_RankOrder_Update` 完成後 skin 並 immediate 掃描既有 rows，正式服反覆按 `O` 與 rank 變更待重測。
- Communities 的 12.1 Discord／friend-request source diff 沒有新增獨立 widget/template；既有 chat／stream frame skin 自然承接。Aurora 未新增 `discordInfo`／member payload consumer，這項已由「待新增 UI」更正為「無額外 runtime skin 必要」。
- 已更正 Bootstrap 判斷：`Init.lua` 的 initial scan 已同時要求 `loadedOrLoading` 與 `loaded`，不把 bootstrap-only 提早執行列為已確認 bug；delayed `ADDON_LOADED` 清錯 theme key 也已修正，兩種 LoD 時序仍待正式服驗證。
- 完整 findings、已撤回誤判、正式服測試矩陣與 12.0.7 → 12.1 待辦見 `2026-08-11-full-review-12.1-migration.md`。
- 六個結構性 blocker 與兩個 secret-safe runtime 修正均未新增模組或修改載入 XML／theme key；secret、secure、combat、pool reuse 與實際 widget 顯示仍須正式服遊戲內驗證。

## 模組記憶入口

- [專案與審查規則](.agents/code_reviews/project-rules.md)
- [Secret value 與安全資料流](.agents/code_reviews/secret-values.md)
- [2026-08-12 CooldownViewer／Communities SECRET SAFE 記錄](.agents/code_reviews/2026-08-12-secret-safe-cooldownviewer-communities.md)
- [Blizzard UI 來源與版本基準](.agents/code_reviews/wowui.md)
- [Init／Core／共用 helper](.agents/code_reviews/core.md)
- [Config／GUI／Locales／SavedVariables](.agents/code_reviews/gui.md)
- [主載入 FrameXML 皮膚](.agents/code_reviews/framexml.md)
- [LoadOnDemand AddOns 皮膚](.agents/code_reviews/addons.md)
- [從 oUF_Ruri 整理的備用審查案例](.agents/code_reviews/reference-lessons.md)
- [2026-08-11 全專案 review 與 12.1 migration](.agents/code_reviews/2026-08-11-full-review-12.1-migration.md)
- [12.0.7 → 12.1 可勾選 To-do](.agents/code_reviews/12.0.7-to-12.1-todo.md)

## 記錄狀態詞

- **已確認**：已由當前工作樹與指定 Blizzard UI build 核對；若涉及遊戲行為，另註明是否完成遊戲內實測。
- **靜態確認**：已核對程式與載入設定，但尚未在遊戲內操作驗證。
- **待驗證**：只有線索或風險假設，不可當成既定問題或安全結論。
- **已撤回／已更正**：保留舊判斷與更正理由，避免後續再次沿用失效結論。
