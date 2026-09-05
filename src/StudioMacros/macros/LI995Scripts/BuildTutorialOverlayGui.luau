local MODULE_NAME = "build-tutorial-overlay-gui-studio"

return {
	Name = "Build tutorial overlay gui";
	Description = "Rebuilds the tutorial spotlight's two authored layers under StarterGui.HUD: TutorialOverlayHUD (scrim...";

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
