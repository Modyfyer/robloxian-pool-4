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

--Constants
local SECONDS_IN_DAY: number = 86400

--Declarations
local LocalPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")
--local UIHelpers = require(LocalPlayer.PlayerScripts.UIHelpers)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._connectionManager = ConnectionManager.new()

	self._mainFrame = screenGui:WaitForChild("Mobile")

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
	self.cabanaRented = false
	self.cabanaClaimed = false

	if _isCabanaAlreadyRented() then
		self.cabanaRented = true
	end

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
	self.cabanaRented = false
	self.cabanaClaimed = false
end

--[[ Private functions ]]--

function _isCabanaAlreadyRented(): boolean
	local rentalTime: string? = RemoteFunctions.GetLastCabanaRentalTime:InvokeServer()
	if not rentalTime then --player has never rented a cabana
		return false
	end
	local rentalDT: DateTime? = DateTime.fromIsoDate(rentalTime)

	if rentalDT then
		local rentalTimestamp = rentalDT.UnixTimestamp
		local now = DateTime.now().UnixTimestamp
		if (now - rentalTimestamp) > SECONDS_IN_DAY then --it's been >24h since the rental pass was purchased
			return false
		else --the rental is still valid
			return true
		end
	else --no rental time could be parsed
		return false
	end
end

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
	local function onProximityPromptTriggered(promptObject: any, player: Player)
		if player ~= LocalPlayer then
			return
		end

		local cabana: Instance? = promptObject.Parent.Parent

		if cabana and cabana.Name == "Cabana" then
			if self.cabanaClaimed and cabana:GetAttribute("Owner") ~= player.Name then
				warn("Player has already rented a different cabana")
				return
			end

			self:Show()
			self.Cabana = cabana

			if (self.cabanaRented) and cabana:GetAttribute("Owner") == player.Name then
				openSettings()
			elseif (cabana:GetAttribute("Owner") == "") or (not cabana:GetAttribute("Owner")) then
				openRentalPrompt()
			else
				warn("Someone else owns this cabana")
				print(cabana:GetAttribute("Owner"))
			end
		end
	end


	--Sets the cabana model visually as rented
	local function setCabanaAsRented()
		if not self.Cabana then
			warn("Cannot set cabana as rented: no cabana found")
			return
		end

		local roof: BasePart = self.Cabana:WaitForChild("Roof") :: BasePart
		local statusGui: GuiObject = roof:WaitForChild("RentalStatusGui") :: GuiObject
		local label: GuiObject? = statusGui:WaitForChild("Frame"):WaitForChild("TextLabel")
		if label then
			label.Text = LocalPlayer.Name .. "'s Cabana"
		end

		local floor: BasePart = self.Cabana:WaitForChild("Floor") :: BasePart
		if floor then
			local proxPrompt: ProximityPrompt? = floor:FindFirstChildOfClass("ProximityPrompt")
			if proxPrompt then
				proxPrompt.ActionText = "Edit Cabana Settings"
			end
		end

		RemoteEvents.RentCabana:FireServer(self.Cabana)
		self.cabanaClaimed = true
	end

	--Purchase
	local function onProductPurchaseFinished(userID, productID, isPurchased)
		if userID == LocalPlayer.UserId and productID == ItemsData["CabanaRental"].DeveloperProductId then
			if isPurchased then
				self.cabanaRented = true
				setCabanaAsRented()
			else
				warn("Cabana was not purchased for", userID)
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
		if _isCabanaAlreadyRented() then
			self.cabanaRented = true
			setCabanaAsRented()
			openSettings()
		else
			MarketplaceService:PromptProductPurchase(LocalPlayer, ItemsData["CabanaRental"].DeveloperProductId, false, Enum.CurrencyType.Robux)
		end

		closeRentalPrompt()
	end)
	self._connectionManager:ConnectToEvent(ProximityPromptService.PromptTriggered, onProximityPromptTriggered)
	self._connectionManager:ConnectToEvent(MarketplaceService.PromptProductPurchaseFinished, onProductPurchaseFinished)
	self._connectionManager:ConnectToEvent(RemoteEvents.LoadCabanaSettings.OnClientEvent, function(settings: SharedSettings.cabanaSettings)
		_loadSettings(self, settings)
	end)
	self._connectionManager:ConnectToEvent(Players.PlayerRemoving, function(player: Player)
		if player ~= LocalPlayer then
			return
		end
		self:Clear()
	end)
end

function _initSettings(self, settings: SharedSettings.cabanaSettings)
end

function _loadSettings(self, settings: SharedSettings.cabanaSettings)
	self._settings = settings

	local function validateNumberEntry(text, lowerBound: number?, upperBound: number?): boolean
		if not text then
			return false
		end
		local val = tonumber(text)
		if not val then
			return false
		end

		if lowerBound and val < lowerBound then
			return false
		end

		if upperBound and val > upperBound then
			return false
		end

		return true
	end

	for _, settingFrame in ipairs(self._settingsListFrame:GetChildren()) do
		if settingFrame:IsA("Frame") then
			if settingFrame:GetAttribute("SettingName") == "StereoSongID" then
				local textboxFrame: ImageLabel = settingFrame:FindFirstChild("TextBoxFrame")
				if textboxFrame then
					local textbox: TextBox? = textboxFrame:FindFirstChild("TextBox")
					if textbox then
						textbox.Text = tostring(settings.currentSongID)
						textbox.FocusLost:Connect(function()
							local valid: boolean = validateNumberEntry(textbox.Text)
							if valid then
								self._settings.currentSongID = tonumber(textbox.Text)
							else
								textbox.PlaceholderText = "Value must be a number"
								textbox.Text = tostring(settings.currentSongID)
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
									local valid: boolean = validateNumberEntry(textbox.Text, 0, 255)
									if valid then
										self._settings.accentColors[color] = tonumber(textbox.Text)
									else
										textbox.PlaceholderText = "Value must be a number"
										textbox.Text = tostring(settings.accentColors[color])
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
					self._settings.allowedFriends = selectOptions[index]
				end)
				arrowR.MouseButton1Click:Connect(function()
					index += 1
					if index > length then
						index = 1
					end
					selected.Text = selectOptions[index]
					self._settings.allowedFriends = selectOptions[index]
				end)
			elseif settingFrame:GetAttribute("SettingName") == "TVChannel" then
				local arrowL: ImageButton = settingFrame:WaitForChild("ArrowL") :: ImageButton
				local arrowR: ImageButton = settingFrame:WaitForChild("ArrowR") :: ImageButton
				local selected: TextLabel = settingFrame:WaitForChild("Selected") :: TextLabel
				local selectOptions: {string} = SharedSettings.Channels
				local index = 1
				local length = #selectOptions

				arrowL.MouseButton1Click:Connect(function()
					index -= 1
					if index < 1 or index > length then
						index = length
					end
					selected.Text = selectOptions[index]
					self._settings.tvChannel = selectOptions[index]
				end)
				arrowR.MouseButton1Click:Connect(function()
					index += 1
					if index > length then
						index = 1
					end
					selected.Text = selectOptions[index]
					self._settings.tvChannel = selectOptions[index]
				end)
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

