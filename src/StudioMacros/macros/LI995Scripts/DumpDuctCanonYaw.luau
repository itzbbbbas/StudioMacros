local MODULE_NAME = "dump-duct-canon-yaw-studio"

return {
	Name = "Dump duct canon yaw";
	Description = "TRAP this exists for: [DuctKit] states ports and bbox in a canonical frame the models are not posed in,...";

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
