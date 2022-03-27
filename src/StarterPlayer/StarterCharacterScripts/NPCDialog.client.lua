player = game.Players.LocalPlayer

if not player.Character then 
	player.CharacterAdded:Wait()
end

char = player.Character
hum = char:WaitForChild("Humanoid")
hrp = char:WaitForChild("HumanoidRootPart")
ts = game:GetService("TweenService")

wait(5) -- waiting for server to populate NPCs

local tweenInfo = TweenInfo.new(
	.5, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)


function pickDialog(npc)
	local dialogs = {}
	local dia = npc.Dialog:GetAttributes()

	for _, v in pairs(dia) do
		table.insert(dialogs, v)
	end

	return dialogs[math.random(1, #dialogs)]
end

interactionCoolDown = false

function interactWith(npc)
	if interactionCoolDown == false then
		interactionCoolDown = true
		local currentNPCPos = npc.HumanoidRootPart.CFrame
		local newPos = Vector3.new(hrp.Position.X, currentNPCPos.Position.Y, hrp.Position.Z)
		local focus = ts:Create(npc.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(currentNPCPos.Position, newPos)})
		npc.ProximityPrompt.Enabled = false
		focus:Play()
		game:GetService("Chat"):Chat(npc.TalkPart, pickDialog(npc))
		wait(5)
		interactionCoolDown = false
		npc.HumanoidRootPart.CFrame = currentNPCPos
		npc.ProximityPrompt.Enabled = true
	end	
end


for _, v in pairs(workspace.NPCs:GetChildren()) do
	v.ProximityPrompt.Triggered:connect(function()
		interactWith(v)
	end)
end