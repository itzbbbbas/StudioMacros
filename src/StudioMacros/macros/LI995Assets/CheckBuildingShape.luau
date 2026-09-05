-- ADR 0078. Mirrors BuildingContentServiceUtil.TOP_LEVEL_NAMES; a command-bar macro has no requires
-- into the game tree, so the list is copied the same way patch-building-trees-studio.luau copies it.
local TOP_LEVEL_NAMES = {
	Base = true,
	FacingPart = true,
	ShellBounds = true,
	StoreFloor = true,
	PlotBillboard = true,
	Structure = true,
	Zone = true,
}

return {
	Name = "Check Building Shape";
	Description = "Report top-level children that ADR 0078 does not allow on a building template.";

	Predicate = function(instance)
		return instance:IsA("Model")
	end;

	Macro = function(instance)
		local strays = {}
		for _, Child in instance:GetChildren() do
			if not TOP_LEVEL_NAMES[Child.Name] then
				table.insert(strays, Child)
			end
		end

		if #strays == 0 then
			print(`[LI995]: {instance.Name} matches the ADR 0078 shape`)
			return
		end

		local names = {}
		for _, Stray in strays do
			table.insert(names, Stray.Name)
		end
		warn(`[LI995]: {instance.Name} strays: {table.concat(names, ", ")}`)

		return strays
	end;
}
