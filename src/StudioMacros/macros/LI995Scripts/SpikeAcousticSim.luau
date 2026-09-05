local MODULE_NAME = "spike-acoustic-sim-studio"

return {
	Name = "Spike acoustic sim";
	Description = "THROWAWAY, Phase 1 of docs/plans/audio-acoustic-sim.md.";

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
