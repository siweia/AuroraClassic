# 主載入 FrameXML 皮膚記憶

## 範圍與載入契約

- 模組位於 `AuroraClassic/FrameXML/`。
- 實際載入清單以 `AuroraClassic/FrameXML/FrameXML.xml` 為準。
- 隨 AuroraClassic 主插件可直接取得的 Blizzard FrameXML，一般以 `tinsert(C.defaultThemes, function() ... end)` 註冊。
- 新增、刪除或改名檔案時，同步核對 Lua、XML `<Script>`、TOC 的 XML 入口與 `.pkgmeta` 打包根目錄。

## 審查方法

- 先在目標 build 的 Blizzard UI 原始碼讀 frame／Mixin 的建立、初始化、refresh、Layout、show／hide、pool reset 與事件流程。
- 確認目標在 AuroraClassic 主載入時確實存在；若屬 LoadOnDemand，不應以 nil guard 留在 FrameXML 模組。
- 優先沿用既有 `B` helper；單一模組用途保持 `local`。
- hook 要選在原生完成更新後的最小範圍。`hooksecurefunc` 與 `HookScript` 不可取代原有行為，`SetScript` 覆寫前需確認 Mixin 契約。
- ScrollBox、frame pool 與資料重綁元件必須可重複套皮膚；background、border、texture、script 與 hook 不得累積。
- Texture 的 atlas、texcoord、vertex color、desaturation 或 alpha 若會被原生 refresh 重設，只 hook 精確更新點，不建立無界限 `OnUpdate`。
- anchor、parent、frame level／strata、scale 與尺寸變更要檢查 Layout 回寫、錨點循環、遮擋與滑鼠區域。

## 驗證矩陣

- 登入後首次套用。
- `/reload`。
- frame 關閉後重開。
- ScrollBox 捲出／捲入與 pool element reset／reuse。
- 設定變更後已存在與之後建立的 frame。
- protected／secure 元件在戰鬥中開啟、刷新與離開戰鬥後狀態。
- secret value 相關 widget 在會啟用限制的正式服場景。

## 2026-08-11 全量審查結論

- 已逐檔閱讀 58/58 Lua；`FrameXML.xml` 的 58 個 Script 與實際檔案完全相符。
- 12.1 確定硬斷點：`ChatFrame.lua` 的 `BattleTagInviteFrame` 已移除；`Fonts.lua` 的固定 RaidWarning slots／`RaidBossEmoteFrame` 已改成動態 pool。
- 確定既有問題：`AlertFrames.lua` 的 `hooked`／`hookded` marker typo 令 pooled alerts 重複掛 hook。
- 確定覆蓋缺口：12.1 SocialUI、Chat Config Additional Colors，以及既有 `InitiativeTasksObjectiveTracker`。
- Voice notification GUID/class 是 chat messaging lockdown secret 風險；動態 HookScript 另受 12.1 ScriptBindings 新契約影響。
- ColorPicker、Splash、UIWidgets 的搬移目前保留 Aurora 所用結構；EquipmentFlyout width、ObjectiveTracker `bar.Icon` 等疑點已由原生 lifecycle 排除。
- 尚未進行正式服遊戲內全模組測試；完整矩陣見總報告。
