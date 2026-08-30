local _, ns = ...
local B, C, L, DB = unpack(ns)

local function SkinMidnightOverlay(frame)
	local panel = frame.overlayFrame
	if not panel or not panel.RunesOfPowerFrame or panel.styled then return end

	panel.Background:SetAlpha(0)
	panel.Border:SetAlpha(0)
	B.SetBD(panel)
	B.ReskinClose(panel.CloseButton)

	panel.styled = true
end

C.themes["Blizzard_ExpansionLandingPage"] = function()
	local frame = _G.ExpansionLandingPage

	hooksecurefunc(frame, "RefreshExpansionOverlay", SkinMidnightOverlay)
	SkinMidnightOverlay(frame)
end
