local MODULE_NAME = "dump-prop-dims-studio"

return {
	Name = "Dump prop dims";
	Description = "Regenerates tests/fixtures/prop-dims-survey.luau: one live-measured bounding box per prop id, so the Lune...";

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
