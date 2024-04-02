local Tool = script.Parent

local player = game.Players.LocalPlayer
local character = player.Character

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerFloatyToggle = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlayerFloatyToggle")

local debounce = false

Tool.Activated:Connect(function()
	if not character then
		character = player.Character
	end
	if debounce == false and character then
		PlayerFloatyToggle:FireServer()
		debounce = true
		task.wait(5)
		debounce = false
	end
end)

