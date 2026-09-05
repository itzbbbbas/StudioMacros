return {
	Name = "Select Descendant TextLabels";
	Description = "Select every TextLabel under the selection.";

	RunOnSelection = true;

	Macro = function(instances)
		local labels = {}
		for _, Instance_ in instances do
			for _, Descendant in Instance_:GetDescendants() do
				if Descendant:IsA("TextLabel") then
					table.insert(labels, Descendant)
				end
			end
		end

		return labels
	end;
}
