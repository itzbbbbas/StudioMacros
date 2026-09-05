return {
	Name = "Pivot to Bottom";
	Description = "Move the pivot to the bottom face, so the asset rests where you place it.";

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	Macro = function(instance)
		if instance:IsA("BasePart") then
			instance.PivotOffset = CFrame.new(0, -instance.Size.Y / 2, 0)
			return
		end

		local Primary = instance.PrimaryPart
		if not Primary then
			warn(`[LI995]: {instance.Name} has no PrimaryPart, set one first`)
			return
		end

		-- The offset is expressed in the pivot's own frame, so measure the box relative to the pivot
		-- rather than to the world.
		local pivot = instance:GetPivot()
		local box_cframe, box_size = instance:GetBoundingBox()
		local local_center = pivot:ToObjectSpace(box_cframe).Position
		instance.PrimaryPart.PivotOffset = Primary.CFrame:ToObjectSpace(pivot)
			* CFrame.new(local_center.X, local_center.Y - box_size.Y / 2, local_center.Z)
	end;
}
