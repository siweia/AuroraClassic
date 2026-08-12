local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_NewPlayerExperience"] = function()
	B.Reskin(KeyboardMouseConfirmButton)
	TutorialWalk_Frame.ContainerFrame.STRAFELEFT.KeyBind:SetTextColor(1, .8, 0)
	TutorialWalk_Frame.ContainerFrame.STRAFERIGHT.KeyBind:SetTextColor(1, .8, 0)
	TutorialWalk_Frame.ContainerFrame.MOVEFORWARD.KeyBind:SetTextColor(1, .8, 0)
	TutorialWalk_Frame.ContainerFrame.MOVEBACKWARD.KeyBind:SetTextColor(1, .8, 0)
	TutorialSingleKey_Frame.ContainerFrame.KeyBind.KeyBind:SetTextColor(1, .8, 0)
end

C.themes["Blizzard_NewPlayerExperienceGuide"] = function()
	local GuideFrame = GuideFrame

	B.ReskinPortraitFrame(GuideFrame)
	GuideFrame.Title:SetTextColor(1, .8, 0)
	GuideFrame.ScrollFrame.Child.Text:SetTextColor(1, 1, 1)
	B.ReskinTrimScroll(GuideFrame.ScrollFrame.ScrollBar)
	B.Reskin(GuideFrame.ScrollFrame.ConfirmationButton)
end
