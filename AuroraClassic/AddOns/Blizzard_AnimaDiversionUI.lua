local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AnimaDiversionUI"] = function()
	local frame = AnimaDiversionFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)

	local currencyFrame = frame.AnimaDiversionCurrencyFrame.CurrencyFrame
	B.ReplaceIconString(currencyFrame.Quantity)
	hooksecurefunc(currencyFrame.Quantity, "SetText", B.ReplaceIconString)

	B.Reskin(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end