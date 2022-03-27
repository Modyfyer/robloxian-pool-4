wait(100)

lastWeather = 0 --[[0 = clear, 1 = overcast, 2 = rain]]
currentWeather = 0

clouds = workspace:WaitForChild("Terrain"):WaitForChild("Clouds")
ts = game:GetService("TweenService")
isRaining = game:GetService("ReplicatedStorage").IsRaining

local tweenInfo = TweenInfo.new(
	10, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

cloudsCover = ts:Create(clouds, tweenInfo, {Cover = .85})
cloudsNormal = ts:Create(clouds, tweenInfo, {Cover = .55})

cloudsDark = ts:Create(clouds, tweenInfo, {Color = Color3.new(85 / 255, 85 / 255, 85 / 255)})
cloudsLight = ts:Create(clouds, tweenInfo, {Color = Color3.new(1, 1, 1)})

function overCast()
	cloudsCover:Play()
	cloudsDark:Play()
	lastWeather = 1
end

function rainySky()
	overCast()
	wait(10)
	isRaining.Value = true
	lastWeather = 2
end

function normalSky()
	isRaining.Value = false
	cloudsNormal:Play()
	cloudsLight:Play()
	wait(120)
end

while wait(math.random(15, 25)) do
	math.randomseed(os.time())
	local randNum = math.random(-25, 500)

	if (randNum > 300) and (randNum < 450) then
		currentWeather = 1
	elseif (randNum > 450) then
		currentWeather = 2
	end

	if currentWeather ~= lastWeather then
		if currentWeather == 1 then
			overCast()
			wait(math.random(200, 400))
		elseif currentWeather == 2 then
			rainySky()
			wait(math.random(200, 400))
		end
		normalSky()
	end
end
