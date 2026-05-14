-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

-- Constants
local TAB_SELECTED_STROKE_COLOR: Color3 = Color3.fromRGB(136, 190, 235)
local TAB_STROKE_COLOR: Color3 = Color3.fromRGB(5, 58, 102)
local TAB_TWEEN_INFO: TweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true)
local TAB_TWEEN_SIZE: number = 0.05

local TabsComponent = Component.new({
	Tag = "TabsComponent",
	Ancestors = { PlayerGui },
})

function TabsComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("GuiObject") then
		warn("TabsComponent is not a GuiObject")
		return
	end

	self.SelectedTab = self.Instance:GetAttribute("DefaultTab") :: string?
end

function TabsComponent:SetTab(tabToSet: string)
	if self.SelectedTab == tabToSet then
		return
	end

	for _, tab: GuiButton in pairs(self.Instance:GetChildren()) do
		local tabUIStroke = tab:FindFirstChildOfClass("UIStroke")
		if tab:GetAttribute("TabName") == tabToSet then
			self.SelectedTab = tabToSet
			local originalSize: UDim2 = tab.Size

			if tabUIStroke then
				tabUIStroke.Color = TAB_SELECTED_STROKE_COLOR
			end

			local openTween = TweenService:Create(
				tab,
				TAB_TWEEN_INFO,
				{ Size = UDim2.fromScale(originalSize.X.Scale - TAB_TWEEN_SIZE, originalSize.Y.Scale - TAB_TWEEN_SIZE) }
			)
			openTween.Completed:Once(function()
				openTween:Destroy()
				openTween = nil
			end)
			openTween:Play()
		elseif tabUIStroke then
			tabUIStroke.Color = TAB_STROKE_COLOR
		end
	end
end

function TabsComponent:Start()
	for _, tab in pairs(self.Instance:GetChildren()) do
		if not tab:IsA("GuiButton") then
			continue
		end
		if tab:GetAttribute("TabName") == self.SelectedTab then
			local tabUIStroke = tab:FindFirstChildOfClass("UIStroke")
			if tabUIStroke then
				tabUIStroke.Color = TAB_SELECTED_STROKE_COLOR
			end
		end
		self._trove:Connect(tab.Activated, function()
			self:SetTab(tab.Name)
		end)
	end
end

function TabsComponent:Stop()
	self._trove:Destroy()
end

return TabsComponent
