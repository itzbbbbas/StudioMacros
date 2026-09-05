local CollectionService = game:GetService("CollectionService")

return {
	Name = "Select by Tag";
	Description = "Select every instance carrying the selection's first CollectionService tag.";

	Macro = function(instance)
		local tags = CollectionService:GetTags(instance)
		if #tags == 0 then
			warn(`[LI995]: {instance.Name} carries no tags`)
			return
		end

		local tagged = CollectionService:GetTagged(tags[1])
		print(`[LI995]: {#tagged} instances tagged {tags[1]}`)
		return tagged
	end;
}
