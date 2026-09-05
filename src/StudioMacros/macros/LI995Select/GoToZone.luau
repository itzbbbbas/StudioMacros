return {
	Name = "Go to Zone";
	Description = "Select the building's Zone folder of spawn pads.";

	Predicate = function(instance)
		return instance:IsA("Model") and instance:FindFirstChild("Zone") ~= nil
	end;

	Macro = function(instance)
		return instance.Zone
	end;
}
