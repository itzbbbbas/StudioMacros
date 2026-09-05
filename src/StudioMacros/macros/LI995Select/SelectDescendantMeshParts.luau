return {
	Name = "Select Descendant MeshParts";
	Description = "Select every MeshPart under the selection.";

	RunOnSelection = true;

	Macro = function(instances)
		local meshes = {}
		for _, Instance_ in instances do
			for _, Descendant in Instance_:GetDescendants() do
				if Descendant:IsA("MeshPart") then
					table.insert(meshes, Descendant)
				end
			end
		end

		return meshes
	end;
}
