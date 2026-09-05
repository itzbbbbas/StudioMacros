return {
	Name = "Go to Base";
	Description = "Select the building's Base slab.";

	Predicate = function(instance)
		return instance:IsA("Model") and instance:FindFirstChild("Base") ~= nil
	end;

	Macro = function(instance)
		return instance.Base
	end;
}
