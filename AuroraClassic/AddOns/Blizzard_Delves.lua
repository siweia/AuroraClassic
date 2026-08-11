local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinButton(button)
	local icon = button.Icon
	if not icon then return end

	if icon:GetAtlas() then
		icon:ResetTexCoord()
		if button.iconBG then button.iconBG:Hide() end
		return
	end

	if button.Border then button.Border:SetAlpha(0) end
	if button.iconBG then
		icon:SetTexCoord(unpack(DB.TexCoord))
		button.iconBG:Show()
	else
		button.iconBG = B.ReskinIcon(icon)
	end
end

local function updateButton(self)
	self:ForEachFrame(reskinButton)
end

local function reskinOptionSlot(frame)
	local option = frame.OptionsList
	B.StripTextures(option)
	local bg = B.SetBD(option, nil, -5, 5, 5, -5)
	bg:SetFrameLevel(3)
	hooksecurefunc(option.ScrollBox, "Update", updateButton)
	updateButton(option.ScrollBox)
end

C.themes["Blizzard_DelvesCompanionConfiguration"] = function()
	B.ReskinPortraitFrame(DelvesCompanionConfigurationFrame)
	B.Reskin(DelvesCompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

	local companionSlots = DelvesCompanionConfigurationFrame.CompanionSlots
	reskinOptionSlot(companionSlots.CompanionCombatRoleSlot)
	reskinOptionSlot(companionSlots.CompanionFlavorSlot)
	reskinOptionSlot(companionSlots.CompanionCombatTrinketSlot)
	reskinOptionSlot(companionSlots.CompanionUtilityTrinketSlot)

	B.ReskinPortraitFrame(DelvesCompanionAbilityListFrame)
	B.ReskinDropDown(DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
	B.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton, "left")
	B.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton, "right")

	hooksecurefunc(DelvesCompanionAbilityListFrame, "UpdatePaginatedButtonDisplay", function(self)
		for _, button in pairs(self.buttons) do
			if not button.styled then
				if button.Icon then B.ReskinIcon(button.Icon) end

				button.styled = true
			end
		end
	end)
end

C.themes["Blizzard_DelvesDashboardUI"] = function()
	DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
	B.Reskin(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

local function handleReward(rewardFrame)
	if not rewardFrame.bg then
		B.CreateBDFrame(rewardFrame, .25)
		rewardFrame.NameFrame:SetAlpha(0)
		rewardFrame.bg = B.ReskinIcon(rewardFrame.Icon)
		B.ReskinIconBorder(rewardFrame.IconBorder, true)
	end
end

C.themes["Blizzard_DelvesDifficultyPicker"] = function()
	B.ReskinPortraitFrame(DelvesDifficultyPickerFrame)
	B.ReskinDropDown(DelvesDifficultyPickerFrame.Dropdown)
	B.Reskin(DelvesDifficultyPickerFrame.EnterDelveButton)

	hooksecurefunc(DelvesDifficultyPickerFrame.DelveRewardsContainerFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(handleReward)
	end)
end
