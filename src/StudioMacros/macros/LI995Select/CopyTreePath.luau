-- Tree.Await takes a path relative to an anchor the caller already holds, so the walk stops at the
-- first ScreenGui, Model or Editspace child rather than at the DataModel.
local function is_anchor(Instance_)
	return Instance_:IsA("ScreenGui")
		or Instance_:IsA("Model")
		or (Instance_.Parent ~= nil and Instance_.Parent.Name == "Editspace")
end

return {
	Name = "Copy Tree Path";
	Description = "Copy the selection's path from its nearest anchor, in the form Tree.Await takes.";

	Macro = function(instance)
		local segments = {}
		local Current = instance

		while Current and Current.Parent do
			if is_anchor(Current) then
				break
			end
			table.insert(segments, 1, Current.Name)
			Current = Current.Parent
		end

		local path = table.concat(segments, "/")
		setclipboard(path)
		print(`[LI995]: copied "{path}"`)
	end;
}
