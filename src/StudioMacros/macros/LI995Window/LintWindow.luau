-- Windows that close contextually or are modal, so a missing ButtonClose is correct
-- (docs/agents/window-ui-anatomy.md, Window skeleton).
local NO_CLOSE = {
	ReviveWindow = true,
	ContextActionWindow = true,
	BoomboxWindow = true,
	TemplateWindow = true,
}

local LAYOUT_CLASSES = { "UIListLayout", "UIGridLayout", "UIPageLayout", "UITableLayout" }

local function find_layout(Parent)
	for _, class in LAYOUT_CLASSES do
		local Layout = Parent:FindFirstChildOfClass(class)
		if Layout then
			return Layout
		end
	end
	return nil
end

return {
	Name = "Lint Window";
	Description = "Check the selected window against the StarterGui contract and select what fails.";

	Predicate = function(instance)
		return instance:IsA("GuiObject")
	end;

	Macro = function(instance)
		local problems = {}
		local offenders = {}

		local mains = {}
		for _, Descendant in instance:GetDescendants() do
			if Descendant.Name == "MainFrame" then
				table.insert(mains, Descendant)
			end
		end

		if #mains == 0 then
			table.insert(problems, "no MainFrame")
		elseif #mains > 1 then
			table.insert(problems, `{#mains} MainFrames, expected 1`)
			for _, Main in mains do
				table.insert(offenders, Main)
			end
		end

		if not NO_CLOSE[instance.Name] and not instance:FindFirstChild("ButtonClose", true) then
			table.insert(problems, "no ButtonClose")
		end

		for _, Descendant in instance:GetDescendants() do
			if Descendant.Name ~= "Components" or not Descendant:IsA("Folder") then
				continue
			end

			-- ADR 0079: the layout object lives beside the template in Components, never on the canvas.
			local Canvas = Descendant.Parent
			if Canvas and Canvas:IsA("GuiObject") and find_layout(Canvas) and not find_layout(Descendant) then
				table.insert(problems, `layout object sits on {Canvas.Name} instead of its Components`)
				table.insert(offenders, Canvas)
			end
		end

		if #problems == 0 then
			print(`[LI995]: {instance.Name} passes the window contract`)
			return
		end

		warn(`[LI995]: {instance.Name}: {table.concat(problems, "; ")}`)
		return offenders
	end;
}
