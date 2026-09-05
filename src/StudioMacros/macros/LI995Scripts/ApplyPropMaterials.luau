local MODULE_NAME = "apply-prop-materials-studio"

return {
	Name = "Apply prop materials";
	Description = "Applies scripts/data/prop-material-rules.luau to Assets.Props.";

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
