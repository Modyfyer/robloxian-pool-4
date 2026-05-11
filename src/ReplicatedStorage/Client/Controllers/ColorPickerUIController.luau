-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local showTweenInfo: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local hideTweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local PlayerService

local ColorPickerUIController = Knit.CreateController({
	Name = "ColorPickerUIController",
})
ColorPickerUIController._trove = Trove.new()

function ColorPickerUIController:Hide()
	if not self._frame.Visible then
		return
	end
	if self._hideTrove then
		self._hideTrove:Destroy()
	end
	self._hideTrove = self._trove:Extend()

	local tween = TweenService:Create(self._uiScale, hideTweenInfo, { Scale = 0 })
	self._hideTrove:Add(tween)
	self._hideTrove:Connect(tween.Completed, function()
		self._frame.Visible = false
		self._hideTrove:Remove(tween)
	end)
	tween:Play()
end

function ColorPickerUIController:Show()
	if self._showTrove then
		self._showTrove:Destroy()
	end
	self._showTrove = self._trove:Extend()

	self._uiScale.Scale = 0
	self._frame.Visible = true

	local tween = TweenService:Create(self._uiScale, showTweenInfo, { Scale = 1 })
	self._showTrove:Add(tween)
	self._showTrove:Connect(tween.Completed, function()
		self._showTrove:Remove(tween)
	end)
	tween:Play()
end

function ColorPickerUIController:KnitStart()
	PlayerService = Knit.GetService("PlayerService")

	local function setColor(hue, sat, val)
		self._colorData = { hue or self._colorData[1], sat or self._colorData[2], val or self._colorData[3] }
		self._selectedColor = Color3.fromHSV(self._colorData[1], self._colorData[2], self._colorData[3])
		self._preview.BackgroundColor3 = self._selectedColor
	end

	local function inBounds(frame, x, y)
		local fx, fy = x - frame.AbsolutePosition.X, y - frame.AbsolutePosition.Y
		local maxX, maxY = frame.AbsoluteSize.X, frame.AbsoluteSize.Y
		if fx >= 0 and fy >= 0 and fx <= maxX and fy <= maxY then
			return fx / maxX, fy / maxY
		end
		return nil
	end

	local function updateRGB(input)
		if self._frame.Visible and self._mouse1Down then
			local x, y = inBounds(self._rgb, input.Position.X, input.Position.Y)
			if x and y then
				self._rgb:WaitForChild("Marker").Position = UDim2.fromScale(x, y)
				setColor(1 - x, 1 - y)
			end
		end
	end

	self._trove:Connect(UserInputService.InputChanged, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			updateRGB(input)
		end
	end)

	self._trove:Connect(UserInputService.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self._mouse1Down = true
		end
	end)

	self._trove:Connect(UserInputService.InputEnded, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self._frame.Visible then
				self._mouse1Down = false
				PlayerService:UpdateColor(self._selectedColor)
			end
		end
	end)

	self._trove:Connect(self._saveButton.Activated, function()
		self:Hide()
	end)
end

function ColorPickerUIController:KnitInit()
	local colorPickerGui = PlayerGui:WaitForChild("ColorPickerGui") :: ScreenGui

	self._frame = colorPickerGui:WaitForChild("Frame") :: Frame

	self._saveButton = self._frame:WaitForChild("SaveButton") :: GuiButton

	self._rgb = self._frame:WaitForChild("RGB") :: Frame
	self._preview = self._frame:WaitForChild("Preview") :: Frame

	self._uiScale = self._frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	self._uiScale.Parent = self._frame

	self._selectedColor = Color3.fromHSV(1, 1, 1)
	self._colorData = { 1, 1, 1 }
	self._mouse1Down = false
end

return ColorPickerUIController
