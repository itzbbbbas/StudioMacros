-- The catalog label spec in AGENTS.md. Outline is a UIStroke, never TextStrokeTransparency, and the
-- 44x7 stud size is what makes TextScaled give one physical text height across every family slab.
local SIZE = UDim2.fromScale(44, 7)
local MAX_DISTANCE = 2000
local STROKE_THICKNESS = 2
local FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local function count_models(Folder)
	local count = 0
	for _, Child in Folder:GetChildren() do
		if Child:IsA("Model") or Child:IsA("BasePart") then
			count += 1
		end
	end
	return count
end

local function build_path(Folder)
	local segments = {}
	local Current = Folder
	while Current and Current.Parent and not Current:IsA("DataModel") do
		table.insert(segments, 1, Current.Name)
		Current = Current.Parent
		if Current.Name == "Assets" or Current.Name == "Editspace" or Current.Name == "Workspace" then
			break
		end
	end

	-- The top segment is dropped when anything sits below it, so same-named families stay apart.
	if #segments > 1 then
		table.remove(segments, 1)
	end
	return table.concat(segments, "/")
end

return {
	Name = "Catalog Billboard";
	Description = "Add or restyle a family folder's __CatalogBillboard to the house label spec.";

	Predicate = function(instance)
		return instance:IsA("Folder") or instance:IsA("Model")
	end;

	Macro = function(instance)
		local Adornee = instance:FindFirstChild("__CatalogPlatform") or instance
		local Billboard = Adornee:FindFirstChild("__CatalogBillboard")
		if not Billboard then
			Billboard = Instance.new("BillboardGui")
			Billboard.Name = "__CatalogBillboard"
			Billboard.Parent = Adornee
		end

		Billboard.Size = SIZE
		Billboard.MaxDistance = MAX_DISTANCE
		Billboard.AlwaysOnTop = false

		local Label = Billboard:FindFirstChildOfClass("TextLabel")
		if not Label then
			Label = Instance.new("TextLabel")
			Label.Name = "LabelCaption"
			Label.Parent = Billboard
		end

		Label.Size = UDim2.fromScale(1, 1)
		Label.BackgroundTransparency = 1
		Label.FontFace = FONT
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.TextScaled = true
		Label.Text = `{build_path(instance)} ({count_models(instance)})`

		local Stroke = Label:FindFirstChildOfClass("UIStroke")
		if not Stroke then
			Stroke = Instance.new("UIStroke")
			Stroke.Parent = Label
		end
		Stroke.Color = Color3.new(0, 0, 0)
		Stroke.Thickness = STROKE_THICKNESS
		Stroke.Transparency = 0

		return Billboard
	end;
}
