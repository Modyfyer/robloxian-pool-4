-- Services
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local CONFIG = {
	minOrbitRadius = 1,
	maxOrbitRadius = 6,
	flyDistance = 8,
	flySpeed = 4,
	bobIntensity = 0.3,
	minWaitTime = 1,
	maxWaitTime = 3,
	texNames = { "A", "B", "C", "D" },
}

local BACKWARD_TWEEN_INFO =
	TweenInfo.new(CONFIG.flySpeed / CONFIG.flyDistance, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local FLY_TWEEN_INFO = TweenInfo.new(CONFIG.flySpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local FORWARD_TWEEN_INFO =
	TweenInfo.new(CONFIG.flySpeed / CONFIG.flyDistance, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local ButterflyComponent = Component.new({
	Tag = "ButterflyComponent",
})

function ButterflyComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Model") then
		warn("ButterflyComponent requires a Model instance")
		return
	end

	self._isRunning = false
end

function ButterflyComponent:Start()
	self._isRunning = true

	local plane = self.Instance:FindFirstChild("Plane")
	if not plane then
		warn("Butterfly model missing Plane part")
		return
	end

	-- Setup animation
	local animController = self.Instance:FindFirstChild("AnimationController")
	local animationPart = self.Instance:FindFirstChild("Animation")

	if animController and animationPart and animationPart:IsA("Animation") then
		local animTrack = animController:LoadAnimation(animationPart)
		self._trove:Add(animTrack)
		animTrack:Play()
	end

	-- Setup texture
	local texName = CONFIG.texNames[math.random(1, #CONFIG.texNames)]
	local texPart = self.Instance:FindFirstChild(texName)
	if texPart then
		texPart.Parent = plane
	end

	task.spawn(function()
		self:_flyLoop(plane)
	end)
end

function ButterflyComponent:_flyLoop(plane)
	while self._isRunning do
		Promise.resolve()
			:andThenCall(function()
				self:_turnAndFly(plane)
			end)
			:andThenCall(Promise.delay, math.random(CONFIG.minWaitTime, CONFIG.maxWaitTime))
			:andThenCall(function()
				self:_fly(plane, FORWARD_TWEEN_INFO, true)
			end)
			:andThenCall(Promise.delay, math.random(CONFIG.minWaitTime, CONFIG.maxWaitTime))
			:andThenCall(function()
				self:_fly(plane, BACKWARD_TWEEN_INFO, false)
			end)
			:andThenCall(Promise.delay, math.random(CONFIG.minWaitTime, CONFIG.maxWaitTime))
			:catch(function(err)
				if self._isRunning then
					warn("Butterfly flight error:", err)
				end
			end)
			:await()
	end
end

function ButterflyComponent:_turnAndFly(plane: BasePart)
	local direction = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
	local targetCFrame = CFrame.new(plane.Position) * CFrame.Angles(0, math.atan2(direction.X, direction.Z), 0)

	local tween = TweenService:Create(plane, FLY_TWEEN_INFO, { CFrame = targetCFrame })

	self._trove:Add(tween)
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
end

function ButterflyComponent:_fly(plane: BasePart, tweenInfo: TweenInfo, forward: boolean)
	local direction = (plane.CFrame.LookVector).Unit
	local bobUp = true

	for _ = 1, CONFIG.flyDistance do
		local targetCFrame = plane.CFrame
		if forward then
			targetCFrame += direction
		else
			targetCFrame -= direction
		end

		if bobUp then
			targetCFrame = targetCFrame + Vector3.new(0, CONFIG.bobIntensity, 0)
		else
			targetCFrame = targetCFrame - Vector3.new(0, CONFIG.bobIntensity, 0)
		end

		bobUp = not bobUp

		local tween = TweenService:Create(plane, tweenInfo, { CFrame = targetCFrame })

		self._trove:Add(tween)
		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
	end
end

function ButterflyComponent:Stop()
	self._isRunning = false
	self._trove:Destroy()
end

return ButterflyComponent
