local Promise = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/Promise.lua"))()
local TableUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/TableUtil.lua"))()

local Client = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local info = TweenInfo.new()

local TweenModel = function(ModelToTween, CFrame)
    return Promise.new(function(resolve, reject)
        local CFrameValue = Instance.new("CFrameValue")
        CFrameValue.Value = ModelToTween:GetPrimaryPartCFrame()
    
        CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
            ModelToTween:SetPrimaryPartCFrame(CFrameValue.Value)
        end)

        local Tween = TweenService:Create(CFrameValue, info, { Value = CFrame })
        Tween:Play();

		Tween.Completed:Connect(function() 
			ModelToTween:SetPrimaryPartCFrame(CFrame)
		end)
        resolve(Tween.Completed)
    end)
end

local GetPlot = function() return getrenv()._G.Plot end
local GetLoadingDock = function() 
    local Plot = tostring(GetPlot())
    local DockNum = string.gsub(Plot, "Plot_", "")
    return game:GetService("Workspace").Map.Landmarks["Loading Dock"]["LoadingDock_" .. DockNum].LoadingSpot
end

local GetVehicle; GetVehicle = function()
    for _, v in next, workspace.PlayerVehicles:GetChildren() do
        if v.Name:match(Client.Name) then
            return v
        end
    end
    game:GetService("ReplicatedStorage").Remotes.SpawnVehicle:InvokeServer(1, Client.Character.HumanoidRootPart.CFrame * CFrame.new(10, 5, 0))
    task.wait()
    return GetVehicle()
end

local GetUnloadingDock; GetUnloadingDock = function()
    return TableUtil.Filter(GetPlot():GetDescendants(), function(part)
        return part.Name:lower():match("door") and part:FindFirstChild("Handle") and part:FindFirstChild("Base")
    end)[1]
end

local GetVehicleSeat; GetVehicleSeat = function(Vehicle)
    local Seats = TableUtil.Filter(Vehicle:GetDescendants(), function(part)
        return part:IsA("Seat")
    end)
    
    return Seats[#Seats]
end

local LoadCar = function()
    return Promise.new(function(resolve, reject)
		local Vehicle = GetVehicle();
        local VehicleSeat = GetVehicleSeat(Vehicle)
		
        local VehicleSize = Vehicle:GetExtentsSize();

        VehicleSeat:Sit(Client.Character:WaitForChild("Humanoid"))
        TweenModel(Vehicle, GetLoadingDock().CFrame * CFrame.new(0, 0, -VehicleSize.Z + 5)):andThen(function() 
			task.wait(3)
            game:GetService("ReplicatedStorage").Remotes.LoadVehicle:InvokeServer()
            task.wait(1)
            resolve()
		end)
    end)
end

local UnloadCar = function()
    return Promise.new(function(resolve, reject)
        local UnloadingDock = GetUnloadingDock();
        local Vehicle = GetVehicle();
        local VehicleSeat = GetVehicleSeat(Vehicle);
        local VehicleSize = Vehicle:GetExtentsSize();
        VehicleSeat:Sit(Client.Character:WaitForChild("Humanoid"))
		local Position = CFrame.new(UnloadingDock.Base.Position + Vector3.new(-VehicleSize.Z + 10, 0, 6)) * CFrame.Angles(0, 90, 0);
        TweenModel(Vehicle, Position):andThen(function() 
            task.wait(3)
            game:GetService("ReplicatedStorage").Remotes.UnloadVehicle:InvokeServer()
            task.wait(1)
            resolve()
		end)
    end)
end

while task.wait(1) do
    local Plot = tostring(GetPlot())
    local DockNum = string.gsub(Plot, "Plot_", "")
    local BayStorage = game:GetService("Workspace").Map.Landmarks["Loading Dock"]["LoadingDock_"..DockNum].BayStorage;
	
	if #BayStorage:GetChildren() > 0 then
        LoadCar():andThen(function()
            UnloadCar()
        end):andThen(function() 
            task.wait(1)
        end)
	task.wait(1)
    end
end
