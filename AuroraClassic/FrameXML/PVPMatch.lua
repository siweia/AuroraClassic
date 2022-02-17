local _, ns = ...
local F, C = unpack(ns)

tinsert(C.defaultThemes, function()

	-- ready dialog
	local PVPReadyDialog = PVPReadyDialog

	F.StripTextures(PVPReadyDialog)
	PVPReadyDialogBackground:Hide()
	F.SetBD(PVPReadyDialog)
	PVPReadyDialogRoleIconTexture:SetTexture(C.rolesTex)
	F.CreateBDFrame(PVPReadyDialogRoleIcon)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, _, _, role)
		if self.roleIcon:IsShown() then
			self.roleIcon.texture:SetTexCoord(F.GetRoleTexCoord(role))
		end
	end)

	F.Reskin(PVPReadyDialog.enterButton)
	F.Reskin(PVPReadyDialog.leaveButton)
	F.ReskinClose(PVPReadyDialogCloseButton)

	local function stripBorders(self)
		F.StripTextures(self)
	end

	if C.isNewPatch then
		ReadyStatus.Border:SetAlpha(0)
		F.SetBD(ReadyStatus)
		F.ReskinClose(ReadyStatus.CloseButton)
	end

	-- match score
	F.SetBD(PVPMatchScoreboard)
	PVPMatchScoreboard:HookScript("OnShow", stripBorders)
	F.ReskinClose(PVPMatchScoreboard.CloseButton)

	local content = PVPMatchScoreboard.Content
	local tabContainer = content.TabContainer

	F.StripTextures(content)
	local bg = F.CreateBDFrame(content, .25)
	bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
	F.ReskinScroll(content.ScrollFrame.ScrollBar)

	F.StripTextures(tabContainer)
	for i = 1, 3 do
		F.ReskinTab(tabContainer.TabGroup["Tab"..i])
	end

	-- match results
	F.SetBD(PVPMatchResults)
	PVPMatchResults:HookScript("OnShow", stripBorders)
	F.ReskinClose(PVPMatchResults.CloseButton)
	F.StripTextures(PVPMatchResults.overlay)

	local content = PVPMatchResults.content
	local tabContainer = content.tabContainer

	F.StripTextures(content)
	local bg = F.CreateBDFrame(content, .25)
	bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
	F.StripTextures(content.earningsArt)
	F.ReskinScroll(content.scrollFrame.scrollBar)

	F.StripTextures(tabContainer)
	for i = 1, 3 do
		F.ReskinTab(tabContainer.tabGroup["tab"..i])
	end

	local buttonContainer = PVPMatchResults.buttonContainer
	F.Reskin(buttonContainer.leaveButton)
	F.Reskin(buttonContainer.requeueButton)
end)