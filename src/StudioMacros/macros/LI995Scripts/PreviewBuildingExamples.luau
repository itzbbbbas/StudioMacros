local MODULE_NAME = "preview-building-examples-studio"

return {
	Name = "Preview building examples";
	Description = "Studio-side contact-sheet builder for the preview dumps.";

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
