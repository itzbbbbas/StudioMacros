return {
	Name = "Toggle LazyRender";
	Description = "Flip the canvas between hand layout with row windowing and the native layout object.";

	Predicate = function(instance)
		return instance:IsA("GuiObject")
	end;

	ToggleValue = function(instance)
		return instance and instance:GetAttribute("LazyRender") or false
	end;

	Macro = function(instance)
		instance:SetAttribute("LazyRender", not instance:GetAttribute("LazyRender"))
	end;
}
