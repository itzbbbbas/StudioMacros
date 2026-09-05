-- FacingPart is an authoring marker only (ADR 0078): nothing reads it at runtime, and only the Base
-- edge it sits on carries meaning. Its Highlight must carry DestroyMeComponentServer or players see it.
local FACING_TAG = "DestroyMeComponentServer"

local CollectionService = game:GetService("CollectionService")

return {
	Name = "Insert FacingPart";
	Description = "Add the ADR 0078 marker sphere on the middle of Base's road-side edge, Highlight tagged.";

	Predicate = function(instance)
		return instance:IsA("Model") and instance:FindFirstChild("Base") ~= nil
	end;

	Macro = function(instance)
		local Existing = instance:FindFirstChild("FacingPart")
		if Existing then
			warn(`[LI995]: {instance.Name} already has a FacingPart`)
			return Existing
		end

		local Base = instance.Base
		local Marker = Instance.new("Part")
		Marker.Name = "FacingPart"
		Marker.Shape = Enum.PartType.Ball
		Marker.Size = Vector3.one
		Marker.Material = Enum.Material.Glass
		Marker.Transparency = 1
		Marker.Anchored = true
		Marker.CanCollide = false
		Marker.CanQuery = false
		Marker.CanTouch = false
		Marker.CFrame = Base.CFrame * CFrame.new(0, Base.Size.Y / 2 + 0.5, -Base.Size.Z / 2)

		local Highlight = Instance.new("Highlight")
		Highlight.Parent = Marker
		CollectionService:AddTag(Highlight, FACING_TAG)

		Marker.Parent = instance
		return Marker
	end;
}
