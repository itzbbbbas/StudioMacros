local Workspace = game:GetService("Workspace")

return {
	Name = "Select Editspace Trees";
	Description = "Select the asset trees parked under Workspace.Editspace.";

	Macro = function()
		local Editspace = Workspace:FindFirstChild("Editspace")
		if not Editspace then
			warn("[LI995]: no Workspace.Editspace, the trees are deployed")
			return
		end

		return Editspace:GetChildren()
	end;
}
