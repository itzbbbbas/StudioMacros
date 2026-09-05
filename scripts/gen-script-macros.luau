--!nolint
-- Regenerates LI995Scripts from the game repo's scripts/studio folder.
--   lune run scripts/gen-script-macros.luau [path/to/lost-in-995]
-- Each macro loadstrings the ModuleScript that Argon syncs to ServerStorage.StudioScripts, so the
-- palette runs the same source the command bar would.

local fs = require("@lune/fs")
local process = require("@lune/process")

local REPO = process.args[1] or "C:/Users/User/Desktop/Github/Roblox/lost-in-995"
local SOURCE_DIR = `{REPO}/scripts/studio`
local OUT_DIR = "src/StudioMacros/macros/LI995Scripts"

local function title_case(word)
	return string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
end

local function pretty_name(stem)
	local words = {}
	for word in string.gmatch(string.gsub(stem, "%-studio$", ""), "[^%-]+") do
		table.insert(words, word)
	end
	words[1] = title_case(words[1])
	return table.concat(words, " ")
end

local function pascal_case(stem)
	local out = ""
	for word in string.gmatch(string.gsub(stem, "%-studio$", ""), "[^%-]+") do
		out ..= title_case(word)
	end
	return out
end

local function first_summary_line(source)
	local parts = {}
	for line in string.gmatch(source, "[^\n]+") do
		local text = string.match(line, "^%-%-%s*(.+)$")
		if not text then
			if #parts > 0 then
				break
			end
			continue
		end
		if string.match(text, "%.luau$") or text == "itzbbbbas" then
			continue
		end

		table.insert(parts, text)
		if #table.concat(parts, " ") > 110 then
			break
		end
	end

	if #parts == 0 then
		return "Run this Studio script."
	end

	-- Descriptions render on one palette row, so the joined header is cut at a sentence or word break.
	local text = table.concat(parts, " ")
	local sentence = string.match(text, "^(.-%.)%s")
	if sentence and #sentence >= 40 then
		text = sentence
	elseif #text > 110 then
		text = string.gsub(string.sub(text, 1, 107), "%s%S*$", "") .. "..."
	end

	text = string.gsub(text, "`", "")
	return (string.gsub(text, '"', "'"))
end

for _, entry in fs.readDir(OUT_DIR) do
	if entry ~= "GroupData.luau" then
		fs.removeFile(`{OUT_DIR}/{entry}`)
	end
end

local written = 0
for _, entry in fs.readDir(SOURCE_DIR) do
	local stem = string.match(entry, "^(.+)%.luau$")
	if not stem then
		continue
	end

	local summary = first_summary_line(fs.readFile(`{SOURCE_DIR}/{entry}`))
	local body = table.concat({
		`local MODULE_NAME = "{stem}"`,
		"",
		"return {",
		`\tName = "{pretty_name(stem)}";`,
		`\tDescription = "{summary}";`,
		"",
		"\tMacro = function()",
		'\t\tlocal Scripts = game:GetService("ServerStorage"):FindFirstChild("StudioScripts")',
		"\t\tlocal Module = Scripts and Scripts:FindFirstChild(MODULE_NAME)",
		"\t\tif not Module then",
		'\t\t\twarn(`[LI995]: {MODULE_NAME} not synced, restart argon serve`)',
		"\t\t\treturn",
		"\t\tend",
		"",
		"\t\tloadstring(Module.Source)()",
		"\tend;",
		"}",
		"",
	}, "\n")

	fs.writeFile(`{OUT_DIR}/{pascal_case(stem)}.luau`, body)
	written += 1
end

print(`wrote {written} script macros to {OUT_DIR}`)
