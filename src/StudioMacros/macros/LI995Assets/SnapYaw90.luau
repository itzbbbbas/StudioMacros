return {
	Name = "Snap Yaw 90";
	Description = "Rotate the selection 90 degrees around its own pivot.";

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	Macro = function(instance)
		instance:PivotTo(instance:GetPivot() * CFrame.Angles(0, math.rad(90), 0))
	end;
}
