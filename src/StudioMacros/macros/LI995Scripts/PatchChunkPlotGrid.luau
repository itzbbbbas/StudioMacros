local MODULE_NAME = "patch-chunk-plot-grid-studio"

return {
	Name = "Patch chunk plot grid";
	Description = "Rebuilds the Assets.Chunk template's plot grid for ADR 0055: 100x100 pads, four per side, on a 128 pitch, centred in the verge at Z +-140.3.";

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
