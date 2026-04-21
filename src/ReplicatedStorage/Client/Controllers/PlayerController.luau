-- Services
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Declarations
local cam = workspace.CurrentCamera
local blur: BlurEffect = Lighting:WaitForChild("RunBlur")
local running: boolean = false
local hum = nil

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local blurOn = TweenService:Create(blur, tweenInfo, { Size = 5 })
local blurOff = TweenService:Create(blur, tweenInfo, { Size = 0 })
local tweenOn = TweenService:Create(cam, tweenInfo, { FieldOfView = 90 })
local tweenOff = TweenService:Create(cam, tweenInfo, { FieldOfView = 70 })

local PlayerController = Knit.CreateController({
	Name = "PlayerController",
})

function PlayerController:KnitInit() end

function PlayerController:KnitStart()
	UserInputService.InputBegan:Connect(function(input)
		if running then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift and hum then
			blurOff:Pause()
			blurOn:Play()
			tweenOff:Pause()
			tweenOn:Play()
			hum.WalkSpeed = 45
			running = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not running then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift and hum then
			blurOn:Pause()
			blurOff:Play()
			tweenOn:Pause()
			tweenOff:Play()
			hum.WalkSpeed = 16
			running = false
		end
	end)

	Knit.Player.CharacterAdded:Connect(function(ch)
		hum = ch:WaitForChild("Humanoid")
	end)
end

return PlayerController
