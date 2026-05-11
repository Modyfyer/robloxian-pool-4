local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local OFFSET: number = 50

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local TooltipComponent = Component.new({
	Tag = "TooltipComponent",
})

function TooltipComponent:Construct()
	assert(self.Instance:IsA("GuiButton"), "TooltipComponent must be attached to a GuiButton")
	self._trove = Trove.new()
	self._tooltip = PlayerGui:WaitForChild("HUDGui"):WaitForChild("MainFrame"):WaitForChild("ButtonTooltip")
	self._extraOffsetX = self.Instance:GetAttribute("TooltipOffsetX") or 0
end

function TooltipComponent:ShowTooltip(x: number, y: number, text: string)
	self._tooltip.Position = UDim2.new(0, x + OFFSET + self._extraOffsetX, 0, y + OFFSET)
	self._tooltip.Visible = true
	self._tooltip.Tooltip.Text = text
end

function TooltipComponent:SetTooltipPosition(x: number, y: number)
	self._tooltip.Position = UDim2.new(0, x + self._extraOffsetX, 0, y)
end

function TooltipComponent:HideTooltip()
	self._tooltip.Position = UDim2.new(0.5, 0, 0.5, 0)
	self._tooltip.Tooltip.Text = ""
	self._tooltip.Visible = false
end

function TooltipComponent:Start()
	local text = self.Instance:GetAttribute("TooltipText") or self.Instance.Name

	self._trove:Connect(self.Instance.MouseEnter, function(x, y)
		self:ShowTooltip(x, y, text)
	end)
	self._trove:Connect(self.Instance.MouseMoved, function(x, y)
		self:SetTooltipPosition(x, y)
	end)
	self._trove:Connect(self.Instance.MouseLeave, function()
		self:HideTooltip()
	end)
end

function TooltipComponent:Stop()
	self._trove:Destroy()
end

return TooltipComponent
