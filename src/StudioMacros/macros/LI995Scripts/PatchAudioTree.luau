local MODULE_NAME = "patch-audio-tree-studio"

return {
	Name = "Patch audio tree";
	Description = "Builds or patches the SoundService tree inside Studio (ADR 0054).";

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
