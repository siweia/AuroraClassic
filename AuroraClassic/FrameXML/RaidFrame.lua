local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.StripTextures(RaidInfoFrame)
	F.CreateBD(RaidInfoFrame)
	F.CreateSD(RaidInfoFrame)
	F.ReskinCheck(RaidFrameAllAssistCheckButton)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)
	RaidInfoDetailFooter:Hide()
	RaidInfoDetailHeader:Hide()
	RaidInfoDetailCorner:Hide()
	RaidInfoFrame.Header = RaidInfoFrame.Header or RaidInfoFrameHeader -- deprecated in 8.3
	RaidInfoFrame.Header:Hide()

	F.Reskin(RaidFrameRaidInfoButton)
	F.Reskin(RaidFrameConvertToRaidButton)
	F.Reskin(RaidInfoExtendButton)
	F.Reskin(RaidInfoCancelButton)
	F.ReskinClose(RaidInfoCloseButton)
	F.ReskinScroll(RaidInfoScrollFrameScrollBar)
	F.ReskinClose(RaidParentFrameCloseButton)

	F.ReskinPortraitFrame(RaidParentFrame)
	RaidInfoInstanceLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoIDLabel:DisableDrawLayer("BACKGROUND")
end)