--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: CabanaUIManager
--]]--<<---------------------------------------------------->>--

--Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
--local CabanaSettingsByName = require(ReplicatedStorage.Data.CabanaSettingsByName)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)
local ItemType = require(ReplicatedStorage.Enums.ItemType)
--local SettingType = require(ReplicatedStorage.Enums.SettingType)

--Declarations
local LocalPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UIHelpers = require(LocalPlayer.PlayerScripts.UIHelpers)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._connectionManager = ConnectionManager.new()

	self._mainFrame = screenGui:WaitForChild("Desktop")

	self._purchasePrompt = self._mainFrame:WaitForChild("PurchasePrompt")
	self._settingsFrame = self._mainFrame:WaitForChild("Settings")

	self._settingsListFrame = self._settingsFrame:WaitForChild("Frame"):WaitForChild("SettingsFrame")

	self._sliderEffectOffTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	self._sliderEffectOnTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	self._arrowEffectLeftTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	self._arrowEffectRightTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	self._purchasePromptCloseTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0)
	self._purchasePromptOpenTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

	self.Cabana = nil
	self._settings = {}
	self.cabanaPurchased = false

	_connectHandlers(self)
	_initSettings(self)

	return self
end

--Hides UI
function UIManager:Hide()
	self._mainFrame.Visible = false
	self._connectionManager:DisconnectAll()
end

--Shows UI

function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

--Clears UI and object values
function UIManager:Clear()
	self._settings = {}
	self.Cabana = nil
	self.cabanaPurchased = false
end

--[[ Private functions ]]--

function _connectHandlers(self)
	--Rental prompts
	local function closeRentalPrompt()
		local tween = TweenService:Create(self._purchasePrompt.UIScale, self._purchasePromptCloseTweenInfo, {Scale = 0})
		tween:Play()
		self._purchasePrompt.Visible = false
	end

	local function openRentalPrompt()
		self._purchasePrompt.Visible = true
		local tween = TweenService:Create(self._purchasePrompt.UIScale, self._purchasePromptOpenTweenInfo, {Scale = 1})
		tween:Play()
	end

	--Settings
	local function closeSettings()
		local tween = TweenService:Create(self._settingsFrame.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Scale = 0})
		tween:Play()
	end

	local function openSettings()
		local tween = TweenService:Create(self._settingsFrame.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Scale = 1})
		tween:Play()
	end

	--ProximityPrompt
	local function onProximityPromptTriggered(promptObject, player)
		if player ~= LocalPlayer then
			return
		end

		local cabana = promptObject.Parent.Parent

		if cabana.Name == "Cabana" then
			self:Show()
			self.Cabana = cabana

			if self.cabanaPurchased and cabana:GetAttribute("Owner") == player.Name then
				openSettings()
			elseif cabana:GetAttribute("Owner") ~= "" and cabana:GetAttribute("Owner") ~= player.Name then
				print("Someone else owns this cabana")
			else
				UIHelpers:SetupViewport(self._purchasePrompt.PreviewFrame.ViewportFrame, self.Cabana)
				openRentalPrompt()
			end
		end
	end

	--Purchase
	local function onProductPurchaseFinished(userID, productID, isPurchased)
		if userID == LocalPlayer.UserId and productID == ItemsData.Items[ItemType.Rental].DeveloperProductId then
			if isPurchased then
				self.cabanaPurchased = true
				if not self.Cabana then return end

				local roof = self.Cabana:FindFirstChild("Roof")
				if roof then
					local statusGui = roof:FindFirstChild("RentalStatusGui")
					if statusGui then
						local label = statusGui:WaitForChild("Frame"):WaitForChild("TextLabel")
						if label then
							label.Text = LocalPlayer.Name .. "'s Cabana"
						end
					end
				end

				local floor = self.Cabana:FindFirstChild("Floor")
				if floor then
					local proxPrompt = floor:FindFirstChildOfClass("ProximityPrompt")
					if proxPrompt then
						proxPrompt.ActionText = "Edit Cabana Settings"
					end
				end

				RemoteEvents.RentCabana:FireServer(self.Cabana)
			else
				warn("not purchased")
			end
		end
	end

	self._connectionManager:ConnectToEvent(self._settingsFrame.CloseButton.MouseButton1Click, closeSettings)
	self._connectionManager:ConnectToEvent(self._settingsFrame.SaveButton.MouseButton1Click, function()
		_saveSettings(self)
		closeSettings()
	end)

	self._connectionManager:ConnectToEvent(self._purchasePrompt.CloseButton.MouseButton1Click, closeRentalPrompt)
	self._connectionManager:ConnectToEvent(self._purchasePrompt.PurchaseButton.MouseButton1Click, function()
		MarketplaceService:PromptProductPurchase(LocalPlayer, ItemsData.Items[ItemType.Rental].DeveloperProductId, false, Enum.CurrencyType.Robux)
		closeRentalPrompt()
	end)
	self._connectionManager:ConnectToEvent(ProximityPromptService.PromptTriggered, onProximityPromptTriggered)
	self._connectionManager:ConnectToEvent(MarketplaceService.PromptProductPurchaseFinished, onProductPurchaseFinished)
end

function _createDropdownSetting(self, settingFrame: GuiObject)

end

function _createTextEntrySetting(self, settingFrame: GuiObject)

end

function _initSettings(self)
	for _, settingFrame in pairs(self._settingsListFrame:GetChildren()) do
		if settingFrame:GetAttribute("SettingName") == "AccentColor" then
			for _, item in pairs(settingFrame:GetChildren()) do
				if item:IsA("ImageLabel") then
					local textbox = item:FindFirstChildOfClass("TextBox")
					if textbox then
						textbox:GetPropertyChangedSignal("Text"):Connect(function()
							-- if textbox.Text ~= nil then
							-- 	local val = tonumber(textbox.Text)
							-- 	if val and typeof(val) ~= number then

							-- 	end
							-- end
						end)
					end
				end
			end
		end
	end
	-- for _, v in pairs(CabanaSettingsByName) do
	-- 	for __, setting in pairs(v) do
	-- 		print(setting["displayName"])
	-- 		-- if setting["displayName"].SettingType == SettingType.TextEntry then
	-- 		-- 	--local newSetting --= self._mainFrame.SettingsListFrame.SliderSetting:Clone()
	-- 		-- -- 		newSetting.Name = setting.displayName
	-- 		-- -- 		newSetting.SettingName.Text = setting.displayName
	-- 		-- -- 		newSetting.Visible = true
	-- 		-- -- 		newSetting.Parent = self._mainFrame.SettingsListFrame
	-- 		-- end
	-- 	end
	-- end
end

function _saveSettings(self)

end

return {
	new = new
}

