# Blizzard UI 來源與版本基準

## 來源優先序

1. `AuroraClassic/AuroraClassic.toc` 的 Interface 與當前工作樹需求。
2. 本機 `D:\Github\WoWUI` 中與目標 build 相符的 MAINLINE 分支／提交。
3. BigWigsMods/WoWUI 或 Gethe/wow-ui-source 遠端來源。
4. Warcraft Wiki、WowInterface Forums 等補充資料。
5. 正式服遊戲內實測用來確認實際載入、secure、secret 與互動行為。

API、Mixin、模板、全域名稱、LoadOnDemand addon 名稱與載入順序的最終依據是相符 build 的 Blizzard UI 原始碼與正式服實測，不以第三方插件實作取代。

## 當前基準（2026-08-11）

- `AuroraClassic/AuroraClassic.toc` 明示 `Interface: 120005`。
- 本輪使用者明確要求 12.0.7 → 12.1 migration，因此固定比較：
  - `live`：`1f2d1789ad7d4721b4b89bcabf736b3d958d8485`，12.0.7.68453。
  - `ptr`：`b883b4d1d004b9437da7a09dfe3ea6752b472f69`，12.1.0.69189。
- oUF_Ruri 記憶中的 12.1 結論仍只作案例；本次 findings 均重新由 AuroraClassic caller 與上述 WoWUI source 核對。

## 查證路線

- 先由 AuroraClassic 的 frame 名稱、Mixin、模板、方法或 addon key 精確搜尋本機 WoWUI。
- 讀目標 frame 的建立、初始化、refresh、pool reset、show／hide、Layout 與事件註冊，不只搜尋單一全域名稱。
- LoadOnDemand 功能以 Blizzard TOC 的真實 addon 名稱確認 `C.themes` key，不從 AuroraClassic 檔名猜測。
- 涉及 protected 或 secret 行為時，同時查 API 文件註記、原始 caller 與資料如何流入 widget。
- 本機來源缺少精確 build 時，才同步／查遠端；不同分支的結構不得混合推論。

## 記錄格式

每次需要固定上游結論時，記錄：

- AuroraClassic 目標 Interface。
- WoWUI 分支、提交或 build。
- Blizzard 檔案與關鍵 Mixin／函式。
- AuroraClassic 對應模組與 hook 點。
- 靜態結論、未確認事項與遊戲內重現步驟。

## 2026-08-11 全量審查狀態

- 已對 58 個 FrameXML 與 63 個 AddOns 模組逐項查證主要 frame、Mixin、TOC key、pool／ScrollBox 與 12.1 diff。
- 精確 findings、上游路徑、migration to-do 與已排除疑點集中保存在 `2026-08-11-full-review-12.1-migration.md`，避免本基準檔重複大量易過期細節。
- 正式服實測仍是 secure、secret、combat、Bootstrap 與實際顯示行為的最終依據。
