local MODULE_NAME = "dump-duct-ports-studio"

return {
	Name = "Dump duct ports";
	Description = "Classifies the industrial ducting kit: which faces of each piece carry an open duct bore, how big that...";

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
