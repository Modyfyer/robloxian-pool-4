local Tool = script.Parent

local player = game.Players.LocalPlayer
local character = player.Character

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerFloatyToggle = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlayerFloatyToggle")

local debounce = false

Tool.Activated:Connect(function()
	if debounce == false then
		if character:FindFirstChild("Floaty") then
			PlayerFloatyToggle:FireServer(false)
		else
			PlayerFloatyToggle:FireServer(true)
		end
		debounce = true
		task.wait(5)
		debounce = false
	end
end)

