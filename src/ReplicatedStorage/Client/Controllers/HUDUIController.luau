-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local drownTweenInfo: TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local lifeguardButtonTweenInfo: TweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
local barTweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local OFFSET = 50
local DEFAULT_WALKSPEED: number = 16
local LIFEGUARD_GAMEPASS_ID = 703084245
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100

local MenuVisibilityComponent = require(ReplicatedStorage.Client.Components.MenuVisibilityComponent)

local ColorPickerUIController

local HUDUIController = Knit.CreateController({
	Name = "HUDUIController",
})
HUDUIController._trove = Trove.new()

function HUDUIController:_connectAnimationHandlers()
	--Character declarations
	-- local character = Knit.Player.Character
	-- local hrp = character:WaitForChild("HumanoidRootPart")
	-- local humanoid = character:WaitForChild("Humanoid")

	--local debounce: boolean = false

	--Animations--
	-- local function cannonballAnimation(anim: Animation, action: Enum.KeyCode)
	-- 	if not debounce then
	-- 		if humanoid.Sit == false then
	-- 			debounce = true
	-- 			local animTrack = humanoid:LoadAnimation(anim)
	-- 			local force = Instance.new("VectorForce")

	-- 			force.Parent = hrp
	-- 			force.Force = Vector3.new(0, 4500, -1200)
	-- 			force.ApplyAtCenterOfMass = true
	-- 			force.Attachment0 = hrp:FindFirstChildWhichIsA("Attachment")

	-- 			animTrack:Play()
	-- 			humanoid.Sit = true

	-- 			--actionUI.UIStroke.Enabled = true
	-- 			task.wait(.5)
	-- 			force:Destroy()
	-- 			task.wait(3)
	-- 			debounce = false

	-- 			--actionUI.UIStroke.Enabled = false
	-- 		end
	-- 	end
	-- end

	--Input handler--
	-- local function onInputBegan(input)
	-- 	if input.UserInputType ~= Enum.UserInputType.Keyboard then
	-- 		return
	-- 	end
	-- 	--local keycode: string = input.KeyCode.Name

	-- 	-- if not self.actionSelected then
	-- 	-- 	for _, action: Frame in pairs(actionKeys) do
	-- 	-- 		if action:GetAttribute("Keybind") == keycode then
	-- 	-- 			--Find the animation that matches the keybind
	-- 	-- 			for _, anim: Animation in pairs(self._actionsAnimations:GetChildren()) do
	-- 	-- 				local keybind: string? = anim:GetAttribute("Keybind")
	-- 	-- 				if keybind == keycode then
	-- 	-- 					if keybind == "X" then
	-- 	-- 						cannonballAnimation(anim, action)
	-- 	-- 					elseif keybind == "C" then
	-- 	-- 						diveAnimation(anim)
	-- 	-- 					end
	-- 	-- 				end
	-- 	-- 			end
	-- 	-- 		end
	-- 	-- 	end
	-- 	-- end
	-- end

	-- self._trove:Connect(UserInputService.InputBegan, function(input)
	-- 	onInputBegan(input)
	-- end)
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

	MenuVisibilityComponent:WaitForInstance(self._avatarMenu):andThen(function(myInstance)
		self._trove:Connect(self._avatarButton.Activated, function()
			myInstance:ToggleVisibility()
		end)
	end)

	MenuVisibilityComponent:WaitForInstance(self._emotesMenu):andThen(function(myInstance)
		self._trove:Connect(self._emotesButton.Activated, function()
			myInstance:ToggleVisibility()
		end)
	end)

	MenuVisibilityComponent:WaitForInstance(self._settingsMenu):andThen(function(myInstance)
		self._trove:Connect(self._settingsButton.Activated, function()
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
		self._trove:Connect(self._shopsButton.Activated, function()
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
		MarketplaceService:PromptGamePassPurchase(Knit.Player, LIFEGUARD_GAMEPASS_ID)
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

	self._actionsAnimations = self._actionsMenu:WaitForChild("Animations") :: Folder
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
