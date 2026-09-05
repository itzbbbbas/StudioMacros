return {
	Name = "Copy Full Path";
	Description = "Copy the selection's GetFullName, for the command bar or a bug report.";

	Macro = function(instance)
		local path = instance:GetFullName()
		setclipboard(path)
		print(`[LI995]: copied "{path}"`)
	end;
}
