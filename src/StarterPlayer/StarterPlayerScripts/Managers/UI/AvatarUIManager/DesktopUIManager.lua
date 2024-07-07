--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Avatar UI for desktop

Initialized by: AvatarUIManager
--]]--<<---------------------------------------------------->>--

--Services
--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
--local LocalPlayer = Players.LocalPlayer

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local Items: Folder = ReplicatedStorage:WaitForChild("Items")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._mainFrame = screenGui:WaitForChild("Desktop") :: Frame
	self._connectionManager = ConnectionManager.new()
	self._inventory = {}
	self._outfit = {}

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: GuiButton
	self._inventoryContainer = self._background:WaitForChild("ScrollingFrame") :: ScrollingFrame

	self._slotPrefab = self._inventoryContainer:WaitForChild("Slot") :: ImageLabel

	self.AvatarButtonPressed = BindableEvents:WaitForChild("AvatarButtonPressed") :: BindableEvent
	self.AvatarMenuClosed = BindableEvents:WaitForChild("AvatarMenuClosed") :: BindableEvent
	self.LoadAvatar = RemoteEvents:WaitForChild("LoadAvatar") :: RemoteEvent
	self.SaveAvatar = RemoteEvents:WaitForChild("SaveAvatar") :: RemoteEvent
	self.LoadInventory = RemoteEvents:WaitForChild("LoadInventory") :: RemoteEvent
	self.SaveInventory = RemoteEvents:WaitForChild("SaveInventory") :: RemoteEvent

	_connectHandlers(self)

	--self._connectionManager:ConnectAll()

	return self
end

--Hides UI
function UIManager:Hide()
	--self._connectionManager:DisconnectAll()
	self._mainFrame.Visible = false
end

--Shows UI
function UIManager:Show()
	--self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	local debounce: boolean = false
	local openTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})

	local function onAvatarButtonPressed(state: boolean?)
		if debounce then return end
		debounce = true
		if state then
			openTween:Play()
		else
			closeTween:Play()
		end
		task.wait(0.1)
		debounce = false
	end

	self._connectionManager:ConnectToEvent(self.AvatarButtonPressed.Event, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(closeTween.Completed, function()
		self.AvatarMenuClosed:Fire()
	end)
	self._connectionManager:ConnectToEvent(self.LoadInventory.OnClientEvent, function(inventory)
		self._inventory = inventory
		_clearInventoryFrame(self)
		_createInventoryItemFrames(self)
	end)
	self._connectionManager:ConnectToEvent(self._inventoryContainer.UIListLayout.Changed, function(property)
		if property ~= "AbsoluteContentSize" then
			return
		end

		local contentSize: Vector2 = self._inventoryContainer.UIListLayout.AbsoluteContentSize
		self._inventoryContainer.CanvasSize = UDim2.fromOffset(0, contentSize.Y)
	end)
end

function _clearInventoryFrame(self)
	for _, v in pairs(self._inventoryContainer:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Slot" then
			v:Destroy()
		end
	end
end

function _createInventoryItemFrames(self)
	local inventory = self._inventory
	local categoriesToDisplay: {string} = {"floaties", "hats", "outfits", "pants"}

	local function _createItemFrame(item, category)
		local newSlot: ImageLabel = self._slotPrefab:Clone()
		newSlot:SetAttribute("Category", category)
		newSlot.ItemName.Text = item.displayName
		newSlot.Visible = true
		newSlot.Name = "ItemSlot"
		newSlot.Parent = self._inventoryContainer
	end

	for category, data in pairs(inventory) do
		if table.find(categoriesToDisplay, tostring(category)) then
			for _, item in pairs(data) do
				_createItemFrame(item, category)
			end
		end
	end

end

function _loadAvatar(self)

end

function _saveAvatar(self)
	local outfit = {}
	if self._outfit ~= nil then
		outfit = self._outfit
	end
	self.SaveAvatar:FireServer(outfit)
end

function _loadInventory(self)
	_clearInventoryFrame(self)
end

function _saveInventory(self)
	local inventory = {}
	if self._inventory ~= nil then
		inventory = self._inventory
	end
	self.SaveInventory:FireServer(inventory)
end

return {
	new = new
}