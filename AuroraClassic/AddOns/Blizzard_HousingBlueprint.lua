local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinGearDropdown(button)
	if button.__auroraStyled then return end

	B.Reskin(button, true)
	button.__auroraStyled = true
end

local function reskinContentSummary(summary)
	if summary.__auroraStyled then return end

	local budgets = summary.BudgetsContainer
	budgets.Background:SetAlpha(0)
	B.CreateBDFrame(budgets, .25)
	B.Reskin(summary.ContentsListButton)
	summary.__auroraStyled = true
end

local function reskinBudgetEntries(self)
	for entry in self.budgetEntryPool:EnumerateActive() do
		if not entry.__auroraStyled then
			entry.Icon.bg = B.CreateBDFrame(entry.Icon, .25)
			entry.__auroraStyled = true
		end
	end
end

C.themes["Blizzard_HousingBlueprint"] = function()
	local frame = HousingBlueprintImportFrame
	B.StripTextures(frame)
	local frameBG = B.SetBD(frame)
	frameBG.ignoreInLayout = true
	B.ReskinClose(frame.CloseButton)

	local input = frame.InputContent
	B.ReskinEditBox(input.ShareCodeBox)
	B.Reskin(input.NextButton)
	reskinGearDropdown(input.GearDropdown)

	local validation = frame.ValidationContent
	B.Reskin(validation.ImportButton)
	reskinGearDropdown(validation.GearDropdown)
	reskinContentSummary(validation.ContentSummary)

	hooksecurefunc(HousingBlueprintBudgetsContainerMixin, "SetInfo", reskinBudgetEntries)
	reskinBudgetEntries(validation.ContentSummary.BudgetsContainer)

	if HousingDashboardFrame then
		local dashboardBudgets = HousingDashboardFrame.CollectionContent.BlueprintDetails.ContentSummary.BudgetsContainer
		reskinBudgetEntries(dashboardBudgets)
	end
end
