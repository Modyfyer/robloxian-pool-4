local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local CurtainComponent = Component.new({
	Tag = "CurtainComponent",
})

function CurtainComponent:Construct()
	self._trove = Trove.new()
	self._curtains = {}
end

function CurtainComponent:_connectCurtain(curtain)
	local click = curtain:WaitForChild("Click")
	local sound = curtain:WaitForChild("Effect")

	local curtainData = {
		open = true,
		debounced = false,
		orgSize = curtain.Size,
		orgCFrame = curtain.CFrame,
	}

	self._curtains[curtain] = curtainData

	self._trove:Connect(click.MouseClick, function()
		if curtainData.debounced then
			return
		end

		Promise.resolve()
			:andThenCall(function()
				curtainData.debounced = true

				if curtainData.open then
					curtain.Size = curtainData.orgSize + Vector3.new(6, 0, 0)
					curtain.CFrame = curtainData.orgCFrame * CFrame.new(3, 0, 0)
					sound.PlaybackSpeed = 0.7
					curtainData.open = false
				else
					curtain.Size = curtainData.orgSize
					curtain.CFrame = curtainData.orgCFrame
					sound.PlaybackSpeed = 1
					curtainData.open = true
				end

				sound:Play()
			end)
			:andThenCall(Promise.delay, 2)
			:finallyCall(function()
				curtainData.debounced = false
			end)
	end)
end

function CurtainComponent:Start()
	for _, curtain in pairs(self.Instance:GetChildren()) do
		if curtain:IsA("BasePart") and curtain.Name == "Curtain" then
			self:_connectCurtain(curtain)
		end
	end
end

function CurtainComponent:Stop()
	self._trove:Destroy()
end

return CurtainComponent
