-- ADR 0079. The layout object is the only copy and native mode needs it, so this moves it rather
-- than cloning, and never deletes.
local LAYOUT_CLASSES = { "UIListLayout", "UIGridLayout", "UIPageLayout", "UITableLayout" }

return {
	Name = "Layout into Components";
	Description = "Move the canvas's layout object into its Components folder, creating the folder if absent.";

	Predicate = function(instance)
		return instance:IsA("GuiObject")
	end;

	Macro = function(instance)
		local Layout
		for _, class in LAYOUT_CLASSES do
			Layout = instance:FindFirstChildOfClass(class)
			if Layout then
				break
			end
		end

		if not Layout then
			warn(`[LI995]: {instance.Name} has no layout object on the canvas`)
			return
		end

		local Components = instance:FindFirstChild("Components")
		if not Components then
			Components = Instance.new("Folder")
			Components.Name = "Components"
			Components.Parent = instance
		end

		Layout.Parent = Components
		return Components
	end;
}
