-- A Highlight under a FacingPart is authored on purpose and carries the DestroyMeComponentServer tag
-- (ADR 0078), so it survives this sweep.
local KEEP_TAG = "DestroyMeComponentServer"

local CollectionService = game:GetService("CollectionService")

return {
	Name = "Strip Editor Junk";
	Description = "Delete Highlights, SelectionBoxes, scripts and empty Folders under the selection.";

	Macro = function(instance)
		local doomed = {}

		for _, Descendant in instance:GetDescendants() do
			local is_marker = Descendant:IsA("Highlight") or Descendant:IsA("SelectionBox")
			local is_script = Descendant:IsA("LuaSourceContainer")
			local is_empty_folder = Descendant:IsA("Folder") and #Descendant:GetChildren() == 0

			if (is_marker or is_script or is_empty_folder) and not CollectionService:HasTag(Descendant, KEEP_TAG) then
				table.insert(doomed, Descendant)
			end
		end

		for _, Doomed in doomed do
			Doomed:Destroy()
		end

		print(`[LI995]: stripped {#doomed} instances from {instance.Name}`)
	end;
}
