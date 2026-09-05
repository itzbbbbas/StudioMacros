return {
	Name = "Anchor All";
	Description = "Anchor every BasePart under the selection.";

	Macro = function(instance)
		local count = 0
		for _, Descendant in instance:GetDescendants() do
			if Descendant:IsA("BasePart") and not Descendant.Anchored then
				Descendant.Anchored = true
				count += 1
			end
		end

		if instance:IsA("BasePart") and not instance.Anchored then
			instance.Anchored = true
			count += 1
		end

		print(`[LI995]: anchored {count} parts`)
	end;
}
