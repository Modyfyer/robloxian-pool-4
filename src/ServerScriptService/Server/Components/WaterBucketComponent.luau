local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local WaterBucketComponent = Component.new({
	Tag = "WaterBucketComponent",
})

function WaterBucketComponent:Construct()
	self._trove = Trove.new()

	self.bucket = self.Instance:WaitForChild("Bucket")
	self.bell = self.Instance.Parent:WaitForChild("Bell")
	self.water = self.Instance:WaitForChild("BucketWater")
	self.particle = self.bucket:WaitForChild("Att"):WaitForChild("Particle")
	self.sound = self.bucket:WaitForChild("Splash")

	self.eventTime = 15 * 60
	self.startPos = self.bucket.CFrame - Vector3.new(0, 8.8, 0)
	self.endPos = self.startPos + Vector3.new(0, 17, 0)
	self.startSize = Vector3.new(14.6, 0.01, 14.6)

	self.tweenInfo = TweenInfo.new(self.eventTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
end

function WaterBucketComponent:Start()
	self.fillBucket =
		TweenService:Create(self.water, self.tweenInfo, { Size = Vector3.new(18.5, 0.01, 18.5), CFrame = self.endPos })
	self._trove:Add(task.spawn(function()
		while task.wait(self.eventTime) do
			self:_playBucketAnimation()
		end
	end))
end

function WaterBucketComponent:Stop()
	self._trove:Destroy()
end

function WaterBucketComponent:_playBucketAnimation()
	self.fillBucket:Play()

	self:tipBucket()
	self.water.Size = self.startSize
	self.water.CFrame = self.startPos
end

function WaterBucketComponent:togglePipes(toggle)
	for _, v in pairs(self.Instance.Parent:GetChildren()) do
		if v.Name == "Pipe" then
			v.Att.Particle.Enabled = toggle
		end
	end
end

function WaterBucketComponent:ringBell()
	local bellBlock = self.bell:WaitForChild("Bell")
	local bellSound: Sound = bellBlock:WaitForChild("BellSound")
	local orgPos: CFrame = self.bell:GetPrimaryPartCFrame()

	bellSound:Play()

	for _ = 1, 5 do
		for i = 0, 22.5, 0.5 do
			task.wait()
			self.bell:SetPrimaryPartCFrame(orgPos * CFrame.Angles(math.rad(i), 0, 0))
		end

		for i = 22.5, 0, -0.5 do
			task.wait()
			self.bell:SetPrimaryPartCFrame(orgPos * CFrame.Angles(math.rad(i), 0, 0))
		end
	end

	self.bell:SetPrimaryPartCFrame(orgPos)
	bellSound:Stop()
end

function WaterBucketComponent:tipBucket()
	local bucketOrg: CFrame = self.Instance:GetPrimaryPartCFrame()

	self:togglePipes(false)
	self:ringBell()

	for i = 0, 112, 8 do
		task.wait()
		self.Instance:SetPrimaryPartCFrame(bucketOrg * CFrame.Angles(0, 0, math.rad(i)))
	end

	self.particle.Enabled = true
	self.sound:Play()
	task.wait(5)
	self.particle.Enabled = false

	for i = 112, 0, -8 do
		task.wait()
		self.Instance:SetPrimaryPartCFrame(bucketOrg * CFrame.Angles(0, 0, math.rad(i)))
	end

	self.Instance:SetPrimaryPartCFrame(bucketOrg)
	self:togglePipes(true)
end

return WaterBucketComponent
