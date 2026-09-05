local MODULE_NAME = "build-changelog-window-gui-studio"

return {
	Name = "Build changelog window gui";
	Description = "Rebuilds StarterGui.Window.ChangelogWindow as a panel with a version rail: a title row, a column of version chips on the left, and that version's entries on the right.";

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
