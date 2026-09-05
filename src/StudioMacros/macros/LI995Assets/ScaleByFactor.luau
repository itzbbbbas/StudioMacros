return {
	Name = "Scale by Factor";
	Description = "Multiply the selection's size by a typed factor.";

	CustomResults = "Number";

	NumberInput = {
		Caption = "factor";
		Prompt = "type a scale factor (2, 0.5, 3/4)...";

		Validate = function(value)
			return value > 0
		end;
	};

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	Macro = function(instance, _plugin, factor)
		if instance:IsA("Model") then
			instance:ScaleTo(instance:GetScale() * factor)
			return
		end

		instance.Size *= factor
	end;
}
