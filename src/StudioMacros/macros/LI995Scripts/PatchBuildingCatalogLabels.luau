local MODULE_NAME = "patch-building-catalog-labels-studio"

return {
	Name = "Patch building catalog labels";
	Description = "Needs the asset trees parked under Workspace.Editspace (ADR 0019).";

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
