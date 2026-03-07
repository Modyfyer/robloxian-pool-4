--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DivingBoardComponent = Component.new({
	Tag = "DivingBoardComponent",
})

function DivingBoardComponent:Construct()
	self._trove = Trove.new()
	self._boardModel = self.Instance:WaitForChild("Board") :: Model
	self._board = self._boardModel:WaitForChild("Board")
	self._debounce = false
end

function DivingBoardComponent:Start()
	local sound = self._board:WaitForChild("Sound")
	local touch = self.Instance:WaitForChild("TouchDetector")

	local anim = self._boardModel:WaitForChild("Anim")
	local animControl = self._boardModel:WaitForChild("AnimationController")
	local animator = animControl:WaitForChild("Animator")

	local loadedAnim = animator:LoadAnimation(anim)

	self._trove:Connect(touch.Touched, function(part)
		if self._debounce then
			return
		end

		if Players:GetPlayerFromCharacter(part.Parent) then
			local player = Players:GetPlayerFromCharacter(part.Parent)
			local char = player.Character
			local hum = char:WaitForChild("Humanoid")
			local state = hum:GetState()

			if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
				Promise.resolve()
					:andThenCall(function()
						self._debounce = true
					end)
					:andThenCall(loadedAnim.Play, loadedAnim)
					:andThenCall(sound.Play, sound)
					:andThenCall(Promise.delay, 1.5)
					:finallyCall(function()
						self._debounce = false
					end)
			end
		end
	end)
end

function DivingBoardComponent:Stop()
	self._trove:Destroy()
end

return DivingBoardComponent
