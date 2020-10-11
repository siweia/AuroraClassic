local _, ns = ...
local F, C = unpack(ns)

tinsert(C.defaultThemes, function()

	local function reskinAlertFrame(frame)
		if not frame.styled then
			if frame.OkayButton then F.Reskin(frame.OkayButton) end
			if frame.CloseButton then F.ReskinClose(frame.CloseButton) end

			frame.styled = true
		end
	end

	hooksecurefunc(HelpTip, "Show", function(self)
		for frame in self.framePool:EnumerateActive() do
			reskinAlertFrame(frame)
		end
	end)
end)