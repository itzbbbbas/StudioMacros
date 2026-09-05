local MODULE_NAME = "dump-duct-sections-studio"

return {
	Name = "Dump duct sections";
	Description = "TRAP this exists for: gauge fixes only the duct HEIGHT, and h2 carries FOUR outer widths (1.35, 2.25, 4.05 and 6.15).";

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
