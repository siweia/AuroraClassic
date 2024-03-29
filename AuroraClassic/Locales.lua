local B, C, L = unpack(select(2, ...))

local locale = GetLocale()

if locale == "zhCN" then
	L["Features"] = "模块"
	L["Bags"] = "背包"
	L["ChatBubbles"] = "聊天泡泡"
	L["Loot"] = "拾取框"
	L["Tooltips"] = "鼠标提示框"
	L["Shadow Border"] = "阴影边框"
	L["Appearance"] = "外观"
	L["Replace default game fonts"] = "全局字体黑色描边"
	L["FlatMode"] = "扁平风格按键"
	L["Opacity"] = "背景透明度*"
	L["Reload Text"] = "不带星号(*)的设置需要重载插件后生效。"
	L["FontScale"] = "字体缩放"
	L["ObjectiveTracker"] = "任务追踪"
elseif locale == "zhTW" then
	L["Features"] = "模塊"
	L["Bags"] = "背包"
	L["ChatBubbles"] = "聊天泡泡"
	L["Loot"] = "拾取框"
	L["Tooltips"] = "滑鼠提示框"
	L["Shadow Border"] = "陰影邊框"
	L["Appearance"] = "外觀"
	L["Replace default game fonts"] = "全局字體黑色描邊"
	L["FlatMode"] = "扁平風格按鍵"
	L["Opacity"] = "背景透明度*"
	L["Reload Text"] = "不帶星標(*)的設置需要重載插件後生效。"
	L["FontScale"] = "字體縮放"
	L["ObjectiveTracker"] = "任務追蹤"
else
	L["Features"] = "Features"
	L["Bags"] = "Bags"
	L["ChatBubbles"] = "Chat Bubbles"
	L["Loot"] = "Loot Frame"
	L["Tooltips"] = "Tooltips"
	L["Shadow Border"] = "Shadow Border"
	L["Appearance"] = "Appearance"
	L["Replace default game fonts"] = "Global Font Outline"
	L["FlatMode"] = "Flat Mode Button"
	L["Opacity"] = "Backdrop Opactiy*"
	L["Reload Text"] = "Settings not marked with an asterisk (*) require a UI reload."
	L["FontScale"] = "Font Scale"
	L["ObjectiveTracker"] = "ObjectiveTracker"
end