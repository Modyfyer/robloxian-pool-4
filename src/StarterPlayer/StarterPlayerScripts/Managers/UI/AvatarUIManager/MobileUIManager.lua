--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Avatar UI for mobile

Initialized by: AvatarUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)

--Declarations
local LocalPlayer = Players.LocalPlayer

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local Items: Folder = ReplicatedStorage:WaitForChild("Items")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local slotTween: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._mainFrame = screenGui:WaitForChild("Mobile") :: Frame
	self._connectionManager = ConnectionManager.new()

	self._inventory = {}

	local outfit: ItemsData.Outfit = {
		floaties = {},
		hats = {},
		pants = {},
		swimsuits = {}
	}
	self._outfit = outfit

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: GuiButton
	self._inventoryContainer = self._background:WaitForChild("ScrollingFrame") :: ScrollingFrame
	self._tabs = self._background:WaitForChild("Tabs") :: Frame

	self._slotPrefab = self._inventoryContainer:WaitForChild("Slot") :: ImageLabel

	self.AvatarButtonPressed = BindableEvents:WaitForChild("AvatarButtonPressed") :: BindableEvent
	self.AvatarMenuClosed = BindableEvents:WaitForChild("AvatarMenuClosed") :: BindableEvent
	self.LoadAvatar = RemoteEvents:WaitForChild("LoadAvatar") :: RemoteEvent
	self.SaveAvatar = RemoteEvents:WaitForChild("SaveAvatar") :: RemoteEvent
	self.LoadInventory = RemoteEvents:WaitForChild("LoadInventory") :: RemoteEvent
	self.SaveInventory = RemoteEvents:WaitForChild("SaveInventory") :: RemoteEvent

	_connectHandlers(self)

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

	--Menu open/close
	self._connectionManager:ConnectToEvent(self.AvatarButtonPressed.Event, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(closeTween.Completed, function()
		self.AvatarMenuClosed:Fire()
	end)

	--Inventory
	self._connectionManager:ConnectToEvent(self.LoadInventory.OnClientEvent, function(inventory)
		self._inventory = inventory
		_loadInventory(self)
	end)
	self._connectionManager:ConnectToEvent(self._inventoryContainer.UIListLayout.Changed, function(property)
		if property ~= "AbsoluteContentSize" then
			return
		end

		local contentSize: Vector2 = self._inventoryContainer.UIListLayout.AbsoluteContentSize
		self._inventoryContainer.CanvasSize = UDim2.fromOffset(0, contentSize.Y)
	end)

	--Avatar
	self._connectionManager:ConnectToEvent(self.LoadAvatar.OnClientEvent, function(outfit)
		self._outfit = outfit
		_loadAvatar(self)
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
	local selectedSlots: {boolean} = {}

	local function _createItemFrame(item: ItemsData.InventoryItem, category: string, index: number)
		local newSlot: ImageLabel = self._slotPrefab:Clone()
		newSlot:SetAttribute("Category", category)
		newSlot:SetAttribute("ItemID", item.itemID)
		newSlot:SetAttribute("Index", index)
		newSlot.ItemName.Text = item.displayName
		newSlot.Visible = true
		newSlot.Name = "ItemSlot"
		newSlot.Parent = self._inventoryContainer

		selectedSlots[index] = false

		local button: ImageButton = newSlot.Button
		local buttonDownTween = TweenService:Create(newSlot.UIStroke, slotTween, {Color = Color3.fromRGB(255, 255, 255)})
		local buttonUpTween = TweenService:Create(newSlot.UIStroke, slotTween, {Color = Color3.fromRGB(0, 0, 0)})
		local debounce: boolean = false

		--Selection
		for _, outfitItem in pairs(self._outfit[category]) do
			if outfitItem.itemID == item.itemID then
				selectedSlots[index] = true
				newSlot.UIStroke.Color = Color3.fromRGB(0, 255, 0)
			end
		end

		--Button Connections
		self._connectionManager:ConnectToEvent(button.MouseButton1Down, function()
			if not debounce then
				debounce = true
				buttonDownTween:Play()
				selectedSlots[index] = not selectedSlots[index]
				task.wait(1)
				debounce = false
			end

			if selectedSlots[index] then
				table.insert(self._outfit[category], item)

				local toEquip: {ItemsData.InventoryItem} = {item}
				_equipAccessories(LocalPlayer.Character, toEquip)
			else
				for itemIndex, outfitItem in pairs(self._outfit[category]) do
					if outfitItem.itemID == item.itemID then
						table.remove(self._outfit[category], itemIndex)
						local attach: Accessory? = LocalPlayer.Character:FindFirstChild(item.displayName)
						if attach then
							attach:Destroy()
						end
					end
				end
			end
			_saveAvatar(self)
		end)
		self._connectionManager:ConnectToEvent(button.MouseButton1Up, function()
			buttonUpTween:Play()
		end)
		self._connectionManager:ConnectToEvent(buttonUpTween.Completed, function()
			if selectedSlots[index] then
				newSlot.UIStroke.Color = Color3.fromRGB(0, 255, 0)
			else
				newSlot.UIStroke.Color = Color3.fromRGB(0, 0, 0)
			end
		end)
	end

	for category, data in pairs(inventory) do
		if table.find(categoriesToDisplay, tostring(category)) then
			for index, item in pairs(data) do
				_createItemFrame(item, tostring(category), index)
			end
		end
	end
end

function _equipAccessories(character: Model, accessories: {ItemsData.InventoryItem})
	local humanoid: Humanoid? = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end

	for _, accessory:ItemsData.InventoryItem in pairs(accessories) do
		local itemFolder: Folder? = Items:WaitForChild(accessory.category)
		if itemFolder then
			for _, item in pairs(itemFolder:GetChildren()) do
				if item.Name == accessory.displayName then
					local newItem = item:Clone()

					humanoid:AddAccessory(newItem)
				end
			end
		end
	end

	humanoid:BuildRigFromAttachments()
end

function _initTabs(self)
	local function onTabButtonPressed(buttonName: string)
		for _, slot in pairs(self._inventoryContainer:GetChildren()) do
			if slot.Name == "ItemSlot" then
				local category = slot:GetAttribute("Category")
				if category ~= nil and (string.lower(buttonName) == string.lower(category)) then
					slot.Visible = true
				else
					slot.Visible = false
				end
			end
		end

		for _, tab in pairs(self._tabs:GetChildren()) do
			if tab:IsA("ImageButton") then
				if string.lower(buttonName) == string.lower(tab.Name) then
					tab.UIStroke.Color = Color3.fromRGB(255, 255, 255)
				else
					tab.UIStroke.Color = Color3.fromRGB(14, 82, 167)
				end
			end
		end
	end

	--Tabs
	for _, tab in pairs(self._tabs:GetChildren()) do
		if tab:IsA("ImageButton") then
			self._connectionManager:ConnectToEvent(tab.MouseButton1Click, function()
				onTabButtonPressed(tab.Name)
			end)
		end
	end
	onTabButtonPressed("Swimsuits")
end

function _loadAvatar(self)
	local char: Model? = LocalPlayer.Character
	if not char then
		return
	end

	if self._outfit ~= nil then
		local accessories: {ItemsData.InventoryItem} = {}
		for _, v in pairs(self._outfit) do
			for _, vv in pairs(v) do
				table.insert(accessories, vv)
			end
		end
		_equipAccessories(char, accessories)
	end
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
	_createInventoryItemFrames(self)
	_initTabs(self)
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