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
- 已逐檔讀完 AuroraClassic 126 個 Lua、TOC、兩份載入 XML、打包／release 設定與 README；58 個 FrameXML Script、63 個 AddOns Script 均與實際 Lua 一一對應。
- 12.1 正式上線後已改用 WoWUI `live` 重核。正式 migration 基準為 `861fbf13`（12.0.7.68974）→ `b3733541`（tag `v12.1.0`，12.1.0.69273）；先前 `ptr=b883b4d`（12.1.0.69189）結論已由 live source 覆核，不再作當前事實來源。
- AuroraClassic 當前工作樹仍為 `Interface: 120005`。ChatFrame、Fonts、Achievement、Delves Companion、Housing Dashboard、Weekly Rewards 六個 12.1 結構性硬斷點在 live 全部仍成立，沒有撤回項；12.1 migration 預定 Interface 為 `120100`，修改前仍須以正式服 `GetBuildInfo()` 第四回傳確認。
- 最後 PTR → live 只改動 16 個 tracked 檔（14 個 code/API，另含 `.gitignore` 與 `No code changes.txt`）；與 Aurora migration 直接相關的是 SocialUI 即時搜尋／filter lifecycle、HousingBlueprint 輸入與內容狀態。未新增第七個現有 runtime 硬斷點，但這兩區的實作與測試清單已補強。
- 已更正 Bootstrap 判斷：`Init.lua` 的 initial scan 已同時要求 `loadedOrLoading` 與 `loaded`，不把 bootstrap-only 提早執行列為已確認 bug；delayed `ADDON_LOADED` 清錯 theme key 仍是確定問題。
- 完整 findings、已撤回誤判、正式服測試矩陣與 12.0.7 → 12.1 待辦見 `2026-08-11-full-review-12.1-migration.md`。
- 本輪未修改 AuroraClassic runtime Lua／XML／TOC；secret、secure、combat 與實際 widget 顯示仍須正式服遊戲內驗證。

## 模組記憶入口

- [專案與審查規則](.agents/code_reviews/project-rules.md)
- [Secret value 與安全資料流](.agents/code_reviews/secret-values.md)
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
