local MODULE_NAME = "preview-building-lots-studio"

return {
	Name = "Preview building lots";
	Description = "Studio-side contact sheet of REAL building lots: 1:1 with what a player walks up to, because it runs the runtime pipeline rather than replaying a dump.";

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
