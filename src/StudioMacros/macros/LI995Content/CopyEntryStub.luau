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

return {
	Name = "Copy Entry Stub";
	Description = "Copy a Prop registry entry table for the selected model, for a hand-placed file.";

	Predicate = function(instance)
		return instance:IsA("Model") or instance:IsA("BasePart")
	end;

	Macro = function(instance)
		local id = instance.Name
		local name = pretty_name(id)
		local source = `-- {id}.luau\n`
			.. "-- itzbbbbas\n\n"
			.. `local {id} = \{\n`
			.. "\tcategory = \"misc\",\n"
			.. `\tname = "{name}",\n`
			.. `\tnickname = "{name}",\n`
			.. "\tsubcategory = \"prop\",\n"
			.. "}\n\n"
			.. `return {id}\n`

		setclipboard(source)
		print(`[LI995]: copied the entry stub for {id}`)
	end;
}
