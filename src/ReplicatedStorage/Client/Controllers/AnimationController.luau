-- Services
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local AssetsFolder = ReplicatedStorage:WaitForChild("Assets") :: Folder
local AnimationsFolder = AssetsFolder:WaitForChild("Animations") :: Folder

local FRONT_FLIP_DISTANCE = 8
local FRONT_FLIP_TIME = 1

local HUDUIController

local AnimationController = Knit.CreateController({
	Name = "AnimationController",
})
AnimationController._trove = Trove.new()

local function getCharacterMass(char): number
	local mass = 0
	for _, child in pairs(char:GetChildren()) do
		if child:IsA("BasePart") then
			mass = mass + child:GetMass()
		elseif child:IsA("Accessory") then
			for _, accessoryChild in pairs(child:GetChildren()) do
				if accessoryChild:IsA("BasePart") then
					mass = mass + accessoryChild:GetMass()
				end
			end
		end
	end
	return mass
end

function AnimationController:KnitStart()
	HUDUIController = Knit.GetController("HUDUIController")

	local character = Knit.Player.Character
	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	local debounce: boolean = false

	local function cannonballAnimation(keycode: string)
		if debounce then
			return
		end

		if humanoid.Sit then
			return
		end

		debounce = true
		local anim = AnimationsFolder:WaitForChild("Cannonball") :: Animation
		local animator = humanoid:WaitForChild("Animator") :: Animator
		local animTrack = animator:LoadAnimation(anim)

		local force = Instance.new("VectorForce")
		force.Force = Vector3.new(0, 4500, -1200)
		force.ApplyAtCenterOfMass = true
		force.Attachment0 = hrp:FindFirstChildWhichIsA("Attachment")
		force.Parent = hrp

		animTrack:Play()
		humanoid.Sit = true

		HUDUIController:SetActionFrameSelection(keycode, true)
		task.wait(0.5)
		force:Destroy()
		task.wait(3)
		debounce = false
		HUDUIController:SetActionFrameSelection(keycode, false)
	end

	local function diveAnimation(keycode: string)
		if debounce then
			return
		end

		if humanoid.Sit then
			return
		end

		if humanoid.PlatformStand then
			return
		end

		local mass = getCharacterMass(character)
		local anim = AnimationsFolder:WaitForChild("Dive") :: Animation
		local animator = humanoid:WaitForChild("Animator") :: Animator
		local animTrack = animator:LoadAnimation(anim)

		HUDUIController:SetActionFrameSelection(keycode, true)

		local force = Instance.new("VectorForce")

		local weight = math.clamp(mass, 12.5, 22.5)
		local yMinForce = 2700 -- minimum Y force value (adjustable)
		local yMaxForce = 4600 -- maximum Y force value (adjustable)
		local zMinForce = 900 -- minimum Z force value (adjustable)
		local zMaxForce = 1400 -- maximum Z force value (adjustable)

		local yForce = (weight - 12.5) / (22.5 - 12.5) * (yMaxForce - yMinForce) + yMinForce
		local zForce = (weight - 12.5) / (22.5 - 12.5) * (zMaxForce - zMinForce) + zMinForce

		force.Force = Vector3.new(0, yForce, zForce * -1)
		force.ApplyAtCenterOfMass = true
		force.Attachment0 = hrp:FindFirstChildWhichIsA("Attachment")
		force.Parent = hrp

		humanoid.PlatformStand = true
		animTrack:Play()

		Debris:AddItem(force, 0.5)
		task.wait(2)

		humanoid.PlatformStand = false
		HUDUIController:SetActionFrameSelection(keycode, false)
	end

	local function frontFlipAnimation(keycode: string)
		if debounce then
			return
		end

		local origin = hrp.CFrame.p
		local direction = hrp.CFrame.LookVector * (FRONT_FLIP_DISTANCE - 1)

		local raycastPar = RaycastParams.new()
		raycastPar.FilterType = Enum.RaycastFilterType.Exclude
		raycastPar.FilterDescendantsInstances = { character }
		local raycastResult = workspace:Raycast(origin, direction, raycastPar)

		if raycastResult then
			return
		end

		local anim = AnimationsFolder:WaitForChild("FrontFlip") :: Animation
		local animator = humanoid:WaitForChild("Animator") :: Animator
		local animTrack = animator:LoadAnimation(anim)

		HUDUIController:SetActionFrameSelection(keycode, true)
		debounce = true
		local walkspeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 0
		local tweenInfo = TweenInfo.new(FRONT_FLIP_TIME)
		local tween =
			TweenService:Create(hrp, tweenInfo, { CFrame = hrp.CFrame * CFrame.new(0, 0, -FRONT_FLIP_DISTANCE) })
		tween:Play()
		animTrack:Play()
		tween.Completed:Wait()
		tween:Destroy()
		tween = nil
		humanoid.WalkSpeed = walkspeed
		debounce = false
		HUDUIController:SetActionFrameSelection(keycode, false)
	end

	local function onInputBegan(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local keycode: string = input.KeyCode.Name

		if keycode == "X" then
			cannonballAnimation(keycode)
		elseif keycode == "C" then
			diveAnimation(keycode)
		elseif keycode == "V" then
			frontFlipAnimation(keycode)
		end
	end

	self._trove:Connect(UserInputService.InputBegan, function(input: InputObject, gpe: boolean)
		if gpe then
			return
		end
		onInputBegan(input)
	end)
end

function AnimationController:KnitInit() end

return AnimationController
