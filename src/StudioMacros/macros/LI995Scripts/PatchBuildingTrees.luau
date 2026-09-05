local MODULE_NAME = "patch-building-trees-studio"

return {
	Name = "Patch building trees";
	Description = "Sorts every building template into the ADR 0078 shape: Structure for static geometry, Zone for every spawn pad folder, and only Base plus the marker parts left at the top level.";

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
