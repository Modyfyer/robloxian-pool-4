local Players = game.Players
local ServerStorage = game:GetService("ServerStorage")
local UserService = game:GetService("UserService")

for _, v in pairs(workspace.NPCSpots:GetChildren()) do
	if v:IsA("BasePart") then
		local isWalker = false
		if v:FindFirstChild("Walker") then
			isWalker = true
		end

		local id = v.UserId.Value
		local inf = UserService:GetUserInfosByUserIdsAsync({ id })

		task.spawn(function()
			local desc = Players:GetHumanoidDescriptionFromUserId(id)
			local md = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			md.Parent = workspace.NPCs
			md.Humanoid.WalkSpeed = 8

			md.Name = inf[1].DisplayName .. " (@" .. inf[1].Username .. ")"
			local ani = ServerStorage.NPCStuff.Animate:Clone()
			local prmpt = ServerStorage.NPCStuff.ProximityPrompt:Clone()
			local dia = v.Dialog:Clone()

			for _, v in pairs(md.Animate:GetChildren()) do
				v.Parent = ani
			end

			md.Animate:Destroy()
			ani.Parent = md
			ani.Disabled = false
			prmpt.Parent = md
			dia.Parent = md
			md.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3.2, 0)
			task.wait(2)
			if isWalker == false then
				md.HumanoidRootPart.Anchored = true
			elseif isWalker == true then
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
	end
end