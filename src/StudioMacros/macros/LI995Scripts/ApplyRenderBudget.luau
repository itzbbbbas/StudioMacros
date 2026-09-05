local MODULE_NAME = "apply-render-budget-studio"

return {
	Name = "Apply render budget";
	Description = "Applies scripts/data/render-budget-rules.luau to the asset trees: per-BasePart CastShadow and per-MeshPart...";

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
