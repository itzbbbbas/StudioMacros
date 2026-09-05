local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Prop/Constant.luau's Category union. A folder segment that is not one of these falls back to misc,
-- because a wrong category ships a live registry entry that fails the boot drift check.
local CATEGORIES = {
	furniture = true,
	street = true,
	lamppost = true,
	nature = true,
	structure = true,
	storage = true,
	vehicle = true,
	misc = true,
}

local function title_case(word)
	return string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
end

local function pretty_name(id)
	local words = {}
	for word in string.gmatch(string.gsub(id, "^prop_", ""), "[^_]+") do
		table.insert(words, title_case(word))
	end
	return table.concat(words, " ")
end

local function path_segments(Model)
	local segments = {}
	local Current = Model.Parent
	while Current and Current.Parent do
		if Current.Name == "Props" then
			break
		end
		table.insert(segments, 1, Current.Name)
		Current = Current.Parent
	end
	return segments
end

local function ensure_folder(Parent, name)
	local Folder = Parent:FindFirstChild(name)
	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = name
		Folder.Parent = Parent
	end
	return Folder
end

return {
	Name = "New Prop Entry";
	Description = "Create the Sources/Content/Prop/Entries ModuleScript for the selected model, for Argon to sync.";

	Predicate = function(instance)
		return instance:IsA("Model") and string.sub(instance.Name, 1, 5) == "prop_"
	end;

	Macro = function(instance)
		local Entries = ReplicatedStorage:FindFirstChild("Sources")
		Entries = Entries and Entries:FindFirstChild("Content")
		Entries = Entries and Entries:FindFirstChild("Prop")
		Entries = Entries and Entries:FindFirstChild("Entries")
		if not Entries then
			warn("[LI995]: ReplicatedStorage.Sources.Content.Prop.Entries not found, is argon serve running?")
			return
		end

		local id = instance.Name
		local segments = path_segments(instance)
		local category = string.lower(segments[1] or "misc")
		if not CATEGORIES[category] then
			category = "misc"
		end

		local Parent = Entries
		for _, segment in segments do
			Parent = ensure_folder(Parent, segment)
		end

		if Parent:FindFirstChild(id) then
			warn(`[LI995]: {id} already has an entry`)
			return Parent[id]
		end

		local name = pretty_name(id)
		local Module = Instance.new("ModuleScript")
		Module.Name = id
		Module.Source = `-- {id}.luau\n`
			.. "-- itzbbbbas\n\n"
			.. `local {id} = \{\n`
			.. `\tcategory = "{category}",\n`
			.. `\tname = "{name}",\n`
			.. `\tnickname = "{name}",\n`
			.. "\tsubcategory = \"prop\",\n"
			.. "}\n\n"
			.. `return {id}\n`
		Module.Parent = Parent

		print(`[LI995]: wrote {id} under {table.concat(segments, "/")}`)
		return Module
	end;
}
