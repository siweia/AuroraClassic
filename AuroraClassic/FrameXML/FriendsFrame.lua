local _, ns = ...
local B, C, L, DB = unpack(ns)

local atlasToTex = {
	["friendslist-invitebutton-horde-normal"] = "Interface\\FriendsFrame\\PlusManz-Horde",
	["friendslist-invitebutton-alliance-normal"] = "Interface\\FriendsFrame\\PlusManz-Alliance",
	["friendslist-invitebutton-default-normal"] = "Interface\\FriendsFrame\\PlusManz-PlusManz",
}
local function replaceInviteTex(self, atlas)
	local tex = atlasToTex[atlas]
	if tex then
		self.ownerIcon:SetTexture(tex)
	end
end

local function keepSocialCardBackground(texture)
	texture:SetColorTexture(0, 0, 0, .25)
end

local function reskinSocialScrollElement(element)
	if element.__auroraSocialSkinned then return end

	local background = element.Background
	if background then
		keepSocialCardBackground(background)
		hooksecurefunc(background, "SetAtlas", keepSocialCardBackground)
	end

	local normal = element.GetNormalTexture and element:GetNormalTexture()
	if normal then
		normal:SetColorTexture(0, 0, 0, .25)
	end

	local highlight = element.GetHighlightTexture and element:GetHighlightTexture()
	if highlight then
		highlight:SetColorTexture(.24, .56, 1, .2)
	end
	if element.Highlight then
		element.Highlight:SetColorTexture(.24, .56, 1, .2)
	end
	if element.Selected then
		element.Selected:SetColorTexture(.24, .56, 1, .35)
	end

	if element.AcceptButton then
		B.Reskin(element.AcceptButton)
	end
	if element.DeclineButton then
		local decline = element.DeclineButton
		decline:SetNormalTexture(DB.closeTex)
		decline:GetNormalTexture():SetVertexColor(1, 0, 0)
		decline:SetHighlightTexture(DB.closeTex)
		decline:GetHighlightTexture():SetVertexColor(1, .2, .2)
	end

	local partyButton = element.PartyButton
	if partyButton and partyButton.ActionIcon then
		B.Reskin(partyButton, true)
	end
	local summonButton = element.RAFSummonButton
	if summonButton and summonButton.ActionIcon then
		B.Reskin(summonButton, true)
	end

	element.__auroraSocialSkinned = true
end

local function reskinSocialScrollBox(scrollBox)
	if scrollBox.__auroraSocialSkinCallback then return end

	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnInitializedFrame, function(_, element)
		reskinSocialScrollElement(element)
	end, scrollBox)
	scrollBox:ForEachFrame(reskinSocialScrollElement)
	scrollBox.__auroraSocialSkinCallback = true
end

local function reskinSocialContent(frame)
	if frame.__auroraSocialSkinned then return end

	local filterBar = frame.FilterBar
	if filterBar then
		B.ReskinInput(filterBar.SearchBar)
		B.ReskinDropDown(filterBar.SearchFilterDropdown)
	end

	if frame.TopDivider then
		frame.TopDivider:SetColorTexture(1, 1, 1, .25)
	end
	if frame.BottomDivider then
		frame.BottomDivider:SetColorTexture(1, 1, 1, .25)
	end
	if frame.ActionButton then
		B.Reskin(frame.ActionButton)
	end
	if frame.ScrollBar then
		B.ReskinTrimScroll(frame.ScrollBar)
	end
	if frame.ScrollBox then
		reskinSocialScrollBox(frame.ScrollBox)
	end

	local warning = frame.RealIDWarning
	if warning then
		B.Reskin(warning.ContinueButton)
		B.ReskinTrimScroll(warning.ScrollBar)
	end
	if frame.NoRecruitsScrollBar then
		B.ReskinTrimScroll(frame.NoRecruitsScrollBar)
	end
	if frame.RewardClaiming then
		B.StripTextures(frame.RewardClaiming)
		B.Reskin(frame.RewardClaiming.ClaimOrViewRewardButton)
	end

	frame.__auroraSocialSkinned = true
end

local function reskinSocialTab(tab)
	if tab.__auroraSocialSkinned then return end

	tab.Background:SetColorTexture(0, 0, 0, .5)
	tab.Background:SetAllPoints()
	tab.SelectedTexture:SetColorTexture(.24, .56, 1, .35)
	tab.SelectedTexture:SetAllPoints()
	tab.HighlightTexture:SetColorTexture(.24, .56, 1, .2)
	tab.HighlightTexture:SetAllPoints()
	tab.TabGlow:SetColorTexture(.24, .56, 1, .5)
	tab.TabGlow:SetAllPoints()

	tab.__auroraSocialSkinned = true
end

local function reskinSocialTabs(frame)
	for tab in frame:EnumerateTabs() do
		reskinSocialTab(tab)
	end
end

C.themes["Blizzard_SocialUI"] = function()
	local frame = SocialUIFrame
	B.ReskinPortraitFrame(frame)

	local battleNetBar = frame.BattleNetBar
	battleNetBar.Background:SetAlpha(0)
	local barBG = B.CreateBDFrame(battleNetBar, .25)
	barBG:SetPoint("TOPLEFT", 2, -4)
	barBG:SetPoint("BOTTOMRIGHT", -2, 4)

	local controls = battleNetBar.ControlsContainer
	controls.BattleNetBackground:SetAlpha(0)
	B.ReskinDropDown(controls.OnlineStatusDropdown)
	B.Reskin(controls.BattleNetMenuButton)

	local unavailable = frame.BattleNetUnavailableNoticeFrame
	B.StripTextures(unavailable.Border)
	B.SetBD(unavailable)

	local broadcast = frame.BattleNetBroadcastFrame
	B.StripTextures(broadcast.Border)
	B.SetBD(broadcast)
	B.ReskinInput(broadcast.EditBox)
	B.Reskin(broadcast.UpdateButton)
	B.Reskin(broadcast.CancelButton)

	local ignoreList = frame.IgnoreListFrame
	B.ReskinPortraitFrame(ignoreList)
	B.StripTextures(ignoreList.Inset)
	B.Reskin(ignoreList.BlockButton)
	B.Reskin(ignoreList.UnblockButton)
	B.ReskinTrimScroll(ignoreList.ScrollBar)
	reskinSocialScrollBox(ignoreList.ScrollBox)

	for _, tabData in pairs(frame.tabDefinitions) do
		if tabData.contentFrame then
			reskinSocialContent(tabData.contentFrame)
		end
	end

	hooksecurefunc(frame, "RefreshTabs", reskinSocialTabs)
	reskinSocialTabs(frame)
end

local function reskinFriendButton(button)
	if not button.styled then
		local gameIcon = button.gameIcon
		gameIcon:SetSize(22, 22)
		button.background:Hide()
		button:SetHighlightTexture(DB.bdTex)
		button:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)

		local travelPass = button.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass:SetPoint("TOPRIGHT", -3, -6)
		B.CreateBDFrame(travelPass, 1)
		travelPass.NormalTexture:SetAlpha(0)
		travelPass.PushedTexture:SetAlpha(0)
		travelPass.DisabledTexture:SetAlpha(0)
		travelPass.HighlightTexture:SetColorTexture(1, 1, 1, .25)
		travelPass.HighlightTexture:SetAllPoints()
		gameIcon:SetPoint("TOPRIGHT", travelPass, "TOPLEFT", -4, 0)

		local icon = travelPass:CreateTexture(nil, "ARTWORK")
		icon:SetTexCoord(.1, .9, .1, .9)
		icon:SetAllPoints()
		button.newIcon = icon
		travelPass.NormalTexture.ownerIcon = icon
		hooksecurefunc(travelPass.NormalTexture, "SetAtlas", replaceInviteTex)

		button.styled = true
	end
end

tinsert(C.defaultThemes, function()
	for i = 1, 4 do
		local tab = _G["FriendsFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
			B.ResetTabAnchor(tab)
			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["FriendsFrameTab"..(i-1)], "TOPRIGHT", -15, 0)
			end
		end
	end
	FriendsFrameIcon:Hide()

	B.StripTextures(FriendsFrame.IgnoreListWindow)
	B.SetBD(FriendsFrame.IgnoreListWindow)
	local closeButton = FriendsFrame.IgnoreListWindow.CloseButton or select(4, FriendsFrame.IgnoreListWindow:GetChildren())
	if closeButton then
		B.ReskinClose(closeButton)
	end
	B.ReskinTrimScroll(FriendsFrame.IgnoreListWindow.ScrollBar)
	B.Reskin(FriendsFrame.IgnoreListWindow.UnignorePlayerButton)

	local INVITE_RESTRICTION_NONE = 9
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.gameIcon then
			reskinFriendButton(button)
		end

		if button.newIcon and button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
				button.newIcon:SetVertexColor(1, 1, 1)
			else
				button.newIcon:SetVertexColor(.5, .5, .5)
			end
		end
	end)

	hooksecurefunc("FriendsFrame_UpdateFriendInviteButton", function(button)
		if not button.styled then
			B.Reskin(button.AcceptButton)
			B.Reskin(button.DeclineButton)

			button.styled = true
		end
	end)

	hooksecurefunc("FriendsFrame_UpdateFriendInviteHeaderButton", function(button)
		if not button.styled then
			button:DisableDrawLayer("BACKGROUND")
			local bg = B.CreateBDFrame(button, .25)
			bg:SetInside(button, 2, 2)
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(.24, .56, 1, .2)
			hl:SetInside(bg)

			button.styled = true
		end
	end)

	-- FriendsFrameBattlenetFrame

	FriendsFrameBattlenetFrame:GetRegions():Hide()
	local bg = B.CreateBDFrame(FriendsFrameBattlenetFrame, .25)
	bg:SetPoint("TOPLEFT", 0, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
	bg:SetBackdropColor(0, .6, 1, .25)

	local menuButton = FriendsFrameBattlenetFrame.ContactsMenuButton
	if menuButton then
		B.ReskinArrow(menuButton, "down")
		menuButton.Icon:Hide()
		menuButton:SetSize(22, 22)
	end

	local broadcastFrame = FriendsFrameBattlenetFrame.BroadcastFrame
	B.StripTextures(broadcastFrame)
	B.SetBD(broadcastFrame, nil, 10, -10, -10, 10)
	broadcastFrame.EditBox:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBDFrame(broadcastFrame.EditBox, 0, true)
	bg:SetPoint("TOPLEFT", -2, -2)
	bg:SetPoint("BOTTOMRIGHT", 2, 2)
	B.Reskin(broadcastFrame.UpdateButton)
	B.Reskin(broadcastFrame.CancelButton)
	broadcastFrame:ClearAllPoints()
	broadcastFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 3, 0)

	local unavailableFrame = FriendsFrameBattlenetFrame.UnavailableInfoFrame
	B.StripTextures(unavailableFrame)
	B.SetBD(unavailableFrame)
	unavailableFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 3, -18)

	B.ReskinPortraitFrame(FriendsFrame)
	B.Reskin(FriendsFrameAddFriendButton)
	B.Reskin(FriendsFrameSendMessageButton)
	B.ReskinTrimScroll(FriendsListFrame.ScrollBar)
	B.ReskinTrimScroll(WhoFrame.ScrollBar)
	B.ReskinTrimScroll(FriendsFriendsFrame.ScrollBar)
	B.ReskinDropDown(FriendsFrameStatusDropdown)
	B.ReskinDropDown(WhoFrameDropdown)
	B.ReskinDropDown(FriendsFriendsFrameDropdown)
	FriendsFrameStatusDropdown:SetWidth(58)
	B.Reskin(FriendsListFrameContinueButton)
	B.ReskinInput(AddFriendNameEditBox)
	B.StripTextures(AddFriendFrame)
	B.SetBD(AddFriendFrame)
	B.StripTextures(FriendsFriendsFrame)
	B.SetBD(FriendsFriendsFrame)
	B.Reskin(FriendsFriendsFrame.SendRequestButton)
	B.Reskin(FriendsFriendsFrame.CloseButton)
	B.Reskin(WhoFrameWhoButton)
	B.Reskin(WhoFrameAddFriendButton)
	B.Reskin(WhoFrameGroupInviteButton)
	B.Reskin(AddFriendEntryFrameAcceptButton)
	B.Reskin(AddFriendEntryFrameCancelButton)

	for i = 1, 4 do
		B.StripTextures(_G["WhoFrameColumnHeader"..i])
	end

	B.StripTextures(WhoFrameListInset)
	WhoFrameEditBox.Backdrop:Hide()
	local whoBg = B.CreateBDFrame(WhoFrameEditBox, 0, true)
	whoBg:SetPoint("TOPLEFT", WhoFrameEditBox, -3, -2)
	whoBg:SetPoint("BOTTOMRIGHT", WhoFrameEditBox, -1, 2)

	for i = 1, 3 do
		local tab = select(i, FriendsTabHeader.TabSystem:GetChildren())
		if tab then
			B.ReskinTab(tab)
		end
	end

	-- Recruite frame

	RecruitAFriendFrame.SplashFrame.Description:SetTextColor(1, 1, 1)
	B.Reskin(RecruitAFriendFrame.SplashFrame.OKButton)
	B.StripTextures(RecruitAFriendFrame.RewardClaiming)
	B.Reskin(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)
	B.Reskin(RecruitAFriendFrame.RecruitmentButton)

	local recruitList = RecruitAFriendFrame.RecruitList
	B.StripTextures(recruitList.Header)
	B.CreateBDFrame(recruitList.Header, .25)
	recruitList.ScrollFrameInset:Hide()
	B.ReskinTrimScroll(recruitList.ScrollBar)

	local recruitmentFrame = RecruitAFriendRecruitmentFrame
	B.StripTextures(recruitmentFrame)
	B.ReskinClose(recruitmentFrame.CloseButton)
	B.SetBD(recruitmentFrame)
	B.StripTextures(recruitmentFrame.EditBox)
	local bg = B.CreateBDFrame(recruitmentFrame.EditBox, .25)
	bg:SetPoint("TOPLEFT", -3, -3)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	B.Reskin(recruitmentFrame.GenerateOrCopyLinkButton)

	local rewardsFrame = RecruitAFriendRewardsFrame
	B.StripTextures(rewardsFrame)
	B.ReskinClose(rewardsFrame.CloseButton)
	B.SetBD(rewardsFrame)

	rewardsFrame:HookScript("OnShow", function(self)
		for i = 1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			local button = child and child.Button
			if button and not button.styled then
				B.ReskinIcon(button.Icon)
				button.IconBorder:Hide()
				button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

				button.styled = true
			end
		end
	end)
end)
