local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinHouseInfoTabs(self)
	if not self.tabsInitialized then return end

	for _, tab in ipairs(self.TabSystem.tabs) do
		if not tab.__auroraStyled then
			B.ReskinTab(tab)
			tab.__auroraStyled = true
		end
	end
end

local function reskinBlueprintSummary(summary)
	if summary.__auroraStyled then return end

	local budgets = summary.BudgetsContainer
	budgets.Background:SetAlpha(0)
	B.CreateBDFrame(budgets, .25)
	B.Reskin(summary.ContentsListButton)
	summary.__auroraStyled = true
end

C.themes["Blizzard_HousingDashboard"] = function()
	B.ReskinPortraitFrame(HousingDashboardFrame)
	B.Reskin(HousingDashboardFrame.HouseInfoContent.HouseFinderButton)
	B.ReskinDropDown(HousingDashboardFrame.HouseDropdown.Dropdown)
	B.ReskinCheck(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.WatchFavorButton)
	B.Reskin(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.NoHouseButton)

	B.ReskinEditBox(HousingDashboardFrame.CatalogContent.SearchBox)
	B.ReskinFilterButton(HousingDashboardFrame.CatalogContent.Filters.FilterDropdown)
	B.ReskinTrimScroll(HousingDashboardFrame.CatalogContent.OptionsContainer.ScrollBar)

	local collection = HousingDashboardFrame.CollectionContent
	B.StripTextures(collection)
	B.ReskinTrimScroll(collection.BlueprintCollection.ScrollBar)
	B.Reskin(collection.BlueprintDetails.GearDropdown, true)
	reskinBlueprintSummary(collection.BlueprintDetails.ContentSummary)

	local contentFrame = HousingDashboardFrame.HouseInfoContent.ContentFrame
	local initiatives = contentFrame.InitiativesFrame.InitiativeSetFrame
	B.ReskinTrimScroll(initiatives.InitiativeTasks.ScrollBar)
	B.ReskinTrimScroll(initiatives.InitiativeActivity.ScrollBar)
	B.Reskin(initiatives.InitiativeActiveNeighborhoodSwitcher.SwitchActiveNeighborhoodBtn)

	hooksecurefunc(contentFrame, "UpdateTabs", reskinHouseInfoTabs)
	reskinHouseInfoTabs(contentFrame)
end

C.themes["Blizzard_HousingModelPreview"] = function()
	B.StripTextures(HousingModelPreviewFrame)
	B.SetBD(HousingModelPreviewFrame)
	B.ReskinClose(HousingModelPreviewFrame.CloseButton)
end

C.themes["Blizzard_HousingCreateNeighborhood"] = function()
	local guildNeighbor = HousingCreateGuildNeighborhoodFrame
	if guildNeighbor then
		B.StripTextures(guildNeighbor)
		B.SetBD(guildNeighbor)
		B.Reskin(guildNeighbor.ConfirmButton)
		B.Reskin(guildNeighbor.CancelButton)
		B.ReskinEditBox(guildNeighbor.NeighborhoodNameEditBox)
	end

	local confirmFrame = guildNeighbor.ConfirmationFrame
	if confirmFrame then
		B.Reskin(confirmFrame.ConfirmButton)
		B.Reskin(confirmFrame.CancelButton)
	end

	local charterFrame = HousingCreateNeighborhoodCharterFrame
	if charterFrame then
		B.StripTextures(charterFrame)
		B.SetBD(charterFrame)
		B.ReskinEditBox(charterFrame.NeighborhoodNameEditBox)
		B.Reskin(charterFrame.ConfirmButton)
		B.Reskin(charterFrame.CancelButton)
	end
end

C.themes["Blizzard_HousingCharter"] = function()
	local frame = HousingCharterFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.Reskin(frame.RequestButton)
		B.Reskin(frame.SettingsButton)
		B.Reskin(frame.CloseButton)
	end
end

C.themes["Blizzard_HousingCornerstone"] = function()
	local frame = HousingCornerstonePurchaseFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.Reskin(frame.BuyButton)
		B.ReskinClose(frame.CloseButton)
		B.StripTextures(frame.MoneyFrameBackdrop)
		B.CreateBDFrame(frame.MoneyFrameBackdrop, .25)
	end

	local frame = HousingCornerstoneVisitorFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.ReskinClose(frame.CloseButton)
	end
end
