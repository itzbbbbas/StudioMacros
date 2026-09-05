return {
	Name = "Scenery Collision Off";
	Description = "Clear CanCollide, CanQuery and CanTouch on every part, for can_collide = false ground cover.";

	Macro = function(instance)
		local count = 0
		local parts = instance:GetDescendants()
		table.insert(parts, instance)

		for _, Part in parts do
			if Part:IsA("BasePart") then
				Part.CanCollide = false
				Part.CanQuery = false
				Part.CanTouch = false
				count += 1
			end
		end

		print(`[LI995]: cleared collision on {count} parts`)
	end;
}
