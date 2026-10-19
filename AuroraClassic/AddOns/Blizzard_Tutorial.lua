local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BoostTutorial"] = function()
	local tutorialFrame = NPE_TutorialKeyboardMouseFrame_Frame
	tutorialFrame.NineSlice:Hide()
	tutorialFrame.Bg:Hide()
	tutorialFrame.TopTileStreaks:Hide()
	tutorialFrame:GetPortrait():SetAlpha(0)
	B.SetBD(tutorialFrame)
	B.ReskinClose(tutorialFrame.CloseButton)
	NPE_TutorialKeyString:SetTextColor(1, 1, 1)
end