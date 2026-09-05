local MODULE_NAME = "patch-building-bases-studio"

return {
	Name = "Patch building bases";
	Description = "Grows every building template's Base slab to the ADR 0055 plot pad, so a lot fills the ground it is placed on.";

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
