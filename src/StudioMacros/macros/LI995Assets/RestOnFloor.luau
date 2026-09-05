local Workspace = game:GetService("Workspace")

local function get_box(instance)
	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	return instance:GetBoundingBox()
end

return {
	Name = "Rest on Floor";
	Description = "Drop the selection straight down until its bottom face touches whatever is below.";

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	Macro = function(instance)
		local box_cframe, box_size = get_box(instance)
		local bottom = box_cframe.Position - Vector3.new(0, box_size.Y / 2, 0)

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { instance }

		local result = Workspace:Raycast(bottom, Vector3.new(0, -4096, 0), params)
		if not result then
			warn(`[LI995]: nothing under {instance.Name} to rest on`)
			return
		end

		instance:PivotTo(instance:GetPivot() + Vector3.new(0, result.Position.Y - bottom.Y, 0))
	end;
}
