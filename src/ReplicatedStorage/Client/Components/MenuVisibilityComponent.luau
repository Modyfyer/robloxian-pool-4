-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local MENU_TWEEN_INFO: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local MenuVisibilityComponent = Component.new({
	Tag = "MenuVisibilityComponent",
})
MenuVisibilityComponent._debounce = false
MenuVisibilityComponent.MenuVisible = false
MenuVisibilityComponent.MenuClosed = Signal.new()

function MenuVisibilityComponent:Construct()
	self._trove = Trove.new()

	self._mainFrame = self.Instance:WaitForChild("MainFrame")

	self._closeButton = self._mainFrame:WaitForChild("CloseButton") :: GuiButton

	self._closeTween = TweenService:Create(self._mainFrame.UIScale, MENU_TWEEN_INFO, { Scale = 0 })
	self._openTween = TweenService:Create(self._mainFrame.UIScale, MENU_TWEEN_INFO, { Scale = 1 })
end

function MenuVisibilityComponent:ToggleVisibility()
	if self._debounce then
		return
	end

	self._debounce = true

	self.MenuVisible = not self.MenuVisible

	if self.MenuVisible then
		self._openTween:Play()
	else
		self._closeTween:Play()
	end

	task.wait(0.1)
	self._debounce = false
end

function MenuVisibilityComponent:Show()
	if self._debounce then
		return
	end

	self._debounce = true

	self.MenuVisible = true

	self._openTween:Play()

	task.wait(0.1)
	self._debounce = false
end

function MenuVisibilityComponent:Hide()
	if self._debounce then
		return
	end

	self._debounce = true

	self.MenuVisible = false

	self._closeTween:Play()

	task.wait(0.1)
	self._debounce = false
end

function MenuVisibilityComponent:Start()
	self._trove:Connect(self._closeButton.Activated, function()
		self:ToggleVisibility()
		self.MenuClosed:Fire()
	end)
end

function MenuVisibilityComponent:Stop()
	self._trove:Destroy()
end

return MenuVisibilityComponent
