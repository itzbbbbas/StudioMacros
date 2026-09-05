local function to_prop_id(name)
	local id = string.lower(name)
	id = string.gsub(id, "[%s%-]+", "_")
	id = string.gsub(id, "[^%w_]", "")
	id = string.gsub(id, "_+", "_")
	id = string.gsub(id, "^_", "")
	id = string.gsub(id, "_$", "")

	if string.sub(id, 1, 5) ~= "prop_" then
		id = "prop_" .. id
	end
	return id
end

return {
	Name = "Rename Prop snake_case";
	Description = "Rename the model to a prop_snake_case id, numbering it when a sibling already holds the stem.";

	RunOnSelection = true;

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	Macro = function(instances)
		for _, Instance_ in instances do
			local stem = to_prop_id(Instance_.Name)
			local Parent = Instance_.Parent
			local id = stem

			if Parent and Parent:FindFirstChild(id) ~= Instance_ then
				local index = 1
				repeat
					id = string.format("%s_%03d", stem, index)
					index += 1
				until Parent:FindFirstChild(id) == nil
			end

			Instance_.Name = id
		end
	end;
}
