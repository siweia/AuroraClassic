local _, ns = ...
local F, C = unpack(ns)

C.themes["Blizzard_NewPlayerExperience"] = function()
	F.Reskin(KeyboardMouseConfirmButton)
	NPE_TutorialWalk_Frame.ContainerFrame.TURNLEFT.KeyBind:SetTextColor(1, .8, 0)
	NPE_TutorialWalk_Frame.ContainerFrame.TURNRIGHT.KeyBind:SetTextColor(1, .8, 0)
	NPE_TutorialWalk_Frame.ContainerFrame.MOVEFORWARD.KeyBind:SetTextColor(1, .8, 0)
	NPE_TutorialWalk_Frame.ContainerFrame.MOVEBACKWARD.KeyBind:SetTextColor(1, .8, 0)
	NPE_TutorialSingleKey_Frame.ContainerFrame.KeyBind.KeyBind:SetTextColor(1, .8, 0)
end

C.themes["Blizzard_NewPlayerExperienceGuide"] = function()
	local GuideFrame = GuideFrame

	F.ReskinPortraitFrame(GuideFrame)
	GuideFrame.Title:SetTextColor(1, .8, 0)
	GuideFrame.ScrollFrame.Child.Text:SetTextColor(1, 1, 1)
	F.ReskinScroll(GuideFrame.ScrollFrame.ScrollBar)
	F.Reskin(GuideFrame.ScrollFrame.ConfirmationButton)
end