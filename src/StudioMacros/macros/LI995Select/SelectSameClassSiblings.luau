return {
	Name = "Select Same-Class Siblings";
	Description = "Select every sibling of the selection that shares its class.";

	Macro = function(instance)
		local Parent = instance.Parent
		if not Parent then
			return
		end

		local matches = {}
		for _, Sibling in Parent:GetChildren() do
			if Sibling.ClassName == instance.ClassName then
				table.insert(matches, Sibling)
			end
		end

		return matches
	end;
}
