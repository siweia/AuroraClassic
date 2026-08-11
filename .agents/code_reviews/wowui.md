# Blizzard UI 來源與版本基準

## 來源優先序

1. `AuroraClassic/AuroraClassic.toc` 的 Interface 與當前工作樹需求。
2. 本機 `D:\Github\WoWUI` 中與目標 build 相符的 MAINLINE 分支／提交。
3. BigWigsMods/WoWUI 或 Gethe/wow-ui-source 遠端來源。
4. Warcraft Wiki、WowInterface Forums 等補充資料。
5. 正式服遊戲內實測用來確認實際載入、secure、secret 與互動行為。

API、Mixin、模板、全域名稱、LoadOnDemand addon 名稱與載入順序的最終依據是相符 build 的 Blizzard UI 原始碼與正式服實測，不以第三方插件實作取代。

## 當前基準（2026-08-12）

- `AuroraClassic/AuroraClassic.toc` 明示 `Interface: 120005`。
- 使用者已指定 12.1 正式上線後以 WoWUI `live` 為 BlizzardInterfaceCode 基準；目前固定比較：
  - 最後 12.0.7 live：`861fbf13f64ead8f984cf7106507a54c6cec9e5e`，12.0.7.68974。
  - 12.1 live：`b37335415534861099918d612f4c35440c1ab986`，tag `v12.1.0`，12.1.0.69273。
- 先前初審使用的 `ptr=b883b4d1`（12.1.0.69189）已由上述 live source 逐項覆核；後續不再以 ptr 結論代表正式服現況。
- 先前 12.0.7 基準 `1f2d1789`（68453）到最後 12.0.7 build 68974 只有 `Blizzard_HouseEditorStorageFrame.lua` 的 saved-state key 變更，AuroraClassic 沒有 HouseEditor caller，因此不改變既有 migration finding。
- 12.1 addon Interface 預定目標是 `120100`；WoWUI 內建 TOC 不提供可直接核對的 MAINLINE Interface 靜態值，修改 AuroraClassic TOC 前仍須以正式服 `/dump select(4, GetBuildInfo())` 確認，之後以關閉「載入過期插件」測試。
- oUF_Ruri 記憶中的 12.1 結論仍只作案例；findings 均由 AuroraClassic caller 與上述 WoWUI live source 重新核對。

## PTR → 正式 live 差異

- `b883b4d1`（PTR 69189）→ `b3733541`（live 69273）共 16 個 tracked 檔有差異（14 個 code/API，另含 `.gitignore` 與 `No code changes.txt`）；六個 Aurora release blocker 所在檔案沒有在這段被撤回。
- SocialUI 搜尋改為 `OnTextChanged` 即時 refresh，隱藏時清除文字；filter dropdown mixin 改為 `SocialUISearchFilterDropdownMixin`。新增 skin 只能處理外觀，不可覆寫這些 lifecycle。
- HousingBlueprint 新增 `C_HousingBlueprint.UpdateBlueprintStringFromInput`，並調整 loading／error／empty content visibility、fixed/minimum height 與兩個 GearDropdown 的 enabled 狀態。此 addon 是獨立 LoD，應有自己的 theme key，不依附 HousingDashboard theme。
- `C_BattleNet.SearchFriends` 在 live 文件新增 `HasRestrictions=true` 且 `SecretArguments=AllowedWhenUntainted`；Aurora 目前沒有 caller，未來 SocialUI skin 不應解析或重送搜尋 payload。
- QueueStatus 新增 `LE_LFG_CATEGORY_LAIR` 顯示名稱，但 Aurora 只把 `QueueStatusFrame` 納入 tooltip backdrop 清單，沒有讀 category，故靜態上不需 migration。

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
