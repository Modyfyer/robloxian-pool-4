-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Data
local ItemsData = require(ReplicatedStorage.Data.ItemsData)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local drownTweenInfo: TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local lifeguardButtonTweenInfo: TweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
local barTweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local actionsMenuTweenInfo: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local OFFSET: number = 50
local DEFAULT_WALKSPEED: number = 16
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100

local MenuVisibilityComponent = require(ReplicatedStorage.Client.Components.MenuVisibilityComponent)

local ColorPickerUIController

local HUDUIController = Knit.CreateController({
	Name = "HUDUIController",
})
HUDUIController._trove = Trove.new()

function HUDUIController:SetActionFrameSelection(keycode: string, highlighted: boolean)
	local actionFrames = self._actionsFrame:GetChildren()
	for _, actionFrame in actionFrames do
		if not actionFrame:IsA("Frame") then
			continue
		end
		if actionFrame:GetAttribute("Keybind") == keycode then
			actionFrame.UIStroke.Enabled = highlighted
		end
	end
end

function HUDUIController:KnitStart()
	ColorPickerUIController = Knit.GetController("ColorPickerUIController")

	local function showTooltip(x: number, y: number, text: string)
		self._tooltip.Position = UDim2.new(0, x + OFFSET, 0, y + OFFSET)
		self._tooltip.Visible = true
		self._tooltip.Tooltip.Text = text
	end

	local function setTooltipPosition(x: number, y: number)
		self._tooltip.Position = UDim2.new(0, x, 0, y)
	end

	local function hideTooltip()
		self._tooltip.Position = UDim2.new(0.5, 0, 0.5, 0)
		self._tooltip.Tooltip.Text = ""
		self._tooltip.Visible = false
	end

	local function hideAllMenusExcept(myInstance)
		for _, v in self._menuInstances do
			if v ~= myInstance then
				v:Hide()
			end
		end
	end

	self._menuInstances = {}

	MenuVisibilityComponent:WaitForInstance(self._avatarMenu):andThen(function(myInstance)
		table.insert(self._menuInstances, myInstance)
		self._trove:Connect(self._avatarButton.Activated, function()
			hideAllMenusExcept(myInstance)
			myInstance:ToggleVisibility()
		end)
	end)

	MenuVisibilityComponent:WaitForInstance(self._emotesMenu):andThen(function(myInstance)
		table.insert(self._menuInstances, myInstance)
		self._trove:Connect(self._emotesButton.Activated, function()
			hideAllMenusExcept(myInstance)
			myInstance:ToggleVisibility()
		end)
	end)

	MenuVisibilityComponent:WaitForInstance(self._settingsMenu):andThen(function(myInstance)
		table.insert(self._menuInstances, myInstance)
		self._trove:Connect(self._settingsButton.Activated, function()
			hideAllMenusExcept(myInstance)
			myInstance:ToggleVisibility()
			if not myInstance.MenuVisible then
				ColorPickerUIController:Hide()
			end
		end)
		self._trove:Connect(myInstance.MenuClosed, function()
			ColorPickerUIController:Hide()
		end)
	end)

	MenuVisibilityComponent:WaitForInstance(self._shopsMenu):andThen(function(myInstance)
		table.insert(self._menuInstances, myInstance)
		self._trove:Connect(self._shopsButton.Activated, function()
			hideAllMenusExcept(myInstance)
			myInstance:ToggleVisibility()
		end)
	end)

	self._trove:Connect(self._avatarButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Avatar")
	end)
	self._trove:Connect(self._avatarButton.MouseMoved, setTooltipPosition)
	self._trove:Connect(self._avatarButton.MouseLeave, hideTooltip)

	self._trove:Connect(self._emotesButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Emotes")
	end)
	self._trove:Connect(self._emotesButton.MouseMoved, setTooltipPosition)
	self._trove:Connect(self._emotesButton.MouseLeave, hideTooltip)

	self._trove:Connect(self._lifeguardButton.Activated, function()
		MarketplaceService:PromptGamePassPurchase(Knit.Player, ItemsData.LifeguardGamepassID)
	end)
	self._lifeguardSpinTween:Play()

	self._trove:Connect(self._settingsButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Settings")
	end)
	self._trove:Connect(self._settingsButton.MouseMoved, setTooltipPosition)
	self._trove:Connect(self._settingsButton.MouseLeave, hideTooltip)

	self._trove:Connect(self._shopsButton.MouseEnter, function(x, y)
		showTooltip(x, y, "Shops")
	end)
	self._trove:Connect(self._shopsButton.MouseMoved, setTooltipPosition)
	self._trove:Connect(self._shopsButton.MouseLeave, hideTooltip)

	local startPosition = UDim2.fromScale(-1, self._actionsMainFrame.Position.Y.Scale)
	local actionsMenuTweenOpen = TweenService:Create(
		self._actionsMainFrame,
		actionsMenuTweenInfo,
		{ Position = UDim2.fromScale(self._actionsMainFrame.Position.X.Scale, self._actionsMainFrame.Position.Y.Scale) }
	)
	local actionsMenuTweenClose = TweenService:Create(
		self._actionsMainFrame,
		actionsMenuTweenInfo,
		{ Position = UDim2.fromScale(-1, self._actionsMainFrame.Position.Y.Scale) }
	)
	self._actionsMainFrame.Position = startPosition

	self._trove:Connect(self._actionsOpenButton.Activated, function()
		self._actionsMainFrame.Visible = true
		self._actionsOpenButton.Visible = false
		actionsMenuTweenOpen:Play()
	end)
	self._trove:Connect(self._actionsCloseButton.Activated, function()
		actionsMenuTweenClose:Play()
		actionsMenuTweenClose.Completed:Wait()
		self._actionsMainFrame.Visible = false
		self._actionsOpenButton.Visible = true
	end)

	local function onOxygenValueChanged()
		self._oxygenVal = Knit.Player:GetAttribute("Oxygen")

		local scaled: number = math.clamp((self._oxygenVal / MAX_OXYGEN), 0, 1)
		local tween = TweenService:Create(self._oxygenBar, barTweenInfo, { Size = UDim2.fromScale(scaled, 1) })

		Promise.resolve()
			:andThenCall(tween.Play, tween)
			:andThenCall(Promise.fromEvent, tween.Completed)
			:finallyCall(function()
				tween:Destroy()
			end)

		if self._oxygenVal <= 0 then
			local character = Knit.Player.Character
			if not character then
				return
			end

			local humanoid = character:WaitForChild("Humanoid")
			if not humanoid then
				return
			end
			Promise.resolve()
				:andThenCall(function()
					self._drownFrame.Visible = true
				end)
				:andThenCall(self._drownAnimA.Play, self._drownAnimA)
				:andThenCall(function()
					humanoid.WalkSpeed = 0
				end)
				:andThenCall(Promise.delay, 4)
				:andThenCall(self._drownAnimB.Play, self._drownAnimB)
				:andThenCall(Promise.delay, 3)
				:finallyCall(function()
					self._drownFrame.Visible = false
					humanoid.WalkSpeed = DEFAULT_WALKSPEED
				end)
		end
	end

	local function onWaterValueChanged()
		self._waterVal = Knit.Player:GetAttribute("Water")

		local scaled: number = math.clamp((self._waterVal / MAX_WATER), 0, 1)
		local tween = TweenService:Create(self._waterBar, barTweenInfo, { Size = UDim2.fromScale(scaled, 1) })

		Promise.resolve()
			:andThenCall(tween.Play, tween)
			:andThenCall(Promise.fromEvent, tween.Completed)
			:finallyCall(function()
				tween:Destroy()
			end)
	end

	self._trove:Connect(Knit.Player:GetAttributeChangedSignal("Oxygen"), onOxygenValueChanged)
	self._trove:Connect(Knit.Player:GetAttributeChangedSignal("Water"), onWaterValueChanged)
end

function HUDUIController:KnitInit()
	self._screenGui = PlayerGui:WaitForChild("HUDGui") :: ScreenGui

	self._avatarMenu = PlayerGui:WaitForChild("AvatarGui") :: ScreenGui
	self._emotesMenu = PlayerGui:WaitForChild("EmotesGui") :: ScreenGui
	self._shopsMenu = PlayerGui:WaitForChild("ShopsGui") :: ScreenGui
	self._settingsMenu = PlayerGui:WaitForChild("SettingsGui") :: ScreenGui

	self._mainFrame = self._screenGui:WaitForChild("MainFrame") :: Frame

	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft") :: Frame
	self._sidebarRight = self._mainFrame:WaitForChild("SidebarRight") :: Frame

	self._actionsMenu = self._mainFrame:WaitForChild("ActionsMenu") :: Frame
	self._drownFrame = self._mainFrame:WaitForChild("DrownAnim") :: Frame
	self._progressBars = self._mainFrame:WaitForChild("ProgressBars") :: Frame
	self._tooltip = self._mainFrame:WaitForChild("ButtonTooltip") :: Frame

	self._actionsMainFrame = self._actionsMenu:WaitForChild("MainFrame") :: ImageLabel
	self._actionsOpenButton = self._actionsMenu:WaitForChild("ButtonOpen") :: ImageButton

	self._actionsFrame = self._actionsMainFrame:WaitForChild("Actions") :: Frame
	self._actionsCloseButton = self._actionsMainFrame:WaitForChild("ButtonClose") :: ImageButton

	self._oxygenBar =
		self._progressBars:WaitForChild("OxygenMeter"):WaitForChild("BG"):WaitForChild("Amount") :: ImageLabel
	self._oxygenVal = Knit.Player:GetAttribute("Oxygen")

	self._waterBar =
		self._progressBars:WaitForChild("WaterMeter"):WaitForChild("BG"):WaitForChild("Amount") :: ImageLabel
	self._waterVal = Knit.Player:GetAttribute("Water")
	self._drownAnimA = TweenService:Create(self._drownFrame, drownTweenInfo, { BackgroundTransparency = 0 }) :: Tween
	self._drownAnimB = TweenService:Create(self._drownFrame, drownTweenInfo, { BackgroundTransparency = 1 }) :: Tween

	self._avatarButton = self._sidebarLeft:WaitForChild("AvatarButton"):WaitForChild("Button") :: GuiButton
	self._emotesButton = self._sidebarLeft:WaitForChild("EmotesButton"):WaitForChild("Button") :: GuiButton
	self._lifeguardButton = self._sidebarRight:WaitForChild("LifeguardButton"):WaitForChild("Button") :: GuiButton
	self._settingsButton = self._sidebarLeft:WaitForChild("SettingsButton"):WaitForChild("Button") :: GuiButton
	self._shopsButton = self._sidebarLeft:WaitForChild("ShopsButton"):WaitForChild("Button") :: GuiButton
	self._lifeguardSpinTween =
		TweenService:Create(self._lifeguardButton, lifeguardButtonTweenInfo, { Rotation = 360 }) :: Tween
end

return HUDUIController
