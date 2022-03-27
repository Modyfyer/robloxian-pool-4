pl = game.Players
us = game:GetService("UserService")

for _, v in pairs(workspace.NPCSpots:GetChildren()) do
	if v:IsA("BasePart") then
		spawn(function()
			local id = v.UserId.Value
			local desc = pl:GetHumanoidDescriptionFromUserId(id)
			local inf = us:GetUserInfosByUserIdsAsync({ id })
			local md = pl:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			md.Parent = workspace.NPCs

			md.Name = inf[1].DisplayName .. " (@" .. inf[1].Username .. ")"
			local ani = game.ServerStorage.NPCStuff.Animate:Clone()
			local prmpt = game.ServerStorage.NPCStuff.ProximityPrompt:Clone()
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
			md.HumanoidRootPart.Anchored = true

			local talkPart = Instance.new("Part", md)
			talkPart.Transparency = 1
			talkPart.CanCollide = false
			talkPart.Name = "TalkPart"
			talkPart.Size = Vector3.new(1, 1, 1)

			local tpWeld = Instance.new("Weld", talkPart)
			tpWeld.Part0 = md.Head
			tpWeld.Part1 = talkPart
			tpWeld.C0 = CFrame.new(0, 1.5, 0)
		end)
	end
end