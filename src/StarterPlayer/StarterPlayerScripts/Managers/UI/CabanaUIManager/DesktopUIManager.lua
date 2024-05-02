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
local ItemsData = require(ReplicatedStorage.Data.ItemsData)
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

--Declarations
local LocalPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
--local UIHelpers = require(LocalPlayer.PlayerScripts.UIHelpers)

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

	self._sliderEffectOffTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	self._sliderEffectOnTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	self._arrowEffectLeftTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	self._arrowEffectRightTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	self._purchasePromptCloseTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	self._purchasePromptOpenTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	self._settingsTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)

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
		local tween = TweenService:Create(self._settingsFrame.UIScale, self._settingsTweenInfo, {Scale = 0})
		tween:Play()
	end

	local function openSettings()
		local tween = TweenService:Create(self._settingsFrame.UIScale, self._settingsTweenInfo, {Scale = 1})
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
			elseif (cabana:GetAttribute("Owner") == "") or (not cabana:GetAttribute("Owner")) then
				openRentalPrompt()
			else
				print("Someone else owns this cabana")
			end
		end
	end

	--Purchase
	local function onProductPurchaseFinished(userID, productID, isPurchased)
		if userID == LocalPlayer.UserId and productID == ItemsData["CabanaRental"].DeveloperProductId then
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
		MarketplaceService:PromptProductPurchase(LocalPlayer, ItemsData["CabanaRental"].DeveloperProductId, false, Enum.CurrencyType.Robux)
		closeRentalPrompt()
	end)
	self._connectionManager:ConnectToEvent(ProximityPromptService.PromptTriggered, onProximityPromptTriggered)
	self._connectionManager:ConnectToEvent(MarketplaceService.PromptProductPurchaseFinished, onProductPurchaseFinished)
	self._connectionManager:ConnectToEvent(RemoteEvents.LoadCabanaSettings.OnClientEvent, function(settings: SharedSettings.cabanaSettings)
		_loadSettings(self, settings)
	end)
end

function _initSettings(self, settings: SharedSettings.cabanaSettings)
	-- for _, settingFrame in ipairs(self._settingsListFrame:GetChildren()) do
	-- 	if settingFrame:GetAttribute("SettingName") == "AccentColor" then
	-- 		-- for _, item in ipairs(settingFrame:GetChildren()) do
	-- 		-- 	if item:IsA("ImageLabel") then
	-- 		-- 		local textbox = item:FindFirstChildOfClass("TextBox")
	-- 		-- 		if textbox then
	-- 		-- 			textbox:GetPropertyChangedSignal("Text"):Connect(_verifyTextInput(textbox))
	-- 		-- 		end
	-- 		-- 	end
	-- 		-- end
	-- 	end
	-- end
end

function _loadSettings(self, settings: SharedSettings.cabanaSettings)
	self._settings = settings
	--print(settings)

	local function validateNumberEntry(text): boolean
		if not text then
			return false
		end
		local val = tonumber(text)
		if not val then
			return false
		end
		return true
	end

	for _, settingFrame in ipairs(self._settingsListFrame:GetChildren()) do
		if settingFrame:IsA("Frame") then
			if settingFrame:GetAttribute("SettingName") == "StereoSongID" then
				local textboxFrame = settingFrame:FindFirstChild("TextBoxFrame")
				if textboxFrame then
					local textbox: TextBox? = textboxFrame:FindFirstChild("TextBox")
					if textbox then
						textbox.Text = tostring(settings.currentSongID)
						textbox.FocusLost:Connect(function()
							local valid = validateNumberEntry(textbox.Text)
							if valid then
								self._settings.currentSongID = tonumber(textbox.Text)
							else
								textbox.PlaceholderText = "Value must be a number"
							end
						end)
					end
				end
			elseif settingFrame:GetAttribute("SettingName") == "AccentColor" then
				for _, v in pairs(settingFrame:GetChildren()) do
					if v:IsA("ImageLabel") then
						local textbox: TextBox? = v:FindFirstChild("TextBox")
						if textbox then
							local color = v:GetAttribute("AccentColor")
							if color then
								textbox.Text = tostring(settings.accentColors[color])

								textbox.FocusLost:Connect(function()
									local valid = validateNumberEntry(textbox.Text)
									if valid then
										self._settings.accentColors[color] = tonumber(textbox.Text)
									else
										textbox.PlaceholderText = "Value must be a number"
									end
								end)
							end
						end
					end
				end
			elseif settingFrame:GetAttribute("SettingName") == "AllowedEntry" then
				local arrowL: ImageButton = settingFrame:WaitForChild("ArrowL") :: ImageButton
				local arrowR: ImageButton = settingFrame:WaitForChild("ArrowR") :: ImageButton
				local selected: TextLabel = settingFrame:WaitForChild("Selected") :: TextLabel
				local selectOptions: {string} = SharedSettings.AllowedFriends
				local index = 1
				local length = #selectOptions
				arrowL.MouseButton1Click:Connect(function()
					index -= 1
					if index < 1 or index > length then
						index = length
					end
					selected.Text = selectOptions[index]
				end)
				arrowR.MouseButton1Click:Connect(function()
					index += 1
					if index < 1 or index > length then
						index = length
					end
					selected.Text = selectOptions[index]
				end)
			elseif settingFrame:GetAttribute("SettingName") == "TVChannel" then
				print(3)
			end
		end
	end
end

function _saveSettings(self)
	local settings: SharedSettings.cabanaSettings = SharedSettings.DefaultSettings
	if self._settings ~= nil then
		settings = self._settings
	end
	RemoteEvents.SaveCabanaSettings:FireServer(settings)
end

return {
	new = new
}

