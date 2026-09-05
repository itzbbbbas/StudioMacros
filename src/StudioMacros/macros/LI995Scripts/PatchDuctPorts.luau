local MODULE_NAME = "patch-duct-ports-studio"

return {
	Name = "Patch duct ports";
	Description = "Writes one Attachment per duct bore onto each ducting model, so the art carries its own connection points...";

	Macro = function()
		local Scripts = game:GetService("ServerStorage"):FindFirstChild("StudioScripts")
		local Module = Scripts and Scripts:FindFirstChild(MODULE_NAME)
		if not Module then
			warn(`[LI995]: {MODULE_NAME} not synced, restart argon serve`)
			return
		end

		loadstring(Module.Source)()
	end;
}
