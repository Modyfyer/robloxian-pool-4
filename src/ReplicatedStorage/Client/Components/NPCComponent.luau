-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ChatService = game:GetService("Chat")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local INTERACTION_DURATION = 5

local NPCComponent = Component.new({
	Tag = "NPCComponent",
})

function NPCComponent:Construct()
	self._trove = Trove.new()
	self._interactionTrove = Trove.new()

	self._proximityPrompt = self.Instance:WaitForChild("ProximityPrompt")
	self._dialog = self.Instance:WaitForChild("Dialog")
	self._talkPart = self.Instance:WaitForChild("TalkPart")

	self._interactionCooldown = false
end

function NPCComponent:pickDialog(): string
	local dialogs = {}
	local dialogAttributes = self._dialog:GetAttributes()

	for _, v in pairs(dialogAttributes) do
		table.insert(dialogs, v)
	end

	return dialogs[math.random(1, #dialogs)]
end

function NPCComponent:Start()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	self._trove:Connect(self._proximityPrompt.Triggered, function()
		if self._interactionCooldown then
			return
		end

		local currentNPCPos = self.Instance.HumanoidRootPart.CFrame
		local newPos = Vector3.new(hrp.Position.X, currentNPCPos.Position.Y, hrp.Position.Z)
		local focusTween = TweenService:Create(
			self.Instance.HumanoidRootPart,
			TWEEN_INFO,
			{ CFrame = CFrame.new(currentNPCPos.Position, newPos) }
		)
		self._interactionTrove:Add(focusTween)

		Promise.resolve()
			:andThenCall(function()
				self._interactionCooldown = true
				self._proximityPrompt.Enabled = false
			end)
			:andThenCall(function()
				if not self.Instance:FindFirstChild("Walker") then
					focusTween:Play()
				end
			end)
			:andThenCall(ChatService.Chat, ChatService, self._talkPart, self:pickDialog())
			:andThenCall(Promise.delay, INTERACTION_DURATION)
			:finallyCall(function()
				if not self.Instance:FindFirstChild("Walker") then
					self.Instance.HumanoidRootPart.CFrame = currentNPCPos
				end
				self._proximityPrompt.Enabled = true
				self._interactionCooldown = false
				self._interactionTrove:Clean()
			end)
	end)
end

function NPCComponent:Stop()
	self._trove:Destroy()
end

return NPCComponent
