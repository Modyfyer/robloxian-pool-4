bucketModel = workspace:WaitForChild("KiddiePlayground"):WaitForChild("Bucket"):WaitForChild("FillBucket")
bucket = bucketModel:WaitForChild("Bucket")
bell = bucketModel.Parent:WaitForChild("Bell")
water = bucketModel:WaitForChild("BucketWater")
particle = bucket:WaitForChild("Att"):WaitForChild("Particle")
sound = bucket:WaitForChild("Splash")

ts = game:GetService("TweenService")

eventTime = 10 --15 * 60
startPos = bucket.CFrame - Vector3.new(0, 8.8, 0)
endPos = startPos + Vector3.new(0, 17, 0)
startSize = Vector3.new(14.6, .01, 14.6)

local tweenInfo = TweenInfo.new(
	eventTime, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

fillBucket = ts:Create(water, tweenInfo, {Size = Vector3.new(18.5, .01, 18.5), CFrame = endPos})

function togglePipes(toggle)
	for _, v in pairs(bucketModel.Parent:GetChildren()) do
		if v.Name == "Pipe" then
			v.Att.Particle.Enabled = toggle
		end
	end
end

function ringBell()
	local bellBlock = bell:WaitForChild("Bell")
	local bellSound = bellBlock:WaitForChild("BellSound")
	local orgPos = bell:GetPrimaryPartCFrame()

	bellSound:Play()

	for e = 1, 5 do
		for i = 0, 22.5, .5 do
			task.wait()
			bell:SetPrimaryPartCFrame(orgPos * CFrame.Angles(math.rad(i), 0, 0))
		end
	
		for i = 22.5, 0, -.5 do
			task.wait()
			bell:SetPrimaryPartCFrame(orgPos * CFrame.Angles(math.rad(i), 0, 0))
		end
	end

	bell:SetPrimaryPartCFrame(orgPos)
	bellSound:Stop()
end

function tipBucket()
	local bucketOrg = bucketModel:GetPrimaryPartCFrame()

	togglePipes(false)
	ringBell()

	for i = 0, 112, 8 do
		task.wait()
		bucketModel:SetPrimaryPartCFrame(bucketOrg * CFrame.Angles(0, 0, math.rad(i)))
	end

	particle.Enabled = true
	sound:Play()
	task.wait(5)
	particle.Enabled = false

	for i = 112, 0, -8 do
		task.wait()
		bucketModel:SetPrimaryPartCFrame(bucketOrg * CFrame.Angles(0, 0, math.rad(i)))
	end

	bucketModel:SetPrimaryPartCFrame(bucketOrg)
	togglePipes(true)
end

while true do
	fillBucket:Play()
	task.wait(eventTime)

	tipBucket()
	water.Size = startSize
	water.CFrame = startPos
end