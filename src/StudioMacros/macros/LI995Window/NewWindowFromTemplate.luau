local StarterGui = game:GetService("StarterGui")

return {
	Name = "New Window from Template";
	Description = "Clone StarterGui.Window.TemplateWindow as NewWindow and select it.";

	Macro = function()
		local Window = StarterGui:FindFirstChild("Window")
		local Template = Window and Window:FindFirstChild("TemplateWindow")
		if not Template then
			warn("[LI995]: StarterGui.Window.TemplateWindow not found, is this Lost in 995?")
			return
		end

		local Clone = Template:Clone()
		Clone.Name = "NewWindow"
		Clone.Parent = Window
		return Clone
	end;
}
