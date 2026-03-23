-- Services
local CollectionService = game:GetService("CollectionService")
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
	TreesPlaced = Signal.new(),
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
	self._isRaining.Value = true
	lastWeather = WEATHER_STATES.RAIN
end

function EnvironmentService:_setClear()
	self._isRaining.Value = false
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
	while task.wait(math.random(15, 25)) do
		self:_updateWeather()
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
local function placeTrees()
	local treeSpots: { Instance } = CollectionService:GetTagged("TreeSpot")
	local treeFolder: Folder = ReplicatedStorage:FindFirstChild("Trees")

	if not treeSpots or not treeFolder then
		warn("EnvironmentService: missing TreeSpots or TreeFolder")
		return
	end

	local treeList = treeFolder:GetChildren()
	if #treeList == 0 then
		warn("EnvironmentService: no templates found in TreeFolder")
		return
	end

	if workspace:FindFirstChild("Trees") then
		workspace.Trees:Destroy()
	end

	local treeModel = Instance.new("Model")
	treeModel.Name = "Trees"
	treeModel.Parent = workspace

	for _, spot in pairs(treeSpots) do
		if spot:IsA("BasePart") or spot:IsA("Model") then
			if spot:IsA("BasePart") then
				spot.Transparency = 1
			elseif spot:IsA("Model") and spot.PrimaryPart then
				spot.PrimaryPart.Transparency = 1
			end

			local template = treeList[math.random(1, #treeList)]:Clone()
			template.Parent = treeModel

			if template.PrimaryPart then
				template:SetPrimaryPartCFrame(spot.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0))
			end
		end
	end
end

function EnvironmentService:KnitStart()
	clouds = workspace:WaitForChild("Terrain"):WaitForChild("Clouds")
	self._isRaining = ReplicatedStorage.IsRaining
	self:_initializeTweens()
	placeTrees()
	self:_weatherCycle()
end

function EnvironmentService:KnitInit()
	-- Initialization logic if needed
end

return EnvironmentService
