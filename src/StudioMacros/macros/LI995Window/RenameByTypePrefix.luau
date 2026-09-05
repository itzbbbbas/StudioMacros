-- The prefix table in docs/agents/window-ui-anatomy.md. GuiButton is checked before the label
-- classes, so a TextButton reads as Button rather than Label.
local PREFIX_ORDER = {
	{ class = "TextBox", prefix = "Input" },
	{ class = "GuiButton", prefix = "Button" },
	{ class = "TextLabel", prefix = "Label" },
	{ class = "ImageLabel", prefix = "Image" },
	{ class = "ViewportFrame", prefix = "Viewport" },
	{ class = "VideoFrame", prefix = "Video" },
	{ class = "ScrollingFrame", prefix = "Scroll" },
	{ class = "Frame", prefix = "Frame" },
}

-- Renaming one of these breaks a lookup: code keys on the name (window-ui-anatomy.md, Top level).
local RESERVED = {
	MainFrame = true,
	Components = true,
	Theme = true,
	CanvasGroup = true,
	Chrome = true,
}

local function is_exempt(Instance_)
	local name = Instance_.Name
	if RESERVED[name] then
		return true
	end
	if string.sub(name, 1, 1) == "[" then
		return true
	end
	-- An ALL-CAPS name exempts itself only (TooltipHUD's READER/WRITER/TEMPLATE slots).
	if name == string.upper(name) and string.match(name, "%a") then
		return true
	end
	if Instance_:IsA("UIComponent") or Instance_:IsA("UIConstraint") then
		return true
	end
	return false
end

local function prefix_for(Instance_)
	for _, entry in PREFIX_ORDER do
		if Instance_:IsA(entry.class) then
			return entry.prefix
		end
	end
	return nil
end

return {
	Name = "Rename by Type Prefix";
	Description = "Apply the window-ui-anatomy prefix table to the selection and its descendants.";

	Predicate = function(instance)
		return instance:IsA("GuiObject") or instance:IsA("ScreenGui")
	end;

	Macro = function(instance)
		local targets = instance:GetDescendants()
		table.insert(targets, instance)

		local renamed = 0
		for _, Target in targets do
			if is_exempt(Target) then
				continue
			end

			local prefix = prefix_for(Target)
			if not prefix or string.sub(Target.Name, 1, #prefix) == prefix then
				continue
			end

			-- Strip the old class prefix so ButtonClose does not become ButtonTextClose.
			local stem = Target.Name
			for _, entry in PREFIX_ORDER do
				if string.sub(stem, 1, #entry.prefix) == entry.prefix and #stem > #entry.prefix then
					stem = string.sub(stem, #entry.prefix + 1)
					break
				end
			end
			if string.sub(stem, 1, 4) == "Text" and #stem > 4 then
				stem = string.sub(stem, 5)
			end

			Target.Name = prefix .. stem
			renamed += 1
		end

		print(`[LI995]: renamed {renamed} instances under {instance.Name}`)
	end;
}
