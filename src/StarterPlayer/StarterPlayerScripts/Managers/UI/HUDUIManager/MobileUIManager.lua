--[[--<<---------------------------------------------------->>--
Module purpose: Handles the HUD UI for mobile

Initialized by: HUDUIManager
--]]--<<---------------------------------------------------->>--

--Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
--local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local LocalPlayer = Players.LocalPlayer
local LocalChar = LocalPlayer.Character

local DEFAULT_WALKSPEED: number = 16
local LIFEGUARD_GAMEPASS_ID = 703084245
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100
local UI_NAME: string = "Mobile"

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	-- Dependency group 0
	self._mainFrame = screenGui:WaitForChild(UI_NAME) :: Frame
	self._connectionManager = ConnectionManager.new()

	-- Dependency group 1
	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu") :: Frame
	self._drownFrame = self._mainFrame:WaitForChild("DrownAnim") :: Frame
	self._progressBars = self._mainFrame:WaitForChild("ProgressBars") :: Frame
	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft") :: Frame
	self._sidebarRight = self._mainFrame:WaitForChild("SidebarRight") :: Frame

	self._oxygenBar = self._progressBars:WaitForChild("OxygenMeter"):WaitForChild("BG"):WaitForChild("Amount") :: ImageLabel
	self._oxygenVal = LocalChar:WaitForChild("Oxygen")

	self._waterBar = self._progressBars:WaitForChild("WaterMeter"):WaitForChild("BG"):WaitForChild("Amount") :: ImageLabel
	self._waterVal = LocalChar:WaitForChild("Water")

	self.AvatarButtonPressed = BindableEvents:WaitForChild("AvatarButtonPressed") :: BindableEvent
	self.EmotesButtonPressed = BindableEvents:WaitForChild("EmotesButtonPressed") :: BindableEvent
	self.SettingsButtonPressed = BindableEvents:WaitForChild("SettingsButtonPressed") :: BindableEvent
	self.ShopsButtonPressed = BindableEvents:WaitForChild("ShopsButtonPressed") :: BindableEvent

	self.AvatarMenuClosed = BindableEvents:WaitForChild("AvatarMenuClosed") :: BindableEvent
	self.EmotesMenuClosed = BindableEvents:WaitForChild("EmotesMenuClosed") :: BindableEvent
	self.SettingsMenuClosed = BindableEvents:WaitForChild("SettingsMenuClosed") :: BindableEvent
	self.ShopsMenuClosed = BindableEvents:WaitForChild("ShopsMenuClosed") :: BindableEvent

	-- Dependency group 2
	-- self._actions = self._actionsMenu:WaitForChild("BG"):WaitForChild("Actions")
	self._actionsAnimations = self._actionsMenu:WaitForChild("Animations") :: Folder

	self._avatarButton = self._sidebarLeft:WaitForChild("AvatarButton"):WaitForChild("Button") :: GuiButton
	self._emotesButton = self._sidebarLeft:WaitForChild("EmotesButton"):WaitForChild("Button") :: GuiButton
	self._lifeguardButton = self._sidebarRight:WaitForChild("LifeguardButton"):WaitForChild("Button") :: GuiButton
	self._settingsButton = self._sidebarLeft:WaitForChild("SettingsButton"):WaitForChild("Button") :: GuiButton
	self._shopsButton = self._sidebarLeft:WaitForChild("ShopsButton"):WaitForChild("Button") :: GuiButton

	local drownTweenInfo : TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local lifeguardButtonTweenInfo: TweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)

	self._drownAnimA = TweenService:Create(self._drownFrame, drownTweenInfo, {BackgroundTransparency = 0}) :: Tween
	self._drownAnimB = TweenService:Create(self._drownFrame, drownTweenInfo, {BackgroundTransparency = 1}) :: Tween
	self._lifeguardSpinTween = TweenService:Create(self._lifeguardButton, lifeguardButtonTweenInfo, {Rotation = 360}) :: Tween

	local states: {string: boolean} = {
		avatar = false,
		emotes = false,
		shops = false,
		settings = false
	}
	self.States = states

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
	-- local character = LocalPlayer.Character
	-- local hrp = character:WaitForChild("HumanoidRootPart")
	-- local humanoid = character:WaitForChild("Humanoid")

	-- local debounce: boolean = false

	--Animations--
	-- local function cannonballAnimation(anim: Animation, action: Enum.KeyCode)
	-- 	if not debounce then
	-- 		if humanoid.Sit == false then
	-- 			debounce = true
	-- 			local animTrack = humanoid:LoadAnimation(anim)
	-- 			local force = Instance.new("VectorForce")

	-- 			force.Parent = hrp
	-- 			force.Force = Vector3.new(0, 4500, -1200)
	-- 			force.ApplyAtCenterOfMass = true
	-- 			force.Attachment0 = hrp:FindFirstChildWhichIsA("Attachment")

	-- 			animTrack:Play()
	-- 			humanoid.Sit = true

	-- 			--actionUI.UIStroke.Enabled = true
	-- 			task.wait(.5)
	-- 			force:Destroy()
	-- 			task.wait(3)
	-- 			debounce = false

	-- 			--actionUI.UIStroke.Enabled = false
	-- 		end
	-- 	end
	-- end

	--Input handler--
	local function onInputBegan(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		--local keycode: string = input.KeyCode.Name
	end

	self._connectionManager:ConnectToEvent(UserInputService.InputBegan, function(input)
		onInputBegan(input)
	end)
end

function _connectButtonHandlers(self)
	--Menus
	local function hideUIs(uiToShow: string)
		for ui: string, state: boolean in pairs(self.States) do
			if (ui ~= uiToShow) and state then
				print(self.States[ui])
				self.States[ui] = false
				if ui == "avatar" then
					self.AvatarButtonPressed:Fire(self.States[ui])
				elseif ui == "emotes" then
					self.EmotesButtonPressed:Fire(self.States[ui])
				elseif ui == "settings" then
					self.SettingsButtonPressed:Fire(self.States[ui])
				elseif ui == "shops" then
					self.ShopsButtonPressed:Fire(self.States[ui])
				end
			end
		end
	end

	-------------------Listeners-----------------
	----Sidebar Left----
	--Avatar
	self._connectionManager:ConnectToEvent(self._avatarButton.MouseButton1Click, function()
		local menu: string = "avatar"
		self.States[menu] = not self.States[menu]
		self.AvatarButtonPressed:Fire(self.States[menu])
		hideUIs(menu)
	end)
	self._connectionManager:ConnectToEvent(self.AvatarMenuClosed.Event, function()
		self.States["avatar"] = false
	end)

	--Emotes
	self._connectionManager:ConnectToEvent(self._emotesButton.MouseButton1Click, function()
		local menu: string = "emotes"
		self.States[menu] = not self.States[menu]
		self.EmotesButtonPressed:Fire(self.States[menu])
		hideUIs(menu)
	end)
	self._connectionManager:ConnectToEvent(self.EmotesMenuClosed.Event, function()
		self.States["emotes"] = false
	end)

	--Lifeguard
	self._connectionManager:ConnectToEvent(self._lifeguardButton.MouseButton1Click, function()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, LIFEGUARD_GAMEPASS_ID)
	end)

	self._lifeguardSpinTween:Play()

	--Settings
	self._connectionManager:ConnectToEvent(self._settingsButton.MouseButton1Click, function()
		local menu: string = "settings"
		self.States[menu] = not self.States[menu]
		self.SettingsButtonPressed:Fire(self.States[menu])
		hideUIs(menu)
	end)
	self._connectionManager:ConnectToEvent(self.SettingsMenuClosed.Event, function()
		self.States["settings"] = false
	end)

	--Shops
	self._connectionManager:ConnectToEvent(self._shopsButton.MouseButton1Click, function()
		local menu: string = "shops"
		self.States[menu] = not self.States[menu]
		self.ShopsButtonPressed:Fire(self.States[menu])
		hideUIs(menu)
	end)
	self._connectionManager:ConnectToEvent(self.ShopsMenuClosed.Event, function()
		self.States["shops"] = false
	end)
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
	end

	--Listeners
	self._connectionManager:ConnectToEvent(self._oxygenVal.Changed, onOxygenValueChanged)
	self._connectionManager:ConnectToEvent(self._waterVal.Changed, onWaterValueChanged)
end

return {
	new = new
}