# 專案規則與 Code Review 方法

## 固定事實來源

- 專案作業規則：`AGENTS.md`。
- 最新審查概況與入口：`CODE_REVIEW.md`。
- 當前程式事實：AuroraClassic 工作樹的 Lua、XML、TOC 與打包設定。
- Blizzard 契約：與專案目標 build 相符的 Blizzard UI 原始碼；必要時再以正式服實測確認。
- 歷史記憶只提供搜尋方向。若與當前程式不一致，必須以當前來源更正並留下撤回記錄。

## 閱讀與同步流程

### 一般任務

1. 讀固定規則、索引與相關模組記憶。
2. 修改前執行 `git status --short`，辨識使用者既有變更。
3. 讀完整相關作用域，沿定義、註冊、建立、refresh、pool reuse、顯示與 caller 追蹤。
4. 涉及 Blizzard API、Mixin、模板、LoadOnDemand 名稱、受保護行為或 secret value 時，核對對應 Blizzard UI 原始碼。
5. 修改後重讀完整函式／作用域，搜尋改名或移除符號，檢查 TOC／XML／theme key。
6. 執行 `git diff --check` 與完整 diff；不能把格式檢查當成語意驗證。
7. 把已確認結論、未驗證風險與遊戲內測試步驟寫回相關記憶。

### 大記憶恢復

讀完專案內所有 Markdown、當前 Lua、XML、TOC、`.pkgmeta` 與必要的 Blizzard UI 來源。完成後先校正 `CODE_REVIEW.md` 與模組記憶，再進行功能修改。

## 審查邊界

- 修改邊界由使用者需求與 dirty worktree 決定；唯讀驗證邊界要涵蓋所有依賴與 caller。
- 單一模組 helper 維持 `local`；只有多模組確實共用的行為才加入 `B`。修改 `B.*` 契約前搜尋所有 caller。
- 新增、刪除或改名模組時，同步檢查 Lua、XML `<Script>`、TOC、`C.defaultThemes`／`C.themes` 與打包路徑。
- 不以大量 nil guard、`pcall` 或空函式代替生命週期、版本與命名調查。

## 完整呼叫鏈收尾

每次追加功能或重構後，至少檢查：

- 建立與註冊是否只有一條有效路徑。
- 初始化、hook、callback 與 refresh 是否可能重複執行。
- ScrollBox／frame pool 重用與 reset 後是否仍正確，皮膚是否冪等。
- frame 關閉重開、LoadOnDemand 先後順序與 `/reload` 是否一致。
- 是否留下重複 skin、重複 hook、只寫不讀欄位、無用回傳值、失效 guard 或 cache。
- anchor、parent、frame level／strata、scale 與尺寸是否會被原生 Layout／refresh 覆寫。

## 安全與效能判斷

- 受保護 frame、secure template、狀態驅動、CVar 與可能在戰鬥中執行的路徑，先檢查 combat lockdown 與 taint。
- secret value 依實際資料流分析，不能只看 API 名稱，也不能把別的專案白名單搬過來。
- 效能問題先量測再最佳化；區分登入／首次載入的配置與 GC 尖峰，以及穩態事件頻率與每幀成本。
- 一次性初始化 allocation 不等於穩態 CPU 問題；高頻事件也不等於必然需要 cache，需先確認更新頻率、命中率與失效成本。

## GUI、CVar 與 runtime 契約

- GUI 開關必須對應實際 runtime 行為；已移除或無效功能不可留下可操作設定。
- 依賴其他設定的選項應反映禁用、隱藏或說明關係。
- CVar 寫入要分辨存在、唯讀、鎖定、公開、移除與戰鬥限制；secure 不等於插件永遠不可寫。
- 需要離開戰鬥後重試時，要有明確 pending 狀態與清除條件，避免每次事件重複寫入。

## 記憶維護

- 詳細記錄採時間順序追加；索引只保留最新摘要。
- 新結論若推翻舊結論，明確標示「已撤回」或「已更正」並寫原因，不直接抹去脈絡。
- 只記錄已核對的當前事實、具體待驗證項與可重現步驟；避免把猜測寫成 bug。
- 跨模組結論同步更新所有相關記憶，避免只有單一檔案知道契約變更。

## 2026-08-11 初始建立

- 完整閱讀 oUF_Ruri 的 24 份 Markdown，吸收其審查方法與記憶維護模式。
- 已排除 oUF、單位框架、資源條與該專案特有模組結論；AuroraClassic 仍定位為 Blizzard UI 皮膚專案。
- 本檔是規則基線，不代表已完成 AuroraClassic 全專案 code review。
