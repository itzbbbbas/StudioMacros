local MODULE_NAME = "probe-memory-leak-studio"

return {
	Name = "Probe memory leak";
	Description = "Leak probe for a running playtest. Samples the engine memory tags that matter for Luau leaks next to the...";

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
