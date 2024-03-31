local ServerStorage = game:GetService("ServerStorage")
local FloatiesFolder = ServerStorage:FindFirstChild("Floaties")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerFloatyToggle = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("PlayerFloatyToggle")


--[[
	EMMA
	MAKE
	THIS
	READ
	OFF
	PLAYER
	DATA
	PLS TY
]]

game.Players.PlayerAdded:Connect(function(player)
	local FloatyTypeValue = Instance.new("StringValue")
	FloatyTypeValue.Name = "FloatyType"
	FloatyTypeValue.Value = "Default"
	FloatyTypeValue.Parent = player
end)

PlayerFloatyToggle.OnServerEvent:Connect(function(player, deployFloaty)
	if deployFloaty then
		local floatyTypeValue = player:FindFirstChild("FloatyType")
		if floatyTypeValue and floatyTypeValue:IsA("StringValue") then
			local floatyModelName = floatyTypeValue.Value
			local floatyModel = FloatiesFolder:FindFirstChild(floatyModelName)

			if floatyModel then
				local floatyClone = floatyModel:Clone()
				floatyClone.Name = "Floaty"
				floatyClone.Parent = player.Character
				floatyClone:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8))
			end
		end
	else
		local existingFloaty = player.Character:FindFirstChild("Floaty")
		if existingFloaty then
			existingFloaty:Destroy()
		end
	end
end)