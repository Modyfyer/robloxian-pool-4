-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Modules
local ItemsData = require(ReplicatedStorage.Data.ItemsData)
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

-- Constants
local SECONDS_IN_DAY: number = 86400

-- local arrowTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local purchaseTweenInfoClose = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local purchaseTweenInfoOpen = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local settingsTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local CabanaService

local CabanaUIController = Knit.CreateController({
	Name = "CabanaUIController",
})
CabanaUIController._trove = Trove.new()

function CabanaUIController:_isCabanaAlreadyRented(): boolean
	local rentalTime: string? = CabanaService:GetLastCabanaRentalTime():await()
	if not rentalTime or typeof(rentalTime) ~= "string" then --player has never rented a cabana
		return false
	end

	local rentalDT: DateTime = DateTime.fromIsoDate(rentalTime)
	local rentalTimestamp: number = rentalDT.UnixTimestamp
	local now: number = DateTime.now().UnixTimestamp
	if (now - rentalTimestamp) > SECONDS_IN_DAY then --it's been >24h since the rental pass was purchased
		return false
	end
	return true
end

function CabanaUIController:_setCabanaAsRented()
	if not self.Cabana then
		warn("Cannot set cabana as rented: no cabana found")
		return
	end

	local roof: BasePart = self.Cabana:WaitForChild("Roof") :: BasePart
	local statusGui: GuiObject = roof:WaitForChild("RentalStatusGui") :: GuiObject
	local label: TextLabel = statusGui:WaitForChild("Frame"):WaitForChild("TextLabel") :: TextLabel
	label.Text = Knit.Player.Name .. "'s Cabana"

	local floor: BasePart = self.Cabana:WaitForChild("Floor") :: BasePart
	if floor then
		local proxPrompt: ProximityPrompt? = floor:FindFirstChildOfClass("ProximityPrompt")
		if proxPrompt then
			proxPrompt.ActionText = "Edit Cabana Settings"
		end
	end

	CabanaService:RequestCabanaRental(self.Cabana)
	self._cabanaClaimed = true
end

function CabanaUIController:_loadSettings(settings: SharedSettings.cabanaSettings)
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
		if not settingFrame:IsA("Frame") then
			continue
		end
		local settingName = settingFrame:GetAttribute("SettingName")

		if settingName == "StereoSongID" then
			local textboxFrame = settingFrame:FindFirstChild("TextBoxFrame") :: ImageLabel
			local textbox = textboxFrame:FindFirstChild("TextBox") :: TextBox
			textbox.Text = tostring(settings.currentSongID)
			self._trove:Connect(textbox.FocusLost, function()
				local valid: boolean = validateNumberEntry(textbox.Text)
				if valid then
					self._settings.currentSongID = tonumber(textbox.Text)
				else
					textbox.PlaceholderText = "Value must be a number"
					textbox.Text = tostring(settings.currentSongID)
				end
			end)
		elseif settingName == "AccentColor" then
			for _, v in pairs(settingFrame:GetChildren()) do
				if not v:IsA("ImageLabel") then
					continue
				end

				local textbox = v:FindFirstChild("TextBox") :: TextBox

				local color = v:GetAttribute("AccentColor")
				textbox.Text = tostring(settings.accentColors[color])

				self._trove:Connect(textbox.FocusLost, function()
					local valid: boolean = validateNumberEntry(textbox.Text, 0, 255)
					if valid then
						self._settings.accentColors[color] = tonumber(textbox.Text)
					else
						textbox.PlaceholderText = "Value must be a number"
						textbox.Text = tostring(settings.accentColors[color])
					end
				end)
			end
		elseif settingName == "AllowedEntry" then
			local arrowL: ImageButton = settingFrame:WaitForChild("ArrowL") :: ImageButton
			local arrowR: ImageButton = settingFrame:WaitForChild("ArrowR") :: ImageButton
			local selected: TextLabel = settingFrame:WaitForChild("Selected") :: TextLabel
			local selectOptions: { string } = SharedSettings.AllowedFriends
			local index = 1
			local length = #selectOptions

			self._trove:Connect(arrowL.Activated, function()
				index -= 1
				if index < 1 or index > length then
					index = length
				end
				selected.Text = selectOptions[index]
				self._settings.allowedFriends = selectOptions[index]
			end)
			self._trove:Connect(arrowR.Activated, function()
				index += 1
				if index > length then
					index = 1
				end
				selected.Text = selectOptions[index]
				self._settings.allowedFriends = selectOptions[index]
			end)
		elseif settingName == "TVChannel" then
			local arrowL: ImageButton = settingFrame:WaitForChild("ArrowL") :: ImageButton
			local arrowR: ImageButton = settingFrame:WaitForChild("ArrowR") :: ImageButton
			local selected: TextLabel = settingFrame:WaitForChild("Selected") :: TextLabel
			local selectOptions: { string } = SharedSettings.Channels
			local index = 1
			local length = #selectOptions

			self._trove:Connect(arrowL.Activated, function()
				index -= 1
				if index < 1 or index > length then
					index = length
				end
				selected.Text = selectOptions[index]
				self._settings.tvChannel = selectOptions[index]
			end)
			self._trove:Connect(arrowR.Activated, function()
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

function CabanaUIController:_saveSettings()
	local settings = SharedSettings.DefaultCabanaSettings
	if not self._settings then
		warn("Unable to save settings: settings not found")
		return
	end

	settings = self._settings
	CabanaService:SaveCabanaSettings(settings)
end

function CabanaUIController:KnitStart()
	CabanaService = Knit.GetService("CabanaService")

	local purchaseTweenClose = TweenService:Create(self._purchasePrompt.UIScale, purchaseTweenInfoClose, { Scale = 0 })
	local purchaseTweenOpen = TweenService:Create(self._purchasePrompt.UIScale, purchaseTweenInfoOpen, { Scale = 1 })
	local settingsTweenClose = TweenService:Create(self._settingsFrame.UIScale, settingsTweenInfo, { Scale = 0 })
	local settingsTweenOpen = TweenService:Create(self._settingsFrame.UIScale, settingsTweenInfo, { Scale = 1 })

	if self:_isCabanaAlreadyRented() then
		self._cabanaRented = true
	end
	local function closeRentalPrompt()
		purchaseTweenClose:Play()
		self._purchasePrompt.Visible = false
	end

	local function openRentalPrompt()
		self._purchasePrompt.Visible = true
		purchaseTweenOpen:Play()
	end

	local function closeSettings()
		settingsTweenClose:Play()
	end

	local function openSettings()
		settingsTweenOpen:Play()
	end

	local function onProximityPromptTriggered(promptObject: any, player: Player)
		if player ~= Knit.Player then
			return
		end

		local cabana: Instance? = promptObject.Parent.Parent

		if cabana and cabana.Name == "Cabana" then
			if self._cabanaClaimed and cabana:GetAttribute("Owner") ~= player.Name then
				warn("Player has already rented a different cabana")
				return
			end

			self._mainFrame.Visible = true
			self.Cabana = cabana

			if self._cabanaRented and cabana:GetAttribute("Owner") == player.Name then
				openSettings()
			elseif (cabana:GetAttribute("Owner") == "") or (not cabana:GetAttribute("Owner")) then
				openRentalPrompt()
			else
				warn(`Someone else owns this cabana: {cabana:GetAttribute("Owner")}`)
			end
		end
	end

	local function onProductPurchaseFinished(userID, productID, isPurchased)
		if not (userID == Knit.Player.UserId) then
			return
		end
		local devProduct = ItemsData:GetDevProductByName("CabanaRental24h")
		if not devProduct then
			warn(`No dev product for product ID {productID}`)
			return
		end
		if productID == devProduct.DeveloperProductId and isPurchased then
			self._cabanaRented = true
			self:_setCabanaAsRented()
		else
			warn("Cabana was not purchased for", userID)
		end
	end

	self._trove:Connect(self._settingsFrame.CloseButton.Activated, closeSettings)
	self._trove:Connect(self._settingsFrame.SaveButton.Activated, function()
		self:_saveSettings()
		closeSettings()
	end)

	self._trove:Connect(self._purchasePrompt.CloseButton.Activated, closeRentalPrompt)
	self._trove:Connect(self._purchasePrompt.PurchaseButton.Activated, function()
		if self._cabanaRented or self:_isCabanaAlreadyRented() then
			self._cabanaRented = true
			self:_setCabanaAsRented()
			openSettings()
			return
		end
		local devProduct = ItemsData:GetDevProductByName("CabanaRental24h")
		if not devProduct then
			warn(`No dev product for CabanaRental24h`)
			return
		end
		MarketplaceService:PromptProductPurchase(
			Knit.Player,
			devProduct.DeveloperProductId,
			false,
			Enum.CurrencyType.Robux
		)

		closeRentalPrompt()
	end)
	self._trove:Connect(ProximityPromptService.PromptTriggered, onProximityPromptTriggered)
	self._trove:Connect(MarketplaceService.PromptProductPurchaseFinished, onProductPurchaseFinished)
	CabanaService.UpdatedCabanaSettings:Connect(function(settings)
		self:_loadSettings(settings)
	end)
end

function CabanaUIController:KnitInit()
	self._screenGui = PlayerGui:WaitForChild("CabanaGui") :: ScreenGui

	self._mainFrame = self._screenGui:WaitForChild("MainFrame") :: Frame

	self._purchasePrompt = self._mainFrame:WaitForChild("PurchasePrompt") :: ImageLabel
	self._settingsFrame = self._mainFrame:WaitForChild("Settings") :: ImageLabel

	self._settingsListFrame = self._settingsFrame:WaitForChild("Frame"):WaitForChild("SettingsFrame") :: ScrollingFrame

	self.Cabana = nil :: Instance?
	self._settings = {}
	self._cabanaRented = false
	self._cabanaClaimed = false

	self._mainFrame.Visible = false
end

return CabanaUIController
