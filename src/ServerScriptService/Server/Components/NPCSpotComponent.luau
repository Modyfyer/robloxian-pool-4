local Players = game.Players
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local UserService = game:GetService("UserService")

local Component = require(ReplicatedStorage.Packages.Component)
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
end

function NPCSpotComponent:Start()
	local inf = UserService:GetUserInfosByUserIdsAsync({ self._userID })

	task.spawn(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(self._userID)
		local md = Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
		md.Parent = workspace.NPCs
		md.Humanoid.WalkSpeed = 8

		md.Name = inf[1].DisplayName .. " (@" .. inf[1].Username .. ")"
		local ani = ServerStorage.NPCStuff.Animate:Clone()
		local prmpt = ServerStorage.NPCStuff.ProximityPrompt:Clone()
		local dia = self.Instance.Dialog:Clone()

		for _, v in pairs(md.Animate:GetChildren()) do
			v.Parent = ani
		end

		md.Animate:Destroy()
		ani.Parent = md
		ani.Disabled = false
		prmpt.Parent = md
		dia.Parent = md
		md.HumanoidRootPart.CFrame = self.Instance.CFrame + Vector3.new(0, 3.2, 0)
		task.wait(2)
		if not self._isWalker then
			md.HumanoidRootPart.Anchored = true
		else
			local walkScript = ServerStorage.NPCStuff.Walk:Clone()
			walkScript.Parent = md
			walkScript.Disabled = false
			local walkVal = Instance.new("BoolValue")
			walkVal.Name = "Walker"
			walkVal.Parent = md
		end

		local talkPart = Instance.new("Part")
		talkPart.Transparency = 1
		talkPart.CanCollide = false
		talkPart.Name = "TalkPart"
		talkPart.Size = Vector3.new(1, 1, 1)
		talkPart.Parent = md

		local tpWeld = Instance.new("Weld")
		tpWeld.Part0 = md.Head
		tpWeld.Part1 = talkPart
		tpWeld.C0 = CFrame.new(0, 1.5, 0)
		tpWeld.Parent = talkPart
	end)
	task.wait(0.4)
end

function NPCSpotComponent:Stop()
	self._trove:Destroy()
end

return NPCSpotComponent
