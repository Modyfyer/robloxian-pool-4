local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local StarterGui = game:GetService("StarterGui")
-- local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- local screenGui = LocalPlayer.PlayerGui:WaitForChild("HUDGui")
-- local desktopFrame = screenGui:WaitForChild("Desktop")

local UIManager = {}
UIManager.__index = UIManager

--[[**
	Creates new instance

	@param [t:ScreenGui] screenGui The platform specific screenGui
**--]]
function new(screenGui)
	local self = setmetatable({}, UIManager)
	
	self._mainFrame = screenGui:WaitForChild("Mobile")
	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu")
	
	_connectHandlers(self)
	
	return self
end

function UIManager:OpenMenu()
	
end

function _connectHandlers(_)
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
end

return {
	new = new
}