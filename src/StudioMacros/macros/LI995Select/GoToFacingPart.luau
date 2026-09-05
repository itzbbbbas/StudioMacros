return {
	Name = "Go to FacingPart";
	Description = "Select the building's FacingPart marker.";

	Predicate = function(instance)
		return instance:IsA("Model") and instance:FindFirstChild("FacingPart") ~= nil
	end;

	Macro = function(instance)
		return instance.FacingPart
	end;
}
