task.wait(100)

local lastWeather = 0 --[[0 = clear, 1 = overcast, 2 = rain]]
local currentWeather = 0

local clouds = workspace:WaitForChild("Terrain"):WaitForChild("Clouds")
local ts = game:GetService("TweenService")
local isRaining = game:GetService("ReplicatedStorage").IsRaining

local tweenInfo = TweenInfo.new(
	10, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

local cloudsCover = ts:Create(clouds, tweenInfo, {Cover = .85})
local cloudsNormal = ts:Create(clouds, tweenInfo, {Cover = .55})

local cloudsDark = ts:Create(clouds, tweenInfo, {Color = Color3.new(85 / 255, 85 / 255, 85 / 255)})
local cloudsLight = ts:Create(clouds, tweenInfo, {Color = Color3.new(1, 1, 1)})

function overCast()
	cloudsCover:Play()
	cloudsDark:Play()
	lastWeather = 1
end

function rainySky()
	overCast()
	task.wait(10)
	isRaining.Value = true
	lastWeather = 2
end

function normalSky()
	isRaining.Value = false
	cloudsNormal:Play()
	cloudsLight:Play()
	task.wait(120)
end

while task.wait(math.random(15, 25)) do
	math.randomseed(os.time())
	local randNum = math.random(-25, 500)

	if (randNum > 300) and (randNum < 450) then
		currentWeather = 1
	elseif randNum > 450 then
		currentWeather = 2
	end

	if currentWeather ~= lastWeather then
		if currentWeather == 1 then
			overCast()
			task.wait(math.random(200, 400))
		elseif currentWeather == 2 then
			rainySky()
			task.wait(math.random(200, 400))
		end
		normalSky()
	end
end
