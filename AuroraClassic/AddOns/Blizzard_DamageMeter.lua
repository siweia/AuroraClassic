local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateButtonState(button)
	button.Icon:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
	button.Icon:SetInside(nil, 2, 2)
	if button:IsOver() then
		button.Icon:SetVertexColor(1, .8, 0)
	else
		button.Icon:SetVertexColor(1, 1, 1)
	end
end

local function updateBGAlpha(self, alpha)
	self.bg:SetAlpha(alpha)
end

local function updateBar(frame)
	local bar = frame.StatusBar
	if not bar then return end

	if not bar.styled then
		B.CreateBDFrame(bar, .25)
		bar:GetStatusBarTexture():ClearTextureSlice()
		bar:SetStatusBarTexture(DB.normTex)
		bar:DisableDrawLayer("BACKGROUND")
		bar.styled = true
	end
	if bar.BackgroundEdge then
		bar.BackgroundEdge:Hide()
	end
end

local function updateBox(self)
	self:ForEachFrame(updateBar)
end

local function updateLocalPlayerEntry(frame)
	updateBar(frame:GetLocalPlayerEntry())
end

local function updateMinimizeButton(frame, collapsed)
	frame.MinimizeButton.__texture:DoCollapse(collapsed)
end

local function reskinMinimizeButton(frame)
	local minimize = frame.MinimizeButton
	B.ReskinCollapse(minimize)
	minimize:GetNormalTexture():SetAlpha(0)
	minimize:GetPushedTexture():SetAlpha(0)
	minimize.__texture:DoCollapse(frame:IsMinimized())
	hooksecurefunc(frame, "SetMinimized", updateMinimizeButton)
end

local function ReskinMeterWindow(frame)
	if frame.styled then return end

	frame.Header:SetTexture()
	local bg = B.SetBD(frame.Header)
	bg:SetPoint("TOPLEFT", frame.Header, 0, -2)
	bg:SetPoint("BOTTOMRIGHT", frame.Header, 0, 2)

	reskinMinimizeButton(frame)

	local container = frame.MinimizeContainer
	B.ReskinTrimScroll(container.ScrollBar)
	container.ScrollBox:ForEachFrame(updateBar)
	hooksecurefunc(container.ScrollBox, "Update", updateBox)

	B.ReskinTrimScroll(container.SourceWindow.ScrollBar)
	container.SourceWindow.Background:SetTexture()
	B.SetBD(container.SourceWindow.Background):SetInside(nil, 2, 2)
	container.SourceWindow.ScrollBox:ForEachFrame(updateBar)
	hooksecurefunc(container.SourceWindow.ScrollBox, "Update", updateBox)

	local background = container.Background
	background:SetTexture()
	background.bg = B.SetBD(background, 1)
	background.bg:SetPoint("TOPLEFT", bg, "BOTTOMLEFT", 0, -2)
	background.bg:SetPoint("BOTTOMRIGHT", background, 0, 0)
	updateBGAlpha(background, background:GetAlpha())
	hooksecurefunc(background, "SetAlpha", updateBGAlpha)
	B.ReskinDropDown(frame.DamageMeterTypeDropdown)
	B.Reskin(frame.SessionDropdown)
	frame.SessionDropdown:SetSize(60, 22)
	frame.SessionDropdown:SetPoint("RIGHT", frame.SettingsDropdown, "LEFT", -8, 0)
	frame.SessionDropdown.Text:SetAlpha(0)

	updateButtonState(frame.SettingsDropdown)
	hooksecurefunc(frame.SettingsDropdown, "OnButtonStateChanged", updateButtonState)

	updateLocalPlayerEntry(frame)
	hooksecurefunc(frame, "ShowLocalPlayerEntry", updateLocalPlayerEntry)

	frame.styled = true
end

C.themes["Blizzard_DamageMeter"] = function()
	if not AuroraClassicDB.DamageMeter then return end

	C_Timer.After(1, function() -- delay to prevent taint
		hooksecurefunc(DamageMeter, "SetupSessionWindow", function(_, _, windowData)
			ReskinMeterWindow(windowData.sessionWindow)
		end)

		for i = 1, 3 do
			local frame = _G["DamageMeterSessionWindow"..i]
			if frame then
				ReskinMeterWindow(frame)
			end
		end
	end)
end
