local _, ns = ...
local B, C, L, DB = unpack(ns)

local r, g, b = DB.r, DB.g, DB.b
local select, pairs = select, pairs

local function reskinQuestIcon(button)
	if not button then return end
	if not button.SetNormalTexture then return end

	if not button.styled then
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		local icon = button.icon or button.Icon
		if icon then
			button.bg = B.ReskinIcon(icon, true)
		end

		button.styled = true
	end

	if button.bg then
		button.bg:SetFrameLevel(0)
	end
end

local function reskinQuestIcons(_, block)
	reskinQuestIcon(block.ItemButton)
	reskinQuestIcon(block.rightEdgeFrame)
end

local function reskinHeader(header)
	header.Text:SetTextColor(r, g, b)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(r, g, b, .8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

local function reskinBarTemplate(bar)
	if bar.bg then return end

	B.StripTextures(bar)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetStatusBarColor(r, g, b)
	bar.bg = B.SetBD(bar)
end

local function reskinBar(self, key)
	local progressBar = self.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar

	if bar and not bar.bg then
		reskinBarTemplate(bar)
	end

	local icon = bar.Icon
	if icon then
		if not icon.bg then			
			icon:SetMask("")
			icon.bg = B.ReskinIcon(icon, true)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 5, 0)
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 25, 0)
		end
	
		if icon.bg then
			icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
		end
	end
end

local function reskinTimer(self, key)
	local timerBar = self.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if bar and not bar.bg then
		reskinBarTemplate(bar)
	end
end

local function updateMinimizeButton(button, collapsed)
	button = button.MinimizeButton
	button.__texture:DoCollapse(collapsed)
end

local function reskinMinimizeButton(button, header)
	B.ReskinCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.__texture:DoCollapse(false)
	if header.SetCollapsed then
		hooksecurefunc(header, "SetCollapsed", updateMinimizeButton)
	end
end

tinsert(C.defaultThemes, function()
	if not AuroraClassicDB.ObjectiveTracker then return end
	if C_AddOns.IsAddOnLoaded("!KalielsTracker") then return end

	-- Reskin Headers
	local mainHeader = ObjectiveTrackerFrame.Header
	B.StripTextures(mainHeader) -- main header looks simple this way

	-- Minimize Button
	local mainMinimize = mainHeader.MinimizeButton
	reskinMinimizeButton(mainMinimize, mainHeader)
	mainMinimize.bg:SetBackdropBorderColor(1, .8, 0, .5)

	local trackers = {
		ScenarioObjectiveTracker,
		UIWidgetObjectiveTracker,
		CampaignQuestObjectiveTracker,	
		QuestObjectiveTracker,
		AdventureObjectiveTracker,
		AchievementObjectiveTracker,
		MonthlyActivitiesObjectiveTracker,
		InitiativeTasksObjectiveTracker,
		ProfessionsRecipeTracker,
		BonusObjectiveTracker,
		WorldQuestObjectiveTracker,
	}
	for _, tracker in pairs(trackers) do
		reskinHeader(tracker.Header)
		hooksecurefunc(tracker, "AddBlock", reskinQuestIcons)
		hooksecurefunc(tracker, "GetProgressBar", reskinBar)
		hooksecurefunc(tracker, "GetTimerBar", reskinTimer)
	end

	-- Handle blocks, untest
	hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = B.SetBD(block.GlowTexture, nil, 0, -2, 4, 2)
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateWidgetRegistration", function(self)
		local widgetContainer = self.WidgetContainer
		if widgetContainer.widgetFrames then
			for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
				if widgetFrame.Frame then widgetFrame.Frame:SetAlpha(0) end

				local bar = widgetFrame.TimerBar
				if bar and not bar.bg then
					bar.bg = B.CreateBDFrame(bar, .25)
				end

				if widgetFrame.CurrencyContainer then
					for currencyFrame in widgetFrame.currencyPool:EnumerateActive() do
						if not currencyFrame.bg then
							currencyFrame.bg = B.ReskinIcon(currencyFrame.Icon)
						end
					end
				end
			end
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "SetUpAffixes", function(self)
		for frame in self.affixPool:EnumerateActive() do
			frame.Border:SetTexture(nil)
			frame.Portrait:SetTexture(nil)
			if not frame.bg then
				frame.bg = B.ReskinIcon(frame.Portrait)
			end

			if frame.info then
				frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
			elseif frame.affixID then
				local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
				frame.Portrait:SetTexture(filedataid)
			end
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "Activate", function(block)
		if not block.bg then
			block.TimerBG:Hide()
			block.TimerBGBack:Hide()
			block.timerbg = B.CreateBDFrame(block.TimerBGBack, .3)
			block.timerbg:SetPoint("TOPLEFT", block.TimerBGBack, 6, -2)
			block.timerbg:SetPoint("BOTTOMRIGHT", block.TimerBGBack, -6, -5)

			block.StatusBar:SetStatusBarTexture(DB.normTex)
			block.StatusBar:SetStatusBarColor(r, g, b)
			block.StatusBar:SetHeight(10)

			select(3, block:GetRegions()):Hide()
			block.bg = B.SetBD(block, nil, 4, -2, -4, 0)
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker, "UpdateSpellCooldowns", function(self)
		for spellFrame in self.spellFramePool:EnumerateActive() do
			local spellButton = spellFrame.SpellButton
			if spellButton and not spellButton.styled then
				local bg = B.ReskinIcon(spellButton.Icon)
				spellButton:SetNormalTexture(0)
				spellButton:SetPushedTexture(0)
				local hl = spellButton:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetInside(bg)
	
				spellButton.styled = true
			end
		end
	end)
end)
