local TweenService = game:GetService("TweenService")
local butterfliesFolder = workspace:WaitForChild("Butterflies")
local spawn1 = butterfliesFolder:WaitForChild("bfSp1")
local spawn2 = butterfliesFolder:WaitForChild("bfSp2")
local bflyMod = game:GetService("ReplicatedStorage"):WaitForChild("Butterfly")

texNames = {"A", "B", "C", "D"}

function spawnButterfly(BFlySpawn)
	local Butterfly = bflyMod:Clone()
	Butterfly.Parent = butterfliesFolder
	
	local Plane = Butterfly:WaitForChild("Plane")
	
	Butterfly[texNames[math.random(1, #texNames)]].Parent = Plane
	
	local Anim = Butterfly:WaitForChild("Animation")
	local anCont = Butterfly:WaitForChild("AnimationController")
	local animTrack = anCont:LoadAnimation(Anim)
	
	local minOrbitRadius = 1
	local maxOrbitRadius = 6
	local flyDistance = 8
	local flySpeed = 4
	local bobIntensity = 0.3

	local orbitRadius = math.random(minOrbitRadius, maxOrbitRadius)
	local theta = math.rad(math.random(0, 360))
	Plane.CFrame = BFlySpawn.CFrame * CFrame.new(orbitRadius * math.cos(theta), 0, orbitRadius * math.sin(theta))
	local bflyOrg = Plane.CFrame

	animTrack:Play()

	spawn(function()
		while true do
			local direction = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
			local targetCFrame = CFrame.new(Plane.Position) * CFrame.Angles(0, math.atan2(direction.X, direction.Z), 0)
			local tweenInfo = TweenInfo.new(flySpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local tween = TweenService:Create(Plane, tweenInfo, {CFrame = targetCFrame})
			tween:Play()
			tween.Completed:Wait()


			local bobUp = true

			for i = 1, flyDistance do 
				targetCFrame = Plane.CFrame+direction 
				if bobUp then 
					targetCFrame = targetCFrame + Vector3.new(0 , bobIntensity , 0) 
				else 
					targetCFrame = targetCFrame - Vector3.new(0 , bobIntensity , 0) 
				end 
				bobUp = not bobUp 

				tweenInfo = TweenInfo.new(flySpeed/flyDistance , Enum.EasingStyle.Sine , Enum.EasingDirection.InOut ) 
				tween = TweenService:Create(Plane , tweenInfo , { CFrame=targetCFrame }) 
				tween:Play() 
				tween.Completed:Wait() 
			end 

			wait(math.random(1, 3))

			for i = 1, flyDistance do 
				targetCFrame = Plane.CFrame-direction 
				if bobUp then 
					targetCFrame = targetCFrame+Vector3.new(0 , bobIntensity , 0) 
				else 
					targetCFrame = targetCFrame-Vector3.new(0 , bobIntensity , 0) 
				end 
				bobUp = not bobUp 

				tweenInfo = TweenInfo.new(flySpeed/flyDistance , Enum.EasingStyle.Sine , Enum.EasingDirection.InOut ) 
				tween = TweenService:Create(Plane , tweenInfo , { CFrame=targetCFrame }) 
				tween:Play() 
				tween.Completed:Wait() 
			end 

			Plane.CFrame = bflyOrg
			wait(math.random(1, 3)) 

		end
	end)
end

for i = 1, 4 do
	spawnButterfly(spawn1)
	spawnButterfly(spawn2)
end
