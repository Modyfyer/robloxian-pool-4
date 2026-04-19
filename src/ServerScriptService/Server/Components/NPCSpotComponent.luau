-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local UserService = game:GetService("UserService")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local NPCSpotComponent = Component.new({
	Tag = "NPCSpotComponent",
})

function NPCSpotComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("BasePart") then
		warn("NPCSpotComponent is not a BasePart")
		return
	end

	self._isWalker = false

	if self.Instance:FindFirstChild("Walker") then
		self._isWalker = true
	end

	self._userID = self.Instance.UserId.Value

	self._userInfo = UserService:GetUserInfosByUserIdsAsync({ self._userID })

	if not self._userInfo[1] then
		warn(`NPCSpotComponent has no User Info for ID {self._userID}`)
		return
	end
end

function NPCSpotComponent:Start()
	Promise.resolve()
		:andThen(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(self._userID)
		end)
		:andThen(function(humanoidDesc)
			local playerModel = Players:CreateHumanoidModelFromDescriptionAsync(humanoidDesc, Enum.HumanoidRigType.R15)
			playerModel.Parent = workspace.NPCs
			playerModel.Humanoid.WalkSpeed = 8

			playerModel.Name = self._userInfo[1].DisplayName .. " (@" .. self._userInfo[1].Username .. ")"

			local ani = ServerStorage.NPCStuff.Animate:Clone()
			local prmpt = ServerStorage.NPCStuff.ProximityPrompt:Clone()
			local dia = self.Instance.Dialog:Clone()

			for _, v in pairs(playerModel.Animate:GetChildren()) do
				v.Parent = ani
			end

			playerModel.Animate:Destroy()
			ani.Parent = playerModel
			ani.Disabled = false
			prmpt.Parent = playerModel
			dia.Parent = playerModel
			playerModel.HumanoidRootPart.CFrame = self.Instance.CFrame + Vector3.new(0, 3.2, 0)

			playerModel:AddTag("NPCComponent")

			return playerModel
		end)
		:andThenCall(Promise.delay, 2)
		:andThen(function(playerModel)
			if not self._isWalker then
				playerModel.HumanoidRootPart.Anchored = true
			else
				local walkScript = ServerStorage.NPCStuff.Walk:Clone()
				walkScript.Parent = playerModel
				walkScript.Disabled = false
				local walkVal = Instance.new("BoolValue")
				walkVal.Name = "Walker"
				walkVal.Parent = playerModel
			end

			local talkPart = Instance.new("Part")
			talkPart.Transparency = 1
			talkPart.CanCollide = false
			talkPart.Name = "TalkPart"
			talkPart.Size = Vector3.new(1, 1, 1)
			talkPart.Parent = playerModel

			local tpWeld = Instance.new("Weld")
			tpWeld.Part0 = playerModel.Head
			tpWeld.Part1 = talkPart
			tpWeld.C0 = CFrame.new(0, 1.5, 0)
			tpWeld.Parent = talkPart

			self._trove:Add(playerModel)
		end)
end

function NPCSpotComponent:Stop()
	self._trove:Destroy()
end

return NPCSpotComponent
