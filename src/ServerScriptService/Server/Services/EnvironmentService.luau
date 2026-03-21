-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Declarations
local EnvironmentService = Knit.CreateService({
	Name = "EnvironmentService",
	Client = {
		WeatherChanged = Knit.CreateSignal(),
	},
	WeatherChanged = Signal.new(),
})

-- Weather Constants
local WEATHER_STATES = {
	CLEAR = 0,
	OVERCAST = 1,
	RAIN = 2,
}

-- Private Variables
local currentWeather = WEATHER_STATES.CLEAR
local lastWeather = WEATHER_STATES.CLEAR
local clouds = nil
local isRaining = nil
local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local cloudsTweens = {}

----- Private Functions -----
function EnvironmentService:_initializeTweens()
	cloudsTweens.cover = TweenService:Create(clouds, tweenInfo, { Cover = 0.85 })
	cloudsTweens.normal = TweenService:Create(clouds, tweenInfo, { Cover = 0.55 })
	cloudsTweens.dark = TweenService:Create(clouds, tweenInfo, { Color = Color3.new(85 / 255, 85 / 255, 85 / 255) })
	cloudsTweens.light = TweenService:Create(clouds, tweenInfo, { Color = Color3.new(1, 1, 1) })
end

function EnvironmentService:_setOvercast()
	cloudsTweens.cover:Play()
	cloudsTweens.dark:Play()
	lastWeather = WEATHER_STATES.OVERCAST
end

function EnvironmentService:_setRain()
	self:_setOvercast()
	task.wait(10)
	isRaining.Value = true
	lastWeather = WEATHER_STATES.RAIN
end

function EnvironmentService:_setClear()
	isRaining.Value = false
	cloudsTweens.normal:Play()
	cloudsTweens.light:Play()
	task.wait(120)
end

function EnvironmentService:_updateWeather()
	math.randomseed(os.time())
	local randNum = math.random(-25, 500)

	if randNum > 300 and randNum < 450 then
		currentWeather = WEATHER_STATES.OVERCAST
	elseif randNum > 450 then
		currentWeather = WEATHER_STATES.RAIN
	else
		currentWeather = WEATHER_STATES.CLEAR
	end

	if currentWeather ~= lastWeather then
		if currentWeather == WEATHER_STATES.OVERCAST then
			self:_setOvercast()
			task.wait(math.random(200, 400))
		elseif currentWeather == WEATHER_STATES.RAIN then
			self:_setRain()
			task.wait(math.random(200, 400))
		end
		self:_setClear()
		self.WeatherChanged:Fire(currentWeather)
		self.Client.WeatherChanged:Fire(currentWeather)
	end
end

function EnvironmentService:_weatherCycle()
	task.wait(100)
	while true do
		self:_updateWeather()
		task.wait(math.random(15, 25))
	end
end

----- Public Functions -----
function EnvironmentService:GetCurrentWeather()
	return currentWeather
end

function EnvironmentService:GetWeatherState(state: number): string
	if state == WEATHER_STATES.CLEAR then
		return "Clear"
	elseif state == WEATHER_STATES.OVERCAST then
		return "Overcast"
	elseif state == WEATHER_STATES.RAIN then
		return "Rain"
	end
	return "Unknown"
end

----- Initialize -----
function EnvironmentService:KnitStart()
	clouds = workspace:WaitForChild("Terrain"):WaitForChild("Clouds")
	isRaining = ReplicatedStorage.IsRaining
	self:_initializeTweens()
	self:_weatherCycle()
end

function EnvironmentService:KnitInit()
	-- Initialization logic if needed
end

return EnvironmentService
