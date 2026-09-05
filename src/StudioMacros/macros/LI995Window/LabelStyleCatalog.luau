-- The catalog caption style in AGENTS.md. UIStroke, never TextStrokeTransparency.
local FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local STROKE_THICKNESS = 2

return {
	Name = "Label Style Catalog";
	Description = "Apply the catalog caption style: GothamSSm Bold white, scaled, black outline.";

	Predicate = function(instance)
		return instance:IsA("TextLabel") or instance:IsA("TextButton")
	end;

	Macro = function(instance)
		instance.FontFace = FONT
		instance.TextColor3 = Color3.new(1, 1, 1)
		instance.TextScaled = true

		local Stroke = instance:FindFirstChildOfClass("UIStroke")
		if not Stroke then
			Stroke = Instance.new("UIStroke")
			Stroke.Parent = instance
		end
		Stroke.Color = Color3.new(0, 0, 0)
		Stroke.Thickness = STROKE_THICKNESS
		Stroke.Transparency = 0
	end;
}
