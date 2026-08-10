# oUF_Ruri 備用審查案例整理

## 定位

2026-08-11 已完整閱讀 `D:\Github\oUF_Ruri` 下 24 份 Markdown：根目錄規則、總 code review、README、全部 `.agents/code_reviews/*.md` 與 issue template。

本檔只保存可泛用的思考模式。oUF_Ruri 是單位框架專案，AuroraClassic 是 Blizzard FrameXML／LoadOnDemand UI 皮膚專案；前者的模組狀態、版本結論、API 白名單與修正歷史不能直接成為後者事實。

## 生命週期與所有權

- 問題通常不只在建立當下；要沿註冊、初始化、refresh、disable／enable、reset、pool reuse、show／hide 與 caller 收尾。
- frame pool／ScrollBox element 可能在資料重綁後保留舊外觀。皮膚要冪等，reset 後需要恢復的狀態要有精確 hook。
- 先辨識誰擁有 frame、region、資料與更新權。外部 code 只應在契約允許的 hook 點補外觀，避免接管原生生命週期。
- lazy load 與「已載入／之後載入」是兩條獨立路徑，不能只因其中一條正常就判定完成。

## Secret value 與受保護行為

- 依精確 predicate、參數與來源到 sink 的資料流判斷，不因 API 名稱相似就整批列為安全或危險。
- 「可能回傳 secret」不等於目前每次都 secret；但只要值成為 secret，就不能做 Lua boolean test、比較、算術、索引、排序、篩選或字串處理。
- Blizzard 明確允許 opaque secret argument 的 formatter／widget setter 路徑可以成立，但允許範圍必須按目標 build 重新確認。
- cosmetic guard 不能跳過必要 reset／refresh，否則可能留下 pool 元件舊狀態。
- secure、combat lockdown、taint 與 secret value 是相關但不同的契約，審查時分開記錄。

## CVar 與設定

- secure CVar 不等於插件永遠不可寫；要分辨戰鬥內封鎖、readonly、locked、public、已移除與其他前置條件。
- 確有戰鬥限制時，可設 pending 並於 `PLAYER_REGEN_ENABLED` 精確重試；成功或失效後清除，避免無限寫入。
- GUI 控制項必須對應有效 runtime 行為與依賴關係。功能 inactive 時不應保留看似可用的選項。
- 設定遷移要處理 default、舊 SavedVariables、清理、locale 與 reload／即時生效契約。

## Code Review 方法

- dirty worktree 限制可修改範圍，不限制唯讀依賴搜尋；「只改一行」仍可能需要檢查整個 caller 網路。
- 刪除 local、namespace alias、API cache、設定 key、locale key、callback 或 load key 前，搜尋完整檔案或全專案並區分 active code、註解與字串。
- `git diff --check` 只檢查空白與 patch 格式；仍需重讀完整作用域、搜尋殘留符號並核對載入設定。
- 新增功能後重新走一次完整呼叫鏈，清理重複 refresh、重複 hook、無用回傳值、只寫不讀欄位、失效 guard 與 cache。
- 若後續證據推翻舊發現，明確標示已撤回／更正與原因，避免記憶持續放大已不存在的問題。

## 效能判斷

- 先 profile 再最佳化，分開看初始化 allocation／GC 尖峰與穩態 CPU／事件頻率。
- 一次性建立 table、closure 或 region 不等於穩態瓶頸；高頻 callback 也要先量測實際成本與命中率。
- cache 會帶來失效與同步成本。只有資料穩定、重算昂貴且有可靠 invalidation 時才值得加入。
- 皮膚專案特別注意重複套用造成的 region／hook 累積，這同時是正確性與效能問題。

## Blizzard 上游契約

- 讀目標 frame／Mixin 的建立、初始化、refresh、pool reset、Layout 與 show／hide 全流程，不以舊全域名稱加 nil guard 結案。
- API、模板、addon key 與載入順序以相符 build 的 Blizzard UI 原始碼為準；第三方插件只能提供搜尋線索。
- 不同 build 的結構不能混搭。Ruri 文件中的 12.1 結論在 AuroraClassic `Interface: 120005` 上一律標成待重新查證。

## 不移植的內容

- oUF element、tag、unitframe、raidframe、nameplate、totem、resource bar、AuraContainer 與其第三方 library 的當前狀態。
- oUF_Ruri 專用設定 key、事件白名單、API 白名單、版本分界與效能結論。
- 只在 Ruri 工作樹成立的 bug、修正、已撤回發現與檔案載入關係。

這些資料若未來與 AuroraClassic 任務產生交集，只用來提出檢查問題；所有實際結論仍回到 AuroraClassic 原始碼、目標 WoWUI build 與正式服實測建立。
