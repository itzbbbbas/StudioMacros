-- Mirrors the FlowView schema (ADR 0079). Seeding through require would need the game's module tree
-- loaded in the plugin VM, which it is not, so the three defaults are written directly.
local DEFAULTS = {
	Virtualized = false,
	BufferRows = 1,
	DebugRows = false,
}

return {
	Name = "Seed FlowView Attributes";
	Description = "Write the three FlowView attributes on the canvas, so the Explorer shows the full set.";

	Predicate = function(instance)
		return instance:IsA("GuiObject")
	end;

	Macro = function(instance)
		for name, default in DEFAULTS do
			if instance:GetAttribute(name) == nil then
				instance:SetAttribute(name, default)
			end
		end
	end;
}
