local _, ns = ...
local F, C = unpack(ns)

tinsert(C.defaultThemes, function()
	local restyled = false

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if restyled then return end

		F.StripTextures(InterfaceOptionsFrameCategories)
		F.StripTextures(InterfaceOptionsFramePanelContainer)
		F.StripTextures(InterfaceOptionsFrameAddOns)
		for i = 1, 2 do
			F.StripTextures(_G["InterfaceOptionsFrameTab"..i])
		end
		F.SetBD(InterfaceOptionsFrame)
		InterfaceOptionsFrame.Border:Hide()
		F.StripTextures(InterfaceOptionsFrame.Header)
		InterfaceOptionsFrame.Header:ClearAllPoints()
		InterfaceOptionsFrame.Header:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(C.mult, 546)
		line:SetPoint("LEFT", 205, 10)
		line:SetColorTexture(1, 1, 1, .25)

		local buttons = {
			"InterfaceOptionsFrameDefaults",
			"InterfaceOptionsFrameOkay",
			"InterfaceOptionsFrameCancel",
			"InterfaceOptionsSocialPanelRedockChat",
			"InterfaceOptionsSocialPanelTwitterLoginButton",
			"InterfaceOptionsDisplayPanelResetTutorials",
		}
		for _, buttonName in pairs(buttons) do
			local button = _G[buttonName]
			if button then
				F.Reskin(button)
			end
		end

		local checkboxes = {
			"InterfaceOptionsControlsPanelStickyTargeting",
			"InterfaceOptionsControlsPanelAutoDismount",
			"InterfaceOptionsControlsPanelAutoClearAFK",
			"InterfaceOptionsControlsPanelAutoLootCorpse",
			"InterfaceOptionsControlsPanelInteractOnLeftClick",
			"InterfaceOptionsControlsPanelLootAtMouse",
			"InterfaceOptionsCombatPanelTargetOfTarget",
			"InterfaceOptionsCombatPanelFlashLowHealthWarning",
			"InterfaceOptionsCombatPanelLossOfControl",
			"InterfaceOptionsCombatPanelEnableFloatingCombatText",
			"InterfaceOptionsCombatPanelAutoSelfCast",
			"InterfaceOptionsDisplayPanelRotateMinimap",
			"InterfaceOptionsDisplayPanelAJAlerts",
			"InterfaceOptionsDisplayPanelShowInGameNavigation",
			"InterfaceOptionsDisplayPanelShowTutorials",
			"InterfaceOptionsSocialPanelProfanityFilter",
			"InterfaceOptionsSocialPanelSpamFilter",	-- isNewPatch, removed in 38627
			"InterfaceOptionsSocialPanelGuildMemberAlert",
			"InterfaceOptionsSocialPanelBlockTrades",
			"InterfaceOptionsSocialPanelBlockGuildInvites",
			"InterfaceOptionsSocialPanelBlockChatChannelInvites",
			"InterfaceOptionsSocialPanelShowAccountAchievments",
			"InterfaceOptionsSocialPanelOnlineFriends",
			"InterfaceOptionsSocialPanelOfflineFriends",
			"InterfaceOptionsSocialPanelBroadcasts",
			"InterfaceOptionsSocialPanelFriendRequests",
			"InterfaceOptionsSocialPanelShowToastWindow",
			"InterfaceOptionsSocialPanelEnableTwitter",
			"InterfaceOptionsSocialPanelAutoAcceptQuickJoinRequests",
			"InterfaceOptionsActionBarsPanelBottomLeft",
			"InterfaceOptionsActionBarsPanelBottomRight",
			"InterfaceOptionsActionBarsPanelRight",
			"InterfaceOptionsActionBarsPanelRightTwo",
			"InterfaceOptionsActionBarsPanelStackRightBars",
			"InterfaceOptionsActionBarsPanelLockActionBars",
			"InterfaceOptionsActionBarsPanelAlwaysShowActionBars",
			"InterfaceOptionsActionBarsPanelCountdownCooldowns",
			"InterfaceOptionsNamesPanelMyName",
			"InterfaceOptionsNamesPanelNonCombatCreature",
			"InterfaceOptionsNamesPanelFriendlyPlayerNames",
			"InterfaceOptionsNamesPanelFriendlyMinions",
			"InterfaceOptionsNamesPanelEnemyPlayerNames",
			"InterfaceOptionsNamesPanelEnemyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesPersonalResource",
			"InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy",
			"InterfaceOptionsNamesPanelUnitNameplatesMakeLarger",
			"InterfaceOptionsNamesPanelUnitNameplatesShowAll",
			"InterfaceOptionsNamesPanelUnitNameplatesAggroFlash",
			"InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemies",
			"InterfaceOptionsNamesPanelUnitNameplatesFriends",
			"InterfaceOptionsCameraPanelWaterCollision",
			"InterfaceOptionsMousePanelInvertMouse",
			"InterfaceOptionsMousePanelEnableMouseSpeed",
			"InterfaceOptionsMousePanelClickToMove",
			"InterfaceOptionsMousePanelLockCursorToScreen",
			"InterfaceOptionsAccessibilityPanelMovePad",
			"InterfaceOptionsAccessibilityPanelCinematicSubtitles",
			"InterfaceOptionsAccessibilityPanelOverrideFadeOut",
			"InterfaceOptionsAccessibilityPanelColorblindMode",
		}
		if C.isNewPatch then
			tinsert(checkboxes, "InterfaceOptionsAccessibilityPanelSpeechToText")
			tinsert(checkboxes, "InterfaceOptionsAccessibilityPanelTextToSpeech")
			tinsert(checkboxes, "InterfaceOptionsAccessibilityPanelRemoteTextToSpeech")
			tremove(checkboxes, 17)
		end
		for _, boxName in pairs(checkboxes) do
			local checkbox = _G[boxName]
			if checkbox then
				F.ReskinCheck(checkbox)
			end
		end

		local dropdowns = {
			"InterfaceOptionsControlsPanelAutoLootKeyDropDown",
			"InterfaceOptionsCombatPanelFocusCastKeyDropDown",
			"InterfaceOptionsCombatPanelSelfCastKeyDropDown",
			"InterfaceOptionsDisplayPanelOutlineDropDown",
			"InterfaceOptionsDisplayPanelSelfHighlightDropDown",
			"InterfaceOptionsDisplayPanelDisplayDropDown",
			"InterfaceOptionsDisplayPanelChatBubblesDropDown",
			"InterfaceOptionsSocialPanelChatStyle",
			"InterfaceOptionsSocialPanelTimestamps",
			"InterfaceOptionsSocialPanelWhisperMode",
			"InterfaceOptionsActionBarsPanelPickupActionKeyDropDown",
			"InterfaceOptionsNamesPanelNPCNamesDropDown",
			"InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown",
			"InterfaceOptionsCameraPanelStyleDropDown",
			"InterfaceOptionsMousePanelClickMoveStyleDropDown",
			"InterfaceOptionsAccessibilityPanelColorFilterDropDown",
			"InterfaceOptionsAccessibilityPanelMotionSicknessDropdown",
			"InterfaceOptionsAccessibilityPanelShakeIntensityDropdown",
		}
		for _, ddName in pairs(dropdowns) do
			local dropdown = _G[ddName]
			if dropdown then
				F.ReskinDropDown(dropdown)
			end
		end

		local sliders = {
			"InterfaceOptionsCombatPanelSpellAlertOpacitySlider",
			"InterfaceOptionsCameraPanelFollowSpeedSlider",
			"InterfaceOptionsMousePanelMouseSensitivitySlider",
			"InterfaceOptionsMousePanelMouseLookSpeedSlider",
			"InterfaceOptionsAccessibilityPanelColorblindStrengthSlider",
		}
		for _, sliderName in pairs(sliders) do
			local slider = _G[sliderName]
			if slider then
				F.ReskinSlider(slider)
			end
		end

		if IsAddOnLoaded("Blizzard_CUFProfiles") then
			CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()

			local boxes = {
				"CompactUnitFrameProfilesRaidStylePartyFrames",
				"CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether",
				"CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight",
				"CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder",
				"CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec3",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec4",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE",
			}
			for _, boxName in pairs(boxes) do
				local checkbox = _G[boxName]
				if checkbox then
					F.ReskinCheck(checkbox)
				end
			end

			F.Reskin(CompactUnitFrameProfilesSaveButton)
			F.Reskin(CompactUnitFrameProfilesDeleteButton)
			F.Reskin(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
			F.ReskinDropDown(CompactUnitFrameProfilesProfileSelector)
			F.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown)
			F.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown)
			F.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider)
			F.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider)
		end

		restyled = true
	end)

	hooksecurefunc("InterfaceOptions_AddCategory", function()
		local num = #INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, num do
			local bu = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]
			if bu and not bu.styled then
				F.ReskinCollapse(bu)
				bu:GetPushedTexture():SetAlpha(0)

				bu.styled = true
			end
		end
	end)
end)