local function round(n)
	return math.round(n * 100) / 100
end

return {
	Name = "Measure Bounding Box";
	Description = "Print the selection's size in studs and its part count.";

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	ToastValue = function(instance)
		if not instance then
			return nil
		end

		local size = if instance:IsA("BasePart") then instance.Size else select(2, instance:GetBoundingBox())
		return `{round(size.X)} x {round(size.Y)} x {round(size.Z)}`
	end;

	Macro = function(instance)
		local size = if instance:IsA("BasePart") then instance.Size else select(2, instance:GetBoundingBox())

		local parts = 0
		for _, Descendant in instance:GetDescendants() do
			if Descendant:IsA("BasePart") then
				parts += 1
			end
		end
		if instance:IsA("BasePart") then
			parts += 1
		end

		print(
			`[LI995]: {instance.Name} is {round(size.X)} x {round(size.Y)} x {round(size.Z)} studs, {parts} parts`
		)
	end;
}
