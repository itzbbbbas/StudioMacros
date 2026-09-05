return {
	Name = "Select Descendant Parts";
	Description = "Select every BasePart under the selection.";

	RunOnSelection = true;

	Macro = function(instances)
		local parts = {}
		for _, Instance_ in instances do
			for _, Descendant in Instance_:GetDescendants() do
				if Descendant:IsA("BasePart") then
					table.insert(parts, Descendant)
				end
			end
		end

		return parts
	end;
}
