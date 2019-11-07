local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	AudioOptionsFrame.Header = AudioOptionsFrame.Header or AudioOptionsFrameHeader -- deprecated in 8.3
	AudioOptionsFrame.Header:SetAlpha(0)
	AudioOptionsFrame.Header:ClearAllPoints()
	AudioOptionsFrame.Header:SetPoint("TOP", AudioOptionsFrame, 0, 0)
	F.CreateBD(AudioOptionsFrame)
	F.CreateSD(AudioOptionsFrame)
	F.Reskin(AudioOptionsFrameOkay)
	F.Reskin(AudioOptionsFrameCancel)
	F.Reskin(AudioOptionsFrameDefaults)
end)