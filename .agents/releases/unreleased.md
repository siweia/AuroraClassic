# AuroraClassic Unreleased 記憶日誌

## 目前基線

- release base：`8.1.0` tag／`a519455fccf83ad46819cf08cffd3af483dc85cd`。
- 目前分支：`master`；`HEAD`仍在`8.1.0`，tracking `origin/master`且本地基線落後12個commit。下列12.1工作尚未commit，全部存在工作樹。
- runtime範圍：31個tracked檔變更（28 modified、3 deleted），另新增`Blizzard_AuraContainer.lua`與`Blizzard_HousingBlueprint.lua`；`AddOns.xml`同步為62個AddOns Script，FrameXML仍為58個Script。
- 工作樹`AuroraClassic.toc`已改為`Interface: 120100`，addon `Version`仍是`8.1.0`；下一個release名稱尚未決定。
- 主要migration來源為WoWUI 12.0.7.68974（`861fbf13`）→12.1.0.69273（`b3733541`）。AuraContainer另核對69283，Communities avatar另核對69382；目前本機live已到69497，但尚未進行全工作樹69497重審。

## 版本、loader與共用契約

- TOC Interface由`120005`更新為`120100`。
- `Init.lua`的delayed `ADDON_LOADED`路徑在執行`C.themes[addon]`後清除同一個event addon key，不再誤清固定AuroraClassic key；initial scan仍要求Blizzard addon完整loaded。
- `B:CreateSD(size, override)`恢復參數、override與既有shadow回傳契約；`Shadow=false`時VenturePlan明確傳入override的caller不再取得nil。
- AlertFrames把`hooked`／`hookded`拼字分裂改成單一`__auroraAnimHooked` marker，避免pooled alert重複掛OnEnter／OnShow／animation hooks。
- ChatBubbles option在default theme建立listener前生效；false＋reload時不建立監聽frame、不註冊聊天事件。
- 移除無caller的`DB.isNewPatch`／addon內`GetBuildInfo()`cache，以及Calendar只用於聊天輸出的debug print。
- 專案記憶改為release歸檔：根目錄只保留本機索引／規則入口，固定review與secret紀錄集中於`.agents/code_reviews/`，具體已完成改動集中於本檔；後續建立tag時再歸檔為`.agents/releases/<version>.md`。
- `.gitignore`預設忽略Markdown，僅允許`.agents/releases/`下的release紀錄納入版本控制；本機規則、索引與todo不隨專案上傳。

## 12.1結構性相容

- ChatFrame改用`BattleNetInviteFrame.Border`／`SendButton`／`CancelButton`，移除不存在的`BattleTagInviteFrame`路徑，讓theme後半可繼續執行。
- RaidWarning／boss-emote字型由固定slot改為`RaidWarningFrame`與`CinematicFrame.BossEmoteFrame`的`fontStringPool`／`AcquireString` lifecycle；每個FontString只初始化一次，FontScale走公開`SetTextScale()`。
- Achievement先清理`AchievementFrame.HeaderDetails`新增頂部材質並套用`Back`按鈕，再由`HeaderDetails.Filters`與`SearchBox.SearchPreviewContainer`取得filter／search；不再覆寫HorizontalLayout／comparison anchors。
- Delves Companion改走`CompanionSlots`，涵蓋Role／Flavor／Combat／Utility四個slot；active option row立即處理，pooled texture／atlas切換會重設或恢復texcoord與border。
- Housing Dashboard改用root lifecycle容器內的`HouseDropdown.Dropdown`，避免在第一個舊path中止整個theme。
- Weekly Rewards改枚舉`ConcessionsFrame.Rewards`children並處理每個`RewardsFrame.Text`；不存在的`WeeklyRewardsFrameNameFrame`改為確認框`ItemFrame.NameFrame`。

## Secret／restricted-object修正

- CooldownViewer移除`GetAuraDispelTypeColor`、aura instance、ColorCurve／RGB與自訂per-aura border state，不再把原生DebuffBorder設透明；dispel語意交回Blizzard原生AuraUtil管理。
- CooldownViewer四個viewer在安裝`RefreshLayout`post-hook後立即掃描active item frames，補theme執行時已存在的pool element。
- Communities roster移除`GetMemberInfo()`／`classID`／class lookup與Applicant重複資料解析；只沿用原生Class texture，shown state不可存取時僅隱藏可選Aurora外框。
- Communities會被`C_Club.SetAvatarTexture`重用的主框`PortraitOverlay.Portrait`、Community card `CommunityLogo`、Invitation／community list row／Ticket Manager `Icon`不再經`B.ReskinIcon`或generic texture strip；主框只重做安全的portrait-frame外觀，其餘改建獨立方形border。ClubFinder guild／community邀請切換後，以可存取的原生Icon shown state同步border，不讀`clubInfo`。
- ObjectiveTracker不再對`ScenarioObjectiveTracker.MawBuffsBlock.Container`及其List安裝Aurora texture／script hooks；該container自身註冊secret `UNIT_AURA`，且同一原生refresh鏈會呼叫`C_UnitAuras.GetAuraDataByIndex`（`RequiresUnitAuraAccess`、`SecretArguments="AllowedWhenUntainted"`），保留Blizzard原生外觀以免把addon hook帶入受限event owner。
- Voice notification在chat messaging lockdown、GUID或class不可存取時不做class衍生與table lookup，保留Blizzard原生channel color。
- 新增`Blizzard_AuraContainer`theme；只經`AuraContainerInbound.SetTooltipBackdrop`設定黑底、黑邊與`.7`透明度，尊重`AuroraClassicDB.Tooltips`，不取得forbidden tooltip、不hook AuraButton也不讀aura payload。
- SocialUI skin不讀或轉送`C_BattleNet.SearchFriends`資料；HousingBlueprint不讀、trim、驗證或保存share code／budget payload；Guild Discord不解析Discord資料。

## 12.1新增UI覆蓋

- `FrameXML/FriendsFrame.lua`新增真實`Blizzard_SocialUI`theme：主框、Battle.net bar／controls、broadcast／unavailable／ignore side windows、動態tabs、各content ScrollBox、Friend Requests／Recent Allies／Quick Join／RAF、Raid content與RaidInfo rows均按pool lifecycle冪等處理。ResizeLayout side-window backdrop以`ignoreInLayout`排除原生尺寸計算。
- 保留legacy FriendsFrame skin；正式服已確認`Blizzard_SocialUI`可載入但`C_SocialUI.IsSystemEnabled()`目前為false，因此`O`仍走legacy路徑，新版可見介面待Blizzard重新啟用後測試。
- Housing Dashboard新增Collection scrollbar／details GearDropdown／ContentSummary、Initiatives scrollbars／切換按鈕與動態HouseInfo tabs。
- 新增獨立`Blizzard_HousingBlueprint`LoD module：Import／Validation buttons、兩個GearDropdown、share-code input外觀、ContentSummary與budget entry pool。Validation與Dashboard兩個具體`BudgetsContainer:SetInfo` instance各自post-hook＋immediate scan；不force-show children、不改`fixedHeight`／`minimumHeight`／Layout／MarkDirty。
- CooldownViewer新增GroupBuffFilter scrollbar／section pools、兩個alert editor與shared drag preview。header在strip前保存初始atlas；drag只hook已知Mixin的正常延後建立路徑，不遍歷Hierarchy受限的UI tree。
- PVP category改枚舉原生`CategoryButtons`（含第五項），Training Ground改枚舉`BonusTrainingGroundButtons`（普通＋Arena）。
- Chat Config把`ChatConfigOtherSettingsAdditionalColors`外層box art納入既有strip；內部swatch仍由原生refresh後的既有hook處理。
- GuildControl Discord固定controls與動態linked／unlinked frames已套skin；兼顧global updater與非會長載入時快取的`rankUpdate`。

## 既有lifecycle與外觀缺口

- GMChat由deprecated `ChatEdit_*` alias改hook canonical `ChatFrameUtil.ActivateChat／DeactivateChat`，精確比對`GMChatFrameEditBox`並同步already-active狀態；同時補`GMChatFrame.ScrollBar`skin。
- Guild rank row不再由自建`GUILD_RANKS_UPDATE`handler按rank count提早掃描；改在`GuildControlUI_RankOrder_Update`建立rows後skin並immediate掃描既有row，避免legacy FriendsFrame按`O`刷新guild roster時索引nil。權限checkbox改用live `NUM_RANK_FLAGS`，涵蓋第21項。
- PlayerChoice補`BorderOverlay`，並承認grid template沒有`OptionText`；root `OptionButtonsContainer`改在原生`Setup`完成後skin active pool，涵蓋點選grid option後才建立的按鈕。
- DamageMeter保留原生`clampedToScreen="true"`，header／content backdrop貼合12.1零offset anchors；最小化圖示依`IsMinimized()`初始化，local player entry改由`GetLocalPlayerEntry()`取得並在`ShowLocalPlayerEntry`後重套skin，後續建立的session window仍由`SetupSessionWindow`hook承接。
- NewPlayer改用`TutorialWalk_Frame`、`STRAFELEFT／STRAFERIGHT`與`TutorialSingleKey_Frame`；Transmog補`PreviewedWeaponToggle.Checkbox`、`SecondaryAppearanceToggle.Checkbox`與`WeaponSheatheDropdown`。
- `InitiativeTasksObjectiveTracker`納入ObjectiveTracker header／block／progress／timer通用skin lifecycle。
- Expansion Landing停止掃不存在的Dragonriding child，改在`RefreshExpansionOverlay`後處理動態Midnight `overlayFrame`；EncounterJournal Journeys補固定Border、buttons、scrollbar與pooled Renown watch checkbox。

## Dead theme與載入清理

- `Blizzard_Delves.lua`只移除不存在的`Blizzard_DelvesDashboardUI`theme，保留同檔有效Delves themes與XML載入。
- 刪除MAINLINE不存在的`Blizzard_TalentUI.lua`、`Blizzard_VoidStorageUI.lua`及對應AddOns XML Script。
- `Blizzard_MajorFactions`addon key本身仍存在，但Aurora唯一目標`MajorFactionRenownFrame`已消失；刪除該Aurora module／XML Script，現行外觀責任由EncounterJournal Journeys承接。
- `Blizzard_Tutorial`仍保留為未實作候選；是否改寫至`Blizzard_BoostTutorial`見`todo.md`。

## 已確認不擴大的邊界

- `Init.lua` initial scan的`loadedOrLoading`＋`loaded`雙回傳判斷與Blizzard完成載入契約一致，不另加bootstrap-only workaround。
- Communities 12.1 Discord／friend-request source差異沒有新增獨立widget/template，不為資料層變更新增consumer。
- Cooldown drag在theme前已存在的匿名singleton沒有公開安全lookup；維持Blizzard原生外觀，`/reload`後由正常建立路徑恢復Aurora skin。
- WoWUI Housing Initiatives仍有指向舊HouseDropdown的HelpTip anchor，屬Blizzard source stale reference，不在Aurora接管。
- Transmog Situations `Init`hook可由現行`OnShow()`反覆命中，不列為漏掉初始化。

## 靜態驗證狀態

- 已逐項核對主要12.1變更的Blizzard TOC／XML／Mixin、theme key、pool lifecycle與source契約；本次六項NDui_EK差異另以WoWUI live 12.1.0.69497重查實際template、caller與event owner。新模組已同步列入`AddOns.xml`，三個刪除模組的XML項目已移除。
- 已搜尋六個舊結構path、dead theme／target、deprecated GMChat alias及secret consumer殘留；沒有發現另一個已確認的結構性hard blocker。
- 目前沒有可用`lua`／`luac`／`luacheck`；Lua只完成完整作用域、caller、載入與diff人工檢查。
- 整體`git diff --check`已通過；Windows工作樹仍可能提示LF之後會轉CRLF，該提示不是whitespace error。

## 正式服驗證邊界

- 基本：關閉「Load out of date AddOns」冷登入、`/reload`、`/dump select(4, GetBuildInfo()) == 120100`。
- LoD：Aurora先載入後首次開每個Blizzard addon；Blizzard addon已載入後才載入／重載Aurora。
- blockers：Battle.net invite與ChatFrame後半、`/rw`／boss emote pool、Achievement搜尋／comparison、Brann四slot、Housing dropdown／頁面、Great Vault concessions／選獎。
- pool／ScrollBox：搜尋、篩選、分頁、ReleaseAll／reacquire、資料切換與高速捲動；重點為SocialUI、Communities、CooldownViewer、Delves、Housing budget、Journeys與Weekly Rewards。
- secret／secure：restricted target aura、AuraContainer tooltip、chat messaging lockdown roster、voice notification、secure drag、戰鬥中開啟／刷新與離戰恢復。
- GUI／core：ChatBubbles false／true兩向reload、Shadow=false＋VenturePlan、FontScale多次reload不累乘、Alert pool reuse。
- Social／Guild：新版SocialUI待runtime gate重新開啟；legacy路徑中使用者已確認修正後按`O`不再出現rank nil錯誤，仍需測guild leader新增／刪除／移動rank、Permissions／Bank／Discord往返與21項權限。
- Communities avatar：反覆捲動／刷新community cards、切換guild／community invitation及主社群列表重用，確認原生avatar可更新且Aurora border無殘影。
- PlayerChoice：開啟grid layout，點選option後確認root buttons立即套skin；再切換選項／分頁／重開，確認pool release／reacquire不漏skin。
- DamageMeter：測初始minimized／expanded、切換最小化、local player entry顯示／隱藏、建立第二／第三session window及Edit Mode拖到螢幕邊緣，確認原生clamp與背景anchors正常。
- Achievement／Transmog：測Achievement搜尋、comparison與Back；Transmog切換secondary appearance及weapon sheathe dropdown，確認新controls有skin且原生layout未被改錨。
- Maw buffs：在Torghast／可顯示MAW aura場景及戰鬥內觸發`UNIT_AURA`，確認維持Blizzard原生外觀且沒有taint、blocked action或Lua error。
- AuraContainer：Tooltips true／false兩向reload、helpful／harmful aura hover、換target／button reuse與restricted combat，確認無Lua error、taint或blocked action。
