--[[--<<---------------------------------------------------->>--
Module purpose: Handles the HUD UI for mobile

Public functions:
-Show()
-Hide()

Initialized by: HUDUIManager
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local LocalChar = LocalPlayer.Character

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
--local UIHelpers = require(LocalPlayer.PlayerScripts.UIHelpers)

local DEFAULT_WALKSPEED = 16
local OXYGEN_SCALE = (70 / 100)
local WATER_SCALE = (180 / 100)

local drownTweenInfo: TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local UIManager = {}
UIManager.__index = UIManager

--[[**
	Creates new instance

	@param [t:ScreenGui] screenGui The platform specific screenGui
**--]]
function new(screenGui)
	local self = setmetatable({}, UIManager)
	
	self._mainFrame = screenGui:WaitForChild("Mobile")
	self._localCharacterHumanoid = LocalChar:WaitForChild("Humanoid")

	self._connectionManager = ConnectionManager.new()

	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft")
	self._sidebarRight = self._mainFrame:WaitForChild("SidebarRight")
	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu")
	self._progressBars = self._mainFrame:WaitForChild("ProgressBars")

	
	self._avatarButton = self._sidebarLeft:WaitForChild("AvatarButton")
	self._emotesButton = self._sidebarLeft:WaitForChild("EmotesButton")
	self._settingsButton = self._sidebarLeft:WaitForChild("SettingsButton")

	self._oxygenBar = self._progressBars:WaitForChild("OxygenMeter"):WaitForChild("BG"):WaitForChild("Amount")
	self._oxygenVal = LocalChar:WaitForChild("Oxygen")

	self._waterBar = self._progressBars:WaitForChild("WaterMeter"):WaitForChild("BG"):WaitForChild("Amount")
	self._waterVal = LocalChar:WaitForChild("Water")

	self._drownFrame = self._mainFrame:WaitForChild("DrownAnim")

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

--[[**
	Shows UI
**--]]
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

function _connectHandlers(self)
	-- self._actionsMenu.ButtonClose.MouseButton1Click:Connect(function()
	-- 	self._actionsMenu.MenuOpen.Visible = false
	-- 	self._actionsMenu.MenuClosed.Visible = true
	-- 	self._actionsMenu.ButtonOpen.Visible = true
	-- 	self._actionsMenu.ButtonClose.Visible = false
	-- end)
	-- self._actionsMenu.ButtonOpen.MouseButton1Click:Connect(function()
	-- 	self._actionsMenu.MenuOpen.Visible = true
	-- 	self._actionsMenu.MenuClosed.Visible = false
	-- 	self._actionsMenu.ButtonOpen.Visible = false
	-- 	self._actionsMenu.ButtonClose.Visible = true
	-- end)

	local function onOxygenValueChanged()
		local oxLev = self._oxygenVal.Value
		self._oxygenBar.Size = UDim2.new(1, 0, 0, ((OXYGEN_SCALE) * oxLev))
		self._oxygenBar.Position = UDim2.new(0, 0, 1, ((OXYGEN_SCALE * oxLev) * -1))
	
		if oxLev <= 0 then
			self._drownFrame.Visible = true
			self._drownAnimA:Play()
			self._localCharacterHumanoid.WalkSpeed = 0
			task.wait(4)
			self._drownAnimB:Play()
			task.wait(3)
			self._drownFrame.Visible = false
			self._localCharacterHumanoid.WalkSpeed = DEFAULT_WALKSPEED
		end
	end

	local function onWaterValueChanged()
		local waterLev = self._waterVal.Value
		self._waterBar.Size = UDim2.new(0, (WATER_SCALE * waterLev), 1, 0)
	end

	local function onMouseMoved()
		
	end

	self._connectionManager:ConnectToEvent(self._oxygenVal.Changed, onOxygenValueChanged)
	self._connectionManager:ConnectToEvent(self._waterVal.Changed, onWaterValueChanged)

	self._connectionManager:ConnectToEvent(self._avatarButton.MouseMoved, onMouseMoved)
end

return {
	new = new
}