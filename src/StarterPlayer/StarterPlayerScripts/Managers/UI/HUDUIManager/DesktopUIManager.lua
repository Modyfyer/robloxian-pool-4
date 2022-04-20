--[[--<<---------------------------------------------------->>--
Module purpose:Handles desktop HUD UI

Initialized by: HUDUIManager
--]]--<<---------------------------------------------------->>--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local UIHelpers = require(LocalPlayer.PlayerScripts.UIHelpers)

--local _SOUNDS_FOLDER = LocalPlayer.PlayerScripts:WaitForChild("Resources"):WaitForChild("Results"):WaitForChild("Sounds")

local UIManager = {}
UIManager.__index = UIManager

--[[**
	Creates new instance

	@param [t:ScreenGui] screenGui The platform specific screenGui
**--]]
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._connectionManager = ConnectionManager.new()

	self._mainFrame = screenGui:WaitForChild("Desktop")
	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu")

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

--[[**
	Clears UI and object values
**--]]
function UIManager:Clear()

end



--[[ Private functions ]]--

function _connectHandlers(self)
	self._actionsMenu.ButtonClose.MouseButton1Click:Connect(function()
		self._actionsMenu.MenuOpen.Visible = false
		self._actionsMenu.MenuClosed.Visible = true
		self._actionsMenu.ButtonOpen.Visible = true
		self._actionsMenu.ButtonClose.Visible = false
	end)
	self._actionsMenu.ButtonOpen.MouseButton1Click:Connect(function()
		self._actionsMenu.MenuOpen.Visible = true
		self._actionsMenu.MenuClosed.Visible = false
		self._actionsMenu.ButtonOpen.Visible = false
		self._actionsMenu.ButtonClose.Visible = true
	end)
	-- local function onReturnToHubButtonPressed()
	-- 	UIHelpers.PlaySoundByName("MenuOpen", _SOUNDS_FOLDER)
	-- end

	-- --Button mouse over
	-- local function onButtonMouseOver()
	-- 	UIHelpers.PlaySoundByName("ButtonMouseOver", _SOUNDS_FOLDER)
	-- end

	-- self._connectionManager:ConnectToEvent(self._mainFrame.HubButton.MouseButton1Click, onReturnToHubButtonPressed)
	-- self._connectionManager:ConnectToEvent(self._mainFrame.HubButton.MouseEnter, onButtonMouseOver)
end

return {
	new = new
}

