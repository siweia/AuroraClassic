local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AuraContainer"] = function()
	if not AuroraClassicDB.Tooltips then return end

	-- The aura tooltip is forbidden; style it only through Blizzard's secure inbound interface.
	AuraContainerInbound.SetTooltipBackdrop({
		backdropInfo = {
			bgFile = DB.bdTex,
			edgeFile = DB.bdTex,
			edgeSize = C.mult,
		},
		borderColor = CreateColor(0, 0, 0, 1),
		centerColor = CreateColor(0, 0, 0, .7),
		anchorOffsets = {
			left = C.mult,
			right = -C.mult,
			top = -C.mult,
			bottom = C.mult,
		},
	})
end
