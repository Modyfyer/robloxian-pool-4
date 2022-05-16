bucketModel = workspace:WaitForChild("KiddiePlayground"):WaitForChild("FillBucket")
bucket = bucketModel:WaitForChild("Bucket")
water = bucketModel:WaitForChild("BucketWater")
particle = bucket:WaitForChild("Att"):WaitForChild("Particle")
sound = bucket:WaitForChild("Splash")

ts = game:GetService("TweenService")

eventTime = 15 * 60
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

function tipBucket()
	local bucketOrg = bucketModel:GetPrimaryPartCFrame()
	for i = 0, 112, 8 do
		wait()
		bucketModel:SetPrimaryPartCFrame(bucketOrg * CFrame.Angles(0, 0, math.rad(i)))
	end

	particle.Enabled = true
	sound:Play()
	wait(5)
	particle.Enabled = false

	for i = 112, 0, -8 do
		wait()
		bucketModel:SetPrimaryPartCFrame(bucketOrg * CFrame.Angles(0, 0, math.rad(i)))
	end
	bucketModel:SetPrimaryPartCFrame(bucketOrg)
end

while true do
	togglePipes(true)
	fillBucket:Play()
	task.wait(eventTime)
	togglePipes(false)
	tipBucket()
	water.Size = startSize
	water.CFrame = startPos
end