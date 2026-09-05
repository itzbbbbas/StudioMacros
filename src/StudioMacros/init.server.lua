-- yo
local modules = script:WaitForChild("modules")
local loader = script.Parent:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapPlugin(modules)

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local UserInputService = game:GetService("UserInputService")

-- Macros authored in the open place rather than compiled into the plugin. Edit one, let the sync
-- tool write it, and the palette reloads itself. No rebuild, no Studio restart.
local LIVE_FOLDER = "Macros"
local LIVE_DEBOUNCE = 0.4

local Blend = require("Blend")
local CommandGroup = require("CommandGroup")
local CommandPalette = require("CommandPalette")
local CustomResultsWidget = require("CustomResultsWidget")
local MacroToast = require("MacroToast")
local Maid = require("Maid")
local RxInstanceUtils = require("RxInstanceUtils")
local ValueObject = require("ValueObject")

local function collectGroupFolders()
	local groups = {}

	for _, group in script.macros:GetChildren() do
		if group:IsA("Folder") then
			table.insert(groups, { folder = group, live = false })
		end
	end

	local liveRoot = ServerStorage:FindFirstChild(LIVE_FOLDER)
	if liveRoot then
		for _, group in liveRoot:GetChildren() do
			if group:IsA("Folder") then
				table.insert(groups, { folder = group, live = true })
			end
		end
	end

	return groups
end

-- TRAP: require caches by instance and a Source edit does not invalidate it, so a live module must be
-- required through a throwaway clone or the palette keeps running the version it first saw.
-- A GroupData carries Name and Icon and no Macro, so the shape check belongs at each call site.
local function requireLive(module)
	local ok, result = pcall(require, module:Clone())
	if not ok then
		warn(`[StudioMacros]: {module:GetFullName()} failed to load: {result}`)
		return nil
	end

	if type(result) == "function" then
		ok, result = pcall(result, require)
		if not ok then
			warn(`[StudioMacros]: {module:GetFullName()} failed to load: {result}`)
			return nil
		end
	end

	if type(result) ~= "table" then
		warn(`[StudioMacros]: {module:GetFullName()} must return a table`)
		return nil
	end

	return result
end

-- Roblox has no API to remove a PluginAction, and creating one twice with the same id throws, so a
-- reload has to hand back the action it made the first time.
local pluginActions = {}
local function getPluginAction(plugin, macroData)
	local existing = pluginActions[macroData.Name]
	if existing then
		return existing
	end

	local ok, action = pcall(function()
		return plugin:CreatePluginAction(
			macroData.Name,
			macroData.Name,
			`[StudioMacros]: {macroData.Description or macroData.Name}`,
			"rbxassetid://5972593639",
			true
		)
	end)
	if not ok then
		return nil
	end

	pluginActions[macroData.Name] = action
	return action
end

local function getToggleValue(macroData, instance)
	if not string.find(macroData.Name, "Toggle", 1, true) then
		return nil
	end

	if macroData.ToggleValue then
		return macroData.ToggleValue(instance)
	end

	if not instance then
		return nil
	end

	local property = string.match(macroData.Name, "^Toggle%s+(%S+)$")
	if not property then
		return nil
	end

	local success, value = pcall(function()
		return instance[property]
	end)

	if not success then
		return nil
	end

	return value
end

local function getToastValue(macroData, instance)
	if macroData.ToastValue then
		return macroData.ToastValue(instance)
	end

	return getToggleValue(macroData, instance)
end

local function getToastName(macroData, instance)
	if macroData.ToastName then
		local name = macroData.ToastName(instance)
		if name then
			return name
		end
	end

	return macroData.Name
end

local function appendSelection(newSelection, result)
	if type(result) == "table" then
		for _, instance in result do
			table.insert(newSelection, instance)
		end
	elseif result then
		table.insert(newSelection, result)
	end
end

local function initialize(plugin)
	local maid = Maid.new()

	local pane = maid:Add(CommandPalette.new())
	local toast = maid:Add(MacroToast.new())

	pane:SetPlugin(plugin)

	local commandsGui = maid:Add(ValueObject.new(nil))

	maid:GiveTask(Blend.New "ScreenGui" {
		Name = "StudioMacrosCommands";
		DisplayOrder = 1000;
		Parent = CoreGui;

		[Blend.Instance] = function(instance)
			commandsGui.Value = instance
		end;

		toast:Render();
	}:Subscribe())

	maid:GiveTask(pane:Render({ Parent = commandsGui }):Subscribe())
	maid:Add(CustomResultsWidget.new(plugin, pane))

	local uiEditorVisible = maid:Add(ValueObject.new(plugin:GetSetting("UIEditorDisabled") or true))

	local toggleCommand = plugin:CreatePluginAction(
		"StudioMacros Commands",
		"StudioMacros Commands",
		"Toggle the StudioMacros command palette",
		"rbxassetid://5972593639",
		true
	)

	maid:GiveTask(toggleCommand.Triggered:Connect(function()
		if pane:IsVisible() then
			pane:CaptureFocus()
		end

		local selection = Selection:Get()

		if #selection > 0 or not pane:IsVisible() then
			pane.TargetSelection.Value = selection
		end

		pane:Show(true)
	end))

	local restoringSelection = false

	maid:GiveTask(Selection.SelectionChanged:Connect(function()
		if restoringSelection or not pane:IsVisible() then
			return
		end

		local selection = Selection:Get()

		if #selection > 0 then
			pane.TargetSelection.Value = selection
			return
		end

		local targetSelection = pane.TargetSelection.Value
		if not targetSelection or #targetSelection == 0 then
			return
		end

		local liveSelection = {}
		for _, selectedInstance in targetSelection do
			if selectedInstance:IsDescendantOf(game) then
				table.insert(liveSelection, selectedInstance)
			end
		end

		if #liveSelection == 0 then
			pane.TargetSelection.Value = nil
			return
		end

		restoringSelection = true
		Selection:Set(liveSelection)

		task.defer(function()
			restoringSelection = false
		end)
	end))

	maid:GiveTask(plugin.Unloading:Connect(function()
		maid:Destroy()
	end))

	-- Tracks the last macro run so "Repeat Last Macro" can replay it. This is
	-- shared across every group/macro, so it lives above the group loop.
	local lastActivated: ((boolean?, ...any) -> ())? = nil
	local lastArguments: { any }? = nil

	for index, entry in collectGroupFolders() do
		local group, live = entry.folder, entry.live
		do
			local groupDataModule = group:FindFirstChild("GroupData")
			if not groupDataModule then
				continue
			end

			local groupData = if live then requireLive(groupDataModule) else require(groupDataModule)
			if type(groupData) ~= "table" or type(groupData.Name) ~= "string" then
				if live then
					warn(`[StudioMacros]: {group:GetFullName()} needs a GroupData returning a Name`)
				end
				continue
			end

			local groupEntry = pane:AddGroup(groupData)
			groupEntry.LayoutOrder.Value = index

			if index ~= 1 then
				groupEntry:SetIsCollapsed(true)
			end

			local activeMacro, leaveActiveMacroOpen
			maid:GiveTask(pane.CustomResultsReset:Connect(function()
				activeMacro = nil
			end))

			for macroIndex, macro in group:GetChildren() do
				if macro.Name == "GroupData" or not macro:IsA("ModuleScript") then
					continue
				end

				local macroData
				if live then
					macroData = requireLive(macro)
					if not macroData then
						continue
					end
					if type(macroData.Name) ~= "string" or type(macroData.Macro) ~= "function" then
						warn(`[StudioMacros]: {macro:GetFullName()} needs a Name and a Macro`)
						continue
					end
				else
					macroData = require(macro)
				end

				if type(macroData) == "function" then
					macroData = macroData(require)
				end

				if macroData.Initialize then
					macroData.Initialize(plugin)
				end

				local pluginAction = getPluginAction(plugin, macroData)

				local macroEntry = groupEntry:AddEntry(macroData)
				macroEntry:SetDefaultIndex(macroIndex)

				if macro.Name == "ToggleUIEditor" then
					maid:GiveTask(RxInstanceUtils.observeLastNamedChildBrio(CoreGui, "Folder", "RobloxGUIEditor")
						:Subscribe(function(editorBrio)
							if editorBrio:IsDead() then
								return
							end

							local editor = editorBrio:GetValue()

							editorBrio:ToMaid():GiveTask(RxInstanceUtils.observeDescendantsOfClassBrio(editor, "ScreenGui")
								:Subscribe(function(screenGuiBrio)
									if screenGuiBrio:IsDead() then
										return
									end

									local screenGui = screenGuiBrio:GetValue()

									screenGuiBrio:ToMaid():GiveTask(uiEditorVisible:Observe():Subscribe(function(isVisible)
										task.defer(function()
											screenGui.Enabled = isVisible
										end)
									end))
								end))
						end))

					maid:GiveTask(RxInstanceUtils.observeLastNamedChildBrio(CoreGui, "ScreenGui", "RobloxGui")
						:Subscribe(function(screenGuiBrio)
							if screenGuiBrio:IsDead() then
								return
							end

							local screenGui = screenGuiBrio:GetValue()

							screenGuiBrio:ToMaid():GiveTask(uiEditorVisible:Observe():Subscribe(function(isVisible)
								screenGui.Enabled = isVisible
							end))
						end))
				end

				local function activated(leavePaneOpen: boolean?, ...)
					if macroEntry:IsGroupHeader() then
						return
					end

					if macro.Name == "RepeatLastMacro" then
						if lastActivated and lastArguments then
							lastActivated(leavePaneOpen, table.unpack(lastArguments, 1, lastArguments.n))
						elseif not leavePaneOpen then
							pane:Hide()
						end
						return
					end

					if macro.Name == "ToggleUIEditor" then
						uiEditorVisible.Value = not uiEditorVisible.Value
						toast:ShowMacro(macroData.Name, groupData.Icon, uiEditorVisible.Value)
						if not leavePaneOpen then
							pane:Hide()
						end
						return
					end

					local customResults = macroData.CustomResults
					local arguments = {...}
					if customResults and #arguments == 0 then
						local isNewlyOpened = not pane:IsVisible()

						-- Macros with their own window use it when they're
						-- triggered from outside the palette; reaching them
						-- through the palette keeps the input inline instead.
						if isNewlyOpened and macroData.OpenWindow then
							macroData.OpenWindow(plugin)
							return
						end

						local useWidget = isNewlyOpened or pane:IsDocked()

						if isNewlyOpened then
							pane.TargetSelection.Value = Selection:Get()
							pane:Show(true)
						end

						pane.NumberInput.Value = macroData.NumberInput
						pane.TargetProperty.Value = macroData.TargetProperty
						pane:SetCustomResults(customResults, useWidget)
						activeMacro = macroData

						if leavePaneOpen then
							leaveActiveMacroOpen = true
						end

						return
					end

					if not leavePaneOpen then
						activeMacro = nil
					end

					local newSelection = {}
					local selectedInstances = Selection:Get()

					-- HACK: This is necessary because if you click a
					-- TextButton in the palette, your selection will be
					-- cleared, which is not desired. idk if this will lead to
					-- more unintended behavior yet, also if you collapse a
					-- group it will clear your selection before a macro is
					-- selected.
					local revertSelection = false
					if (not selectedInstances or #selectedInstances == 0) and pane.TargetSelection.Value then
						selectedInstances = pane.TargetSelection.Value
						revertSelection = true
					end

					local undoRecording
					local toggledInstance
					local packedArguments = table.pack(...)

					lastActivated = activated
					lastArguments = packedArguments

					local function startRecording()
						undoRecording = ChangeHistoryService:TryBeginRecording(macroData.Name)
						if not undoRecording then
							warn("[StudioMacros]: Failed to begin recording for", macroData.Name)
						end
					end

					local function closePane()
						if leavePaneOpen then
							return
						end

						if leaveActiveMacroOpen then
							pane:SetCustomResults(nil)
						else
							pane:Hide()
						end
					end

					local success, macroError = xpcall(function()
						if #selectedInstances > 0 and macroData.RunOnSelection then
							local validInstances = {}
							for _, selectedInstance in selectedInstances do
								if macroData.Predicate and not macroData.Predicate(selectedInstance) then
									print(macroData.Name, "failed predicate", selectedInstance)
									continue
								end

								table.insert(validInstances, selectedInstance)
							end

							if #validInstances > 0 then
								startRecording()

								local newInstance = macroData.Macro(validInstances, plugin, table.unpack(packedArguments, 1, packedArguments.n))
								toggledInstance = validInstances[1]

								closePane()
								appendSelection(newSelection, newInstance)
							end
						elseif #selectedInstances > 0 then
							startRecording()
							for _, selectedInstance in selectedInstances do
								if macroData.Predicate then
									local validInstance = macroData.Predicate(selectedInstance)
									if not validInstance then
										print(macroData.Name, "failed predicate", selectedInstance)
										continue
									end
								end

								local newInstance = macroData.Macro(selectedInstance, plugin, table.unpack(packedArguments, 1, packedArguments.n))
								toggledInstance = selectedInstance

								closePane()
								appendSelection(newSelection, newInstance)
							end
						else
							if not macroData.Predicate then
								startRecording()
								local newInstance = macroData.Macro(nil, plugin, table.unpack(packedArguments, 1, packedArguments.n))

								closePane()
								appendSelection(newSelection, newInstance)
							end
						end

						leaveActiveMacroOpen = nil

						if #newSelection > 0 then
							Selection:Set(newSelection)
							pane.TargetSelection.Value = newSelection
						elseif revertSelection then
							Selection:Set(selectedInstances)
							pane.TargetSelection.Value = selectedInstances
						end
					end, debug.traceback)

					if undoRecording then
						local operation = Enum.FinishRecordingOperation.Cancel
						if success then
							operation = Enum.FinishRecordingOperation.Commit
						end
						ChangeHistoryService:FinishRecording(undoRecording, operation)
					end

					if success then
						toast:ShowMacro(
							getToastName(macroData, toggledInstance),
							groupData.Icon,
							getToastValue(macroData, toggledInstance)
						)
					end

					if not success then
						error(macroError, 0)
					end
				end

				maid:GiveTask(pane.CustomResultActivated:Connect(function(customResult, ...)
					if activeMacro ~= macroData then
						return
					end

					if customResult == macroData.CustomResults then
						activated(...)
					end
				end))

				maid:GiveTask(macroEntry.Activated:Connect(activated))
				if pluginAction then
					maid:GiveTask(pluginAction.Triggered:Connect(activated))
				end
			end
		end
	end

	return maid
end

if plugin then
	local currentMaid = initialize(plugin)

	-- The palette has no API to drop a group, so a reload rebuilds the whole thing. The cached
	-- PluginActions survive it, which is the only reason a rebuild is legal at all.
	local watchMaid = Maid.new()
	local queued = false

	local function reload()
		if queued then
			return
		end
		queued = true

		task.delay(LIVE_DEBOUNCE, function()
			queued = false
			if currentMaid then
				currentMaid:Destroy()
			end
			currentMaid = initialize(plugin)
		end)
	end

	local function watch(liveRoot)
		watchMaid:GiveTask(liveRoot.DescendantAdded:Connect(reload))
		watchMaid:GiveTask(liveRoot.DescendantRemoving:Connect(reload))
		watchMaid:GiveTask(liveRoot.Changed:Connect(reload))
	end

	local liveRoot = ServerStorage:FindFirstChild(LIVE_FOLDER)
	if liveRoot then
		watch(liveRoot)
	end

	-- The folder is usually absent until the sync tool writes it, so pick it up whenever it appears.
	watchMaid:GiveTask(ServerStorage.ChildAdded:Connect(function(Child)
		if Child.Name == LIVE_FOLDER then
			watch(Child)
			reload()
		end
	end))

	plugin.Unloading:Connect(function()
		watchMaid:Destroy()
	end)
end
