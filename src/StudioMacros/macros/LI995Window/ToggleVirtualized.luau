return {
	Name = "Toggle Virtualized";
	Description = "Flip the canvas between hand layout with row windowing and the native layout object.";

	Predicate = function(instance)
		return instance:IsA("GuiObject")
	end;

	ToggleValue = function(instance)
		return instance and instance:GetAttribute("Virtualized") or false
	end;

	Macro = function(instance)
		instance:SetAttribute("Virtualized", not instance:GetAttribute("Virtualized"))
	end;
}
