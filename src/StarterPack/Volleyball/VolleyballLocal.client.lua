local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local holdObj = tool:WaitForChild("Hold")
local swingObj = tool:WaitForChild("Swing")
local progressEmitter = handle:WaitForChild("Progress")
local minNumber = 7
local maxNumber = 25
local currentNumber = minNumber
local incrementAmount = .2

local mainScript = tool:WaitForChild("VolleyballServer")
local Event = mainScript:WaitForChild("FireVolleyball")

local player = game.Players.LocalPlayer
local char = player.Character
local hum = char:WaitForChild("Humanoid")

local holdAnim = hum:LoadAnimation(holdObj)
local swingAnim = hum:LoadAnimation(swingObj)

local counting = false
Debounce = false
thrown = false

local function updateEmitterColor()
	if progressEmitter then
		local progress = (currentNumber - minNumber) / (maxNumber - minNumber)
		progressEmitter.Color = ColorSequence.new(Color3.new(1, 1 - progress, 1 - progress))
	end
end

local function onActivated()
	if Debounce == false then
		Debounce = true
		counting = true
		progressEmitter.Enabled = true
		holdAnim:Play()
		
		while counting and currentNumber <= maxNumber do
			currentNumber = currentNumber + incrementAmount
			updateEmitterColor()
			progressEmitter.Rate = math.floor(currentNumber / 2)
			wait(.05)
		end
	end
end

local function onDeactivated()
	if Debounce == true and thrown == false then
		counting = false
		progressEmitter.Enabled = false
		holdAnim:Stop()
		swingAnim:Play()
		Event:FireServer(currentNumber, math.rad(75))
		thrown = true
		currentNumber = minNumber
		updateEmitterColor()
		progressEmitter.Rate = 2
		wait(10)
		Debounce = false
		thrown = false
	end
end

tool.Activated:Connect(onActivated)
tool.Deactivated:Connect(onDeactivated)