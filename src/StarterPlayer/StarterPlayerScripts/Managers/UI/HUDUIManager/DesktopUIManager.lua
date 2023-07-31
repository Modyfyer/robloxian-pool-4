--[[--<<---------------------------------------------------->>--
Module purpose: Handles the HUD UI for desktop

Initialized by: HUDUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
local LocalPlayer = Players.LocalPlayer
local LocalChar = LocalPlayer.Character

local DEFAULT_WALKSPEED = 16
local OXYGEN_SCALE = (70 / 100)
local WATER_SCALE = (180 / 100)

local drownTweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local debounce = false

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	-- Dependency group 0
	self._mainFrame = screenGui:WaitForChild("Desktop")
	self._localCharacterHumanoid = LocalChar:WaitForChild("Humanoid")

	self._connectionManager = ConnectionManager.new()

	self._actionKeys = {
		Cannonball = "X",
		Dive = "C",
		FrontFlip = "V",
		BackFlip = "B",
		Whistle = "N"
	}
	self._actionSelected = false

	-- Dependency group 1
	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu")
	self._avatarButton = self._mainFrame:WaitForChild("AvatarButton")
	self._drownFrame = self._mainFrame:WaitForChild("DrownAnim")
	self._emotesButton = self._mainFrame:WaitForChild("EmotesButton")
	self._settingsButton = self._mainFrame:WaitForChild("SettingsButton")
	self._shopsButton = self._mainFrame:WaitForChild("ShopsButton")
	self._tooltip = self._mainFrame:WaitForChild("ButtonTooltip")

	self._oxygenBar = self._mainFrame:WaitForChild("OxygenMeter"):WaitForChild("OxygenLevelBG"):WaitForChild("OxygenLevel")
	self._oxygenVal = LocalChar:WaitForChild("Oxygen")

	self._waterBar = self._mainFrame:WaitForChild("WaterMeter"):WaitForChild("WaterLevel")
	self._waterVal = LocalChar:WaitForChild("Water")

	-- Dependency group 2
	self._actions = self._actionsMenu:WaitForChild("BG"):WaitForChild("Actions")
	self._actionsAnimations = self._actionsMenu:WaitForChild("Animations")

	self._drownAnimA = TweenService:Create(self._drownFrame, drownTweenInfo, {BackgroundTransparency = 0})
	self._drownAnimB = TweenService:Create(self._drownFrame, drownTweenInfo, {BackgroundTransparency = 1})

	_connectHandlers(self)

	return self
end

--[[**
	Hides UI
**--]]
function UIManager:Hide()
	self._connectionManager:DisconnectAll()
	self._mainFrame.Visible = false
end

--Shows UI
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	local character = LocalPlayer.Character
	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	local function onOxygenValueChanged()
		character = LocalPlayer.Character
		if not character then
			return
		end

		humanoid = character:WaitForChild("Humanoid")
		if not humanoid then
			return
		end

		local oxLev: number = self._oxygenVal.Value
		self._oxygenBar.Size = UDim2.new(1, 0, 0, ((OXYGEN_SCALE) * oxLev))
		self._oxygenBar.Position = UDim2.new(0, 0, 1, ((OXYGEN_SCALE * oxLev) * -1))

		if oxLev <= 0 then
			self._drownFrame.Visible = true
			self._drownAnimA:Play()
			humanoid.WalkSpeed = 0
			task.wait(4)
			self._drownAnimB:Play()
			task.wait(3)
			self._drownFrame.Visible = false
			humanoid.WalkSpeed = DEFAULT_WALKSPEED

			--_resetActionSelections(self)
		end
	end

	local function onWaterValueChanged()
		local waterLev = self._waterVal.Value
		self._waterBar.Size = UDim2.new(1, 0, 0, (WATER_SCALE * waterLev))
	end

	local function onMouseEnter(x, y, text)
		local OFFSET = 50
		self._tooltip.Position = UDim2.new(0, x + OFFSET, 0, y + OFFSET)
		self._tooltip.Visible = true
		self._tooltip.Tooltip.Text = text
	end

	local function onMouseMoved(x, y)
		self._tooltip.Position = UDim2.new(0, x, 0, y)
	end

	local function onMouseLeave()
		self._tooltip.Position = UDim2.new(0.5,0,0.5,0)
		self._tooltip.Tooltip.Text = ""
		self._tooltip.Visible = false
	end

	-- local function onActionsMenuOpened()
	-- 	self._actionsMenu.MenuOpen.Visible = true
	-- 	self._actionsMenu.MenuClosed.Visible = false
	-- end

	-- local function onActionsMenuClosed()
	-- 	self._actionsMenu.MenuOpen.Visible = false
	-- 	self._actionsMenu.MenuClosed.Visible = true
	-- end

	local function cannonballAnimation(anim, actionUI)
		if not debounce then
			if humanoid.Sit == false then
				debounce = true
				local animTrack = humanoid:LoadAnimation(anim)
				local force = Instance.new("VectorForce")

				force.Parent = hrp
				force.Force = Vector3.new(0, 4500, -1200)
				force.ApplyAtCenterOfMass = true
				force.Attachment0 = hrp:FindFirstChildWhichIsA("Attachment")

				animTrack:Play()
				humanoid.Sit = true
				self.actionSelected = true
				actionUI.UIStroke.Enabled = true
				task.wait(.5)
				force:Destroy()
				task.wait(3)
				debounce = false
				self.actionSelected = false
				actionUI.UIStroke.Enabled = false
			end
		end
	end

	local function diveAnimation(anim)

	end

	local function onInputBegan(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local keycode = input.KeyCode

		if not self.actionSelected then
			for _, action in pairs(self._actions:GetChildren()) do
				if action:GetAttribute("Keybind") == keycode.Name then
					--Find the animation that matches the keybind
					for _, anim in pairs(self._actionsAnimations:GetChildren()) do
						local keybind = anim:GetAttribute("Keybind")
						if keybind == keycode.Name then
							if keybind == "X" then
								cannonballAnimation(anim, action)
							elseif keybind == "C" then
								diveAnimation(anim)
							end
						end
					end
				end
			end
		end
	end

	--Connections
	self._connectionManager:ConnectToEvent(UserInputService.InputBegan, function(input)
		onInputBegan(input)
	end)

	-- self._connectionManager:ConnectToEvent(self._actionsMenu.MenuOpen.ButtonClose.MouseButton1Click, onActionsMenuClosed)
	-- self._connectionManager:ConnectToEvent(self._actionsMenu.MenuClosed.ButtonOpen.MouseButton1Click, onActionsMenuOpened)

	self._connectionManager:ConnectToEvent(self._oxygenVal.Changed, onOxygenValueChanged)
	self._connectionManager:ConnectToEvent(self._waterVal.Changed, onWaterValueChanged)
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseEnter, function(x, y)
		onMouseEnter(x, y, "Avatar")
	end)
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseMoved, onMouseMoved)
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseLeave, onMouseLeave)

	self._connectionManager:ConnectToEvent(self._emotesButton.MouseEnter, function(x, y)
		onMouseEnter(x, y, "Emotes")
	end)
	self._connectionManager:ConnectToEvent(self._emotesButton.MouseMoved, onMouseMoved)
	self._connectionManager:ConnectToEvent(self._emotesButton.MouseLeave, onMouseLeave)

	self._connectionManager:ConnectToEvent(self._settingsButton.MouseEnter, function(x, y)
		onMouseEnter(x, y, "Settings")
	end)
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseMoved, onMouseMoved)
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseLeave, onMouseLeave)

	self._connectionManager:ConnectToEvent(self._shopsButton.MouseEnter, function(x, y)
		onMouseEnter(x, y, "Shops")
	end)
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseMoved, onMouseMoved)
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseLeave, onMouseLeave)
end

-- Resets the action selections
-- function _resetActionSelections(self)
-- 	for _, action in pairs(self._actions:GetChildren()) do
-- 		if action.Name ~= "UIListLayout" then
-- 			action.UIStroke.Enabled = false
-- 		end
-- 	end
-- 	self._selectedAction = false
-- end

return {
	new = new
}