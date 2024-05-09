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
local Event = require(ReplicatedStorage.Utils.Event)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local LocalPlayer = Players.LocalPlayer
local LocalChar = LocalPlayer.Character

local DEFAULT_WALKSPEED: number = 16
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	-- Dependency group 0
	self._mainFrame = screenGui:WaitForChild("Desktop")
	self._connectionManager = ConnectionManager.new()

	-- Dependency group 1
	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu")
	self._drownFrame = self._mainFrame:WaitForChild("DrownAnim")
	self._progressBars = self._mainFrame:WaitForChild("ProgressBars")
	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft")
	self._tooltip = self._mainFrame:WaitForChild("ButtonTooltip")

	self._oxygenBar = self._progressBars:WaitForChild("OxygenMeter"):WaitForChild("BG"):WaitForChild("Amount")
	self._oxygenVal = LocalChar:WaitForChild("Oxygen")

	self._waterBar = self._progressBars:WaitForChild("WaterMeter"):WaitForChild("BG"):WaitForChild("Amount")
	self._waterVal = LocalChar:WaitForChild("Water")

	self.AvatarButtonEvent = BindableEvents:WaitForChild("AvatarButtonPressed")

	-- Dependency group 2
	-- self._actions = self._actionsMenu:WaitForChild("BG"):WaitForChild("Actions")
	self._actionsAnimations = self._actionsMenu:WaitForChild("Animations")

	self._avatarButton = self._sidebarLeft:WaitForChild("AvatarButton"):WaitForChild("Button")
	self._emotesButton = self._sidebarLeft:WaitForChild("EmotesButton"):WaitForChild("Button")
	self._settingsButton = self._sidebarLeft:WaitForChild("SettingsButton"):WaitForChild("Button")
	self._shopsButton = self._sidebarLeft:WaitForChild("ShopsButton"):WaitForChild("Button")

	local drownTweenInfo : TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	self._drownAnimA = TweenService:Create(self._drownFrame, drownTweenInfo, {BackgroundTransparency = 0})
	self._drownAnimB = TweenService:Create(self._drownFrame, drownTweenInfo, {BackgroundTransparency = 1})

	_connectAnimationHandlers(self)
	_connectButtonHandlers(self)
	_connectMeterHandlers(self)

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

function _connectAnimationHandlers(self)
	--Character declarations
	local character = LocalPlayer.Character
	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	local actionKeys: {string: Enum.KeyCode} = {
		Cannonball = Enum.KeyCode.X,
		Dive = Enum.KeyCode.C,
		FrontFlip = Enum.KeyCode.V,
		BackFlip = Enum.KeyCode.B,
		Whistle = Enum.KeyCode.N
	}

	local debounce: boolean = false

	--Animations--
	local function cannonballAnimation(anim: Animation, action: Enum.KeyCode)
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

				--actionUI.UIStroke.Enabled = true
				task.wait(.5)
				force:Destroy()
				task.wait(3)
				debounce = false

				--actionUI.UIStroke.Enabled = false
			end
		end
	end

	local function diveAnimation(anim)
		print("dive anim")
	end

	--Input handler--
	local function onInputBegan(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local keycode: string = input.KeyCode.Name

		-- if not self.actionSelected then
		-- 	for _, action: Frame in pairs(actionKeys) do
		-- 		if action:GetAttribute("Keybind") == keycode then
		-- 			--Find the animation that matches the keybind
		-- 			for _, anim: Animation in pairs(self._actionsAnimations:GetChildren()) do
		-- 				local keybind: string? = anim:GetAttribute("Keybind")
		-- 				if keybind == keycode then
		-- 					if keybind == "X" then
		-- 						cannonballAnimation(anim, action)
		-- 					elseif keybind == "C" then
		-- 						diveAnimation(anim)
		-- 					end
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- end
	end

	self._connectionManager:ConnectToEvent(UserInputService.InputBegan, function(input)
		onInputBegan(input)
	end)
end

function _connectButtonHandlers(self)
	--Tooltip--
	local function showTooltip(x: number, y: number, text: string)
		local OFFSET = 50
		self._tooltip.Position = UDim2.new(0, x + OFFSET, 0, y + OFFSET)
		self._tooltip.Visible = true
		self._tooltip.Tooltip.Text = text
	end

	local function setTooltipPosition(x: number, y: number)
		self._tooltip.Position = UDim2.new(0, x, 0, y)
	end

	local function hideTooltip()
		self._tooltip.Position = UDim2.new(0.5,0,0.5,0)
		self._tooltip.Tooltip.Text = ""
		self._tooltip.Visible = false
	end

	-------------------Listeners-----------------
	----Sidebar Left----
	--Avatar
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseButton1Click, function()
		self.AvatarButtonEvent:Fire()
	end)
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Avatar")
	end)
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseMoved, setTooltipPosition)
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseLeave, hideTooltip)

	--Emotes
	self._connectionManager:ConnectToEvent(self._emotesButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Emotes")
	end)
	self._connectionManager:ConnectToEvent(self._emotesButton.MouseMoved, setTooltipPosition)
	self._connectionManager:ConnectToEvent(self._emotesButton.MouseLeave, hideTooltip)

	--Settings
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseButton1Click, function()
		print("settings")
	end)
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Settings")
	end)
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseMoved, setTooltipPosition)
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseLeave, hideTooltip)

	--Shops
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseButton1Click, function()
	
	end)
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Shops")
	end)
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseMoved, setTooltipPosition)
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseLeave, hideTooltip)
end

function _connectMeterHandlers(self)
	--Character declarations
	local character = LocalPlayer.Character
	local humanoid = character:WaitForChild("Humanoid")

	--Oxygen UI
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
		local scaled = (oxLev / MAX_OXYGEN)--math.clamp(oxLev / 100, 0, 1)
		self._oxygenBar:TweenSize(UDim2.fromScale(scaled, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.5)
		--self._oxygenBar.Size = UDim2.new(scaled, 0, 1, 0)

		if oxLev <= 0 then
			self._drownFrame.Visible = true
			self._drownAnimA:Play()
			humanoid.WalkSpeed = 0
			task.wait(4)
			self._drownAnimB:Play()
			task.wait(3)
			self._drownFrame.Visible = false
			humanoid.WalkSpeed = DEFAULT_WALKSPEED
		end
	end

	--Water UI
	local function onWaterValueChanged()
		local waterLev: number = self._waterVal.Value
		local scaled = (waterLev / MAX_WATER)--math.clamp(waterLev / 100, 0, 1)
		self._waterBar:TweenSize(UDim2.fromScale(scaled, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.5)
		--self._waterBar.Size = UDim2.new(scaled, 0, 1, 0)
	end

	--Listeners
	self._connectionManager:ConnectToEvent(self._oxygenVal.Changed, onOxygenValueChanged)
	self._connectionManager:ConnectToEvent(self._waterVal.Changed, onWaterValueChanged)
end

return {
	new = new
}